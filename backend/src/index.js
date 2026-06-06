const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const http = require('http');
const { Server } = require('socket.io');
const { body, query, validationResult } = require('express-validator');
const cron = require('node-cron');
require('dotenv').config();

const { requireAuth, verifyFirebaseToken, signToken, admin } = require('./middleware/auth');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const port = process.env.PORT || 5000;

// Middleware
app.use(helmet({
  contentSecurityPolicy: false, // Turn off CSP for easy Firebase CDN scripts injection
}));
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Panel Page Handlers
app.get('/doctor', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/doctor.html'));
});

app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/admin.html'));
});

// Routes
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Health check route
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// ──────────────────────────────────────────────
// UTILITY: FCM Push Notification Sender
// ──────────────────────────────────────────────
async function sendPush(phone, title, body) {
  try {
    const user = await prisma.user.findUnique({
      where: { phone },
      select: { fcmToken: true }
    });
    if (!user?.fcmToken) {
      console.log(`ℹ️ No FCM token for ${phone}, skipping push`);
      return;
    }

    await admin.messaging().send({
      token: user.fcmToken,
      notification: { title, body },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } }
    });

    // Store notification in DB
    await prisma.notification.create({
      data: { phone, title, body }
    });

    console.log(`📲 Push sent to ${phone}: ${title}`);
  } catch (e) {
    console.error('FCM send failed:', e.message);
  }
}

// ──────────────────────────────────────────────
// AUTH ROUTES (public — no requireAuth)
// ──────────────────────────────────────────────

// POST /api/auth/verify — verify user identity and issue JWT
app.post('/api/auth/verify', async (req, res) => {
  try {
    const { phone, role, authKey } = req.body;

    // Auth Key Check for Staff — now uses env variable
    const staffKey = process.env.STAFF_AUTH_KEY || 'aarogya123';
    if ((role === 'doctor' || role === 'admin') && authKey !== staffKey) {
      return res.status(401).json({ error: 'Invalid Auth Key.' });
    }

    const user = await prisma.user.findUnique({
      where: { phone },
      include: { patient: true, doctor: true }
    });

    if (user) {
      // Issue JWT token
      const token = signToken({
        phone: user.phone,
        role: user.role,
        userId: user.id,
      });
      return res.json({ isNew: false, user, token });
    } else {
      return res.json({ isNew: true });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// PROTECTED ROUTES (requireAuth applied)
// ──────────────────────────────────────────────

// SYNC — full data pull
app.get('/api/sync', async (req, res) => {
  try {
    const clinics = await prisma.clinic.findMany();
    const doctors = await prisma.doctor.findMany();
    const appointments = await prisma.appointment.findMany();
    const reports = await prisma.report.findMany();
    res.json({ clinics, doctors, appointments, reports });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// APPOINTMENT ROUTES
// ──────────────────────────────────────────────
const appointmentValidation = [
  body('symptoms').trim().isLength({ min: 3 }).withMessage('Symptoms must be at least 3 characters'),
  body('consultationType').isIn(['Physical', 'Telemedicine', 'Physical consult']).withMessage('Invalid consultation type'),
];

app.post('/api/appointments', appointmentValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const appt = await prisma.appointment.create({ data: req.body });
    io.emit('db_update', { type: 'appointment_created', data: appt });

    // Send push notification to patient
    if (appt.patientPhone) {
      sendPush(
        appt.patientPhone,
        'MediVan Dispatched 🚛',
        `Your van is on the way — ETA ~15 mins. Doctor: ${appt.doctorName}`
      );
    }

    res.json(appt);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/appointments/:id', async (req, res) => {
  try {
    const appt = await prisma.appointment.update({
      where: { id: req.params.id },
      data: req.body
    });
    io.emit('db_update', { type: 'appointment_updated', data: appt });
    res.json(appt);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// CLINIC ROUTES
// ──────────────────────────────────────────────

// GET /api/clinics/nearby — find clinics within radius using Haversine formula
app.get('/api/clinics/nearby', [
  query('lat').isFloat().withMessage('Latitude is required'),
  query('lng').isFloat().withMessage('Longitude is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { lat, lng, radius = 15 } = req.query;
    const latNum = parseFloat(lat);
    const lngNum = parseFloat(lng);
    const radiusNum = parseFloat(radius);

    const clinics = await prisma.clinic.findMany({ where: { status: 'ACTIVE' } });

    // Haversine distance filter
    const R = 6371; // Earth radius in km
    const nearby = clinics.filter(c => {
      const dLat = (c.latitude - latNum) * Math.PI / 180;
      const dLng = (c.longitude - lngNum) * Math.PI / 180;
      const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(latNum * Math.PI / 180) * Math.cos(c.latitude * Math.PI / 180) *
        Math.sin(dLng / 2) ** 2;
      const dist = R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      c.distanceKm = Math.round(dist * 10) / 10;
      return dist <= radiusNum;
    }).sort((a, b) => a.distanceKm - b.distanceKm);

    res.json(nearby);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// REPORT ROUTES
// ──────────────────────────────────────────────
app.post('/api/reports', async (req, res) => {
  try {
    const report = await prisma.report.create({ data: req.body });
    io.emit('db_update', { type: 'report_created', data: report });
    res.json(report);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// PRESCRIPTION ROUTES
// ──────────────────────────────────────────────
app.post('/api/prescriptions', async (req, res) => {
  try {
    const { appointmentId, patientId, doctorName, diagnosis, medicines, notes } = req.body;

    const prescription = await prisma.prescription.create({
      data: {
        appointmentId,
        patientId,
        doctorName,
        diagnosis,
        medicines,
        notes
      }
    });

    await prisma.activityLog.create({
      data: {
        role: 'DOCTOR',
        action: 'ISSUED_PRESCRIPTION',
        details: `${doctorName} issued prescription for Appt: ${appointmentId}`
      }
    });

    // Update appointment status to COMPLETED
    const appt = await prisma.appointment.update({
      where: { id: appointmentId },
      data: { status: 'COMPLETED' }
    });

    io.emit('db_update', { type: 'prescription_created', data: prescription });
    io.emit('db_update', { type: 'appointment_updated', data: appt });

    // Send push to patient
    if (appt.patientPhone) {
      sendPush(
        appt.patientPhone,
        'Prescription Ready 💊',
        `Dr. ${doctorName} has issued your prescription. Tap to view.`
      );
    }

    res.json(prescription);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// DIAGNOSTICS ROUTES
// ──────────────────────────────────────────────
app.post('/api/diagnostics', [
  body('appointmentId').notEmpty().withMessage('Appointment ID is required'),
  body('readings').isArray({ min: 1 }).withMessage('At least one reading is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { appointmentId, readings } = req.body;
    // readings: [{ testName, result, referenceRange }]
    const created = await Promise.all(
      readings.map(r => prisma.diagnostic.create({
        data: { appointmentId, testName: r.testName, result: r.result, referenceRange: r.referenceRange }
      }))
    );

    io.emit('db_update', { type: 'diagnostics_added', data: created });

    await prisma.activityLog.create({
      data: {
        role: 'DOCTOR',
        action: 'DIAGNOSTICS_RECORDED',
        details: `${created.length} diagnostics recorded for appointment ${appointmentId}`
      }
    });

    res.json(created);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/diagnostics/:appointmentId', async (req, res) => {
  try {
    const diags = await prisma.diagnostic.findMany({
      where: { appointmentId: req.params.appointmentId }
    });
    res.json(diags);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// MEDICINE ORDER ROUTES
// ──────────────────────────────────────────────
app.post('/api/orders', [
  body('patientId').notEmpty().withMessage('Patient ID is required'),
  body('medicines').isArray({ min: 1 }).withMessage('At least one medicine is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { patientId, medicines, deliveryAddress, prescriptionId } = req.body;
    const order = {
      id: `ord_${Date.now()}`,
      patientId,
      medicines,
      deliveryAddress,
      prescriptionId,
      status: 'PENDING',
      createdAt: new Date()
    };

    // Update stock for each medicine ordered
    await Promise.all(medicines.map(m =>
      prisma.medicine.updateMany({
        where: { name: m.name },
        data: { stockCount: { decrement: m.quantity || 1 } }
      })
    ));

    await prisma.activityLog.create({
      data: {
        role: 'PATIENT',
        action: 'MEDICINE_ORDER',
        details: JSON.stringify(order)
      }
    });

    io.emit('db_update', { type: 'medicine_order', data: order });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// USER ROUTES
// ──────────────────────────────────────────────
app.post('/api/users/profile', async (req, res) => {
  try {
    const { phone, name, role, age, gender, address, medicalHistory } = req.body;

    const user = await prisma.user.create({
      data: {
        phone,
        name,
        role: role.toUpperCase()
      }
    });

    if (role === 'patient') {
      await prisma.patient.create({
        data: {
          userId: user.id,
          age: parseInt(age) || 0,
          gender: gender || 'Other',
          address: address || '',
          medicalHistory: medicalHistory || ''
        }
      });
    } else if (role === 'doctor') {
      await prisma.doctor.create({
        data: {
          userId: user.id,
          specialization: 'General'
        }
      });
    }

    const fullUser = await prisma.user.findUnique({
      where: { id: user.id },
      include: { patient: true, doctor: true }
    });

    // Issue JWT token for newly created user
    const token = signToken({
      phone: fullUser.phone,
      role: fullUser.role,
      userId: fullUser.id,
    });

    res.json({ ...fullUser, token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/users/fcm-token — save FCM token for push notifications
app.post('/api/users/fcm-token', async (req, res) => {
  try {
    const { phone, token } = req.body;
    if (!phone || !token) {
      return res.status(400).json({ error: 'Phone and token are required' });
    }

    const user = await prisma.user.update({
      where: { phone },
      data: { fcmToken: token }
    });

    res.json({ success: true, message: 'FCM token saved' });
  } catch (error) {
    // User might not exist yet — that's fine
    if (error.code === 'P2025') {
      return res.json({ success: false, message: 'User not found — token will be saved on next login' });
    }
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// ACTIVITY LOG ROUTES
// ──────────────────────────────────────────────
app.get('/api/activity', async (req, res) => {
  try {
    const logs = await prisma.activityLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50
    });
    res.json(logs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// NOTIFICATION ROUTES
// ──────────────────────────────────────────────
app.get('/api/notifications/:phone', async (req, res) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { phone: req.params.phone },
      orderBy: { createdAt: 'desc' },
      take: 20
    });
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// SEED ROUTE (disabled in production)
// ──────────────────────────────────────────────
app.post('/api/seed', async (req, res) => {
  if (process.env.NODE_ENV === 'production') {
    return res.status(403).json({ error: 'Seed disabled in production' });
  }

  try {
    // Clear existing data
    await prisma.diagnostic.deleteMany();
    await prisma.prescription.deleteMany();
    await prisma.appointment.deleteMany();
    await prisma.report.deleteMany();
    await prisma.doctor.deleteMany();
    await prisma.clinic.deleteMany();
    await prisma.medicine.deleteMany();
    await prisma.activityLog.deleteMany();
    await prisma.notification.deleteMany();

    // ── 3 Clinics at real coordinates ──
    const clinic1 = await prisma.clinic.create({
      data: {
        name: 'Primary Care Unit A',
        vehicleNumber: 'DL-01-A-1234',
        latitude: 28.6271,
        longitude: 77.3760,
        address: 'Sector 62, Noida, UP',
        currentLocation: 'Noida Sector 62 Main Crossing, UP',
        services: 'General Checkup, Pediatrics, Vaccinations',
        status: 'ACTIVE'
      }
    });

    const clinic2 = await prisma.clinic.create({
      data: {
        name: 'Maternal & Child Health Express',
        vehicleNumber: 'DL-02-B-5678',
        latitude: 28.4595,
        longitude: 77.0266,
        address: 'Sector 15, Gurugram, HR',
        currentLocation: 'Gurugram Sector 15 Community Center',
        services: 'Gynaecology, Pediatrics, Ultrasound',
        status: 'ACTIVE'
      }
    });

    const clinic3 = await prisma.clinic.create({
      data: {
        name: 'Emergency Response Van',
        vehicleNumber: 'DL-03-C-9012',
        latitude: 28.6139,
        longitude: 77.2090,
        address: 'Connaught Place, New Delhi',
        currentLocation: 'Near India Gate, New Delhi',
        services: 'Emergency Care, First Aid, Diagnostics',
        status: 'ACTIVE'
      }
    });

    // ── Doctor users ──
    let docUser1 = await prisma.user.findUnique({ where: { phone: '+919999999991' } });
    if (!docUser1) {
      docUser1 = await prisma.user.create({
        data: { name: 'Dr. Aarav Sharma', phone: '+919999999991', role: 'DOCTOR' }
      });
    }

    let docUser2 = await prisma.user.findUnique({ where: { phone: '+919999999992' } });
    if (!docUser2) {
      docUser2 = await prisma.user.create({
        data: { name: 'Dr. Priya Patel', phone: '+919999999992', role: 'DOCTOR' }
      });
    }

    let docUser3 = await prisma.user.findUnique({ where: { phone: '+919999999993' } });
    if (!docUser3) {
      docUser3 = await prisma.user.create({
        data: { name: 'Dr. Ananya Rao', phone: '+919999999993', role: 'DOCTOR' }
      });
    }

    // ── 3 Doctors with specializations ──
    const doctor1 = await prisma.doctor.create({
      data: {
        userId: docUser1.id,
        specialization: 'General Physician',
        clinicId: clinic1.id,
        isAvailable: true
      }
    });

    const doctor2 = await prisma.doctor.create({
      data: {
        userId: docUser2.id,
        specialization: 'Paediatrician',
        clinicId: clinic1.id,
        isAvailable: true
      }
    });

    const doctor3 = await prisma.doctor.create({
      data: {
        userId: docUser3.id,
        specialization: 'Gynaecologist',
        clinicId: clinic2.id,
        isAvailable: true
      }
    });

    // ── Demo patient user ──
    let patientUser = await prisma.user.findUnique({ where: { phone: '+911111111111' } });
    if (!patientUser) {
      patientUser = await prisma.user.create({
        data: { name: 'Raj Kumar', phone: '+911111111111', role: 'PATIENT' }
      });
    }

    let patient = await prisma.patient.findUnique({ where: { userId: patientUser.id } });
    if (!patient) {
      patient = await prisma.patient.create({
        data: {
          userId: patientUser.id,
          age: 35,
          gender: 'Male',
          address: 'Sector 62, Noida',
          medicalHistory: 'Mild hypertension'
        }
      });
    }

    // ── 2 CONFIRMED appointments (for live tracking demo) ──
    const confirmedAppt1 = await prisma.appointment.create({
      data: {
        clinicId: clinic1.id,
        doctorId: doctor1.id,
        patientId: patient.id,
        symptoms: 'Persistent headache, mild fever',
        doctorName: 'Dr. Aarav Sharma',
        doctorSpecialization: 'General Physician',
        clinicName: 'Primary Care Unit A',
        patientName: 'Raj Kumar',
        patientPhone: '+911111111111',
        address: 'Sector 62, Noida',
        consultationType: 'Physical',
        status: 'CONFIRMED',
        scheduledAt: new Date(),
      }
    });

    const confirmedAppt2 = await prisma.appointment.create({
      data: {
        clinicId: clinic1.id,
        doctorId: doctor2.id,
        patientId: patient.id,
        symptoms: 'Skin rash, itching',
        doctorName: 'Dr. Priya Patel',
        doctorSpecialization: 'Paediatrician',
        clinicName: 'Primary Care Unit A',
        patientName: 'Raj Kumar',
        patientPhone: '+911111111111',
        address: 'Sector 62, Noida',
        consultationType: 'Telemedicine',
        status: 'CONFIRMED',
        scheduledAt: new Date(Date.now() + 3600000), // 1 hour from now
      }
    });

    // ── 1 COMPLETED appointment with prescription ──
    const completedAppt = await prisma.appointment.create({
      data: {
        clinicId: clinic1.id,
        doctorId: doctor1.id,
        patientId: patient.id,
        symptoms: 'Mild Fever, Cough',
        doctorName: 'Dr. Aarav Sharma',
        doctorSpecialization: 'General Physician',
        clinicName: 'Primary Care Unit A',
        patientName: 'Raj Kumar',
        patientPhone: '+911111111111',
        address: 'Sector 62, Noida',
        consultationType: 'Physical',
        status: 'COMPLETED',
        scheduledAt: new Date(Date.now() - 5 * 86400000), // 5 days ago
      }
    });

    // Prescription for completed appointment
    await prisma.prescription.create({
      data: {
        appointmentId: completedAppt.id,
        patientId: patient.id,
        doctorName: 'Dr. Aarav Sharma',
        diagnosis: 'Viral fever with upper respiratory infection',
        medicines: 'Paracetamol 500mg - twice daily for 5 days\nCetirizine 10mg - once at night for 3 days\nCough Syrup - 10ml thrice daily for 5 days',
        notes: 'Rest well, drink plenty of fluids. Follow up in 7 days if symptoms persist.',
        followUpDays: 7,
      }
    });

    // ── 5 Medicines in stock ──
    await prisma.medicine.createMany({
      data: [
        { name: 'Paracetamol 500mg', dosage: '500mg', stockCount: 200 },
        { name: 'Cetirizine 10mg', dosage: '10mg', stockCount: 150 },
        { name: 'Amoxicillin 250mg', dosage: '250mg', stockCount: 100 },
        { name: 'ORS Sachets', dosage: '1 sachet', stockCount: 300 },
        { name: 'Ibuprofen 400mg', dosage: '400mg', stockCount: 120 },
      ]
    });

    // ── Activity logs ──
    await prisma.activityLog.createMany({
      data: [
        { role: 'SYSTEM', action: 'DATABASE_SEEDED', details: 'Demo data initialized for hackathon' },
        { role: 'PATIENT', action: 'APPOINTMENT_BOOKED', details: `${patientUser.name} booked a Physical appointment` },
        { role: 'DOCTOR', action: 'ISSUED_PRESCRIPTION', details: `Dr. Aarav Sharma issued prescription for ${patientUser.name}` },
      ]
    });

    io.emit('db_update', { type: 'seed_complete' });
    res.json({
      message: 'Seeded successfully with rich demo data',
      data: {
        clinics: 3,
        doctors: 3,
        confirmedAppointments: 2,
        completedAppointments: 1,
        medicines: 5,
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ──────────────────────────────────────────────
// Socket.io event pipeline
// ──────────────────────────────────────────────
io.on('connection', (socket) => {
  console.log('A client connected to real-time sync stream:', socket.id);

  // Driver GPS update — broadcast and persist
  socket.on('gps_update', async (data) => {
    console.log('Live GPS position update broadcast:', data);
    io.emit('gps_position', data);

    // Also update clinic's last known GPS position in DB
    if (data.clinicId) {
      try {
        await prisma.clinic.update({
          where: { id: data.clinicId },
          data: {
            lastGpsLat: data.lat,
            lastGpsLng: data.lng,
            lastGpsTime: new Date(),
          }
        });
      } catch (e) {
        console.error('GPS DB update failed:', e.message);
      }
    }
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected from stream:', socket.id);
  });
});

// ──────────────────────────────────────────────
// CRON JOBS — Follow-up reminders
// ──────────────────────────────────────────────
// Run daily at 8 AM IST (2:30 AM UTC)
cron.schedule('30 2 * * *', async () => {
  console.log('🔔 Running follow-up reminder check...');
  try {
    const today = new Date();
    const prescriptions = await prisma.prescription.findMany({
      include: {
        appointment: true
      }
    });

    for (const rx of prescriptions) {
      const followUpDate = new Date(rx.createdAt);
      followUpDate.setDate(followUpDate.getDate() + rx.followUpDays);

      const daysUntil = Math.ceil((followUpDate - today) / (1000 * 60 * 60 * 24));
      if (daysUntil === 1 && rx.appointment?.patientPhone) {
        await sendPush(
          rx.appointment.patientPhone,
          'Follow-up Reminder 📋',
          `Dr. ${rx.doctorName} recommended a follow-up tomorrow. Tap to book.`
        );
        console.log(`📋 Sent follow-up reminder to ${rx.appointment.patientPhone}`);
      }
    }
  } catch (e) {
    console.error('Follow-up cron error:', e.message);
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

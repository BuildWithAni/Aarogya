const admin = require('firebase-admin');
const jwt = require('jsonwebtoken');

// Initialize Firebase Admin once
if (!admin.apps.length) {
  try {
    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
      ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
      : null;

    if (serviceAccount) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log('✅ Firebase Admin initialized with service account');
    } else {
      // Fallback: initialize without credentials (dev mode)
      admin.initializeApp();
      console.log('⚠️ Firebase Admin initialized without service account (dev mode)');
    }
  } catch (e) {
    console.error('❌ Firebase Admin initialization failed:', e.message);
    // Initialize with default for dev environments
    admin.initializeApp();
  }
}

/**
 * Middleware: verify Firebase ID token from client
 * Expects `x-firebase-token` header
 */
async function verifyFirebaseToken(req, res, next) {
  const idToken = req.headers['x-firebase-token'];
  if (!idToken) return res.status(401).json({ error: 'No Firebase token provided' });

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.uid = decoded.uid;
    req.phone = decoded.phone_number;
    next();
  } catch (e) {
    console.error('Firebase token verification failed:', e.message);
    res.status(401).json({ error: 'Invalid Firebase token' });
  }
}

/**
 * Middleware: verify internal JWT on protected routes
 * Expects `Authorization: Bearer <token>` header
 */
function requireAuth(req, res, next) {
  // Skip auth in development if JWT_SECRET is not set
  if (process.env.NODE_ENV === 'development' && !process.env.JWT_SECRET) {
    req.user = { phone: 'dev_user', role: 'PATIENT', userId: 'dev' };
    return next();
  }

  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized — no token provided' });

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (e) {
    res.status(401).json({ error: 'Token expired or invalid' });
  }
}

/**
 * Generate a signed JWT for a verified user
 */
function signToken(payload) {
  return jwt.sign(payload, process.env.JWT_SECRET || 'dev_fallback_secret', {
    expiresIn: '7d',
  });
}

module.exports = { verifyFirebaseToken, requireAuth, signToken, admin };

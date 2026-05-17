import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("My Appointments", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF22D3EE),
          labelColor: const Color(0xFF22D3EE),
          unselectedLabelColor: Colors.white38,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: "UPCOMING"),
            Tab(text: "PAST"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList(isUpcoming: true),
          _buildAppointmentList(isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildAppointmentList({required bool isUpcoming}) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: isUpcoming ? 1 : 5,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(
          isUpcoming: isUpcoming,
          doctor: "Dr. Sarah Wilson",
          type: "Physical Consultation",
          date: isUpcoming ? "Tomorrow, 10:00 AM" : "12 May 2026, 02:30 PM",
          status: isUpcoming ? "CONFIRMED" : "COMPLETED",
        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildAppointmentCard({
    required bool isUpcoming,
    required String doctor,
    required String type,
    required String date,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF22D3EE).withOpacity(0.1), shape: BoxShape.circle),
                child: const Text("👨‍⚕️", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(type, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (status == "CONFIRMED") ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: (status == "CONFIRMED") ? Colors.green : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 40, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF22D3EE), size: 16),
                  const SizedBox(width: 8),
                  Text(date, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              if (isUpcoming)
                const Text("Track 🚛", style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 13))
              else
                const Text("View Report 📄", style: TextStyle(color: Color(0xFF22D3EE), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

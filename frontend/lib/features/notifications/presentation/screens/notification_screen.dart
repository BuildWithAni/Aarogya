import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Notifications", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () {}, child: const Text("Mark all as read", style: TextStyle(color: Color(0xFF22D3EE), fontSize: 12))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationGroup("Today"),
          _buildNotificationItem(
            emoji: "🚛",
            title: "Clinic Arriving Soon",
            desc: "Mobile Clinic #402 is just 2 km away from your location.",
            time: "2 mins ago",
            isUnread: true,
          ),
          _buildNotificationItem(
            emoji: "💊",
            title: "Medicine Reminder",
            desc: "Time to take your Morning Dose (Paracetamol 500mg).",
            time: "1 hour ago",
            isUnread: true,
          ),
          const SizedBox(height: 30),
          _buildNotificationGroup("Yesterday"),
          _buildNotificationItem(
            emoji: "📅",
            title: "Appointment Confirmed",
            desc: "Your consultation with Dr. Sarah Wilson is confirmed for tomorrow.",
            time: "20 hours ago",
            isUnread: false,
          ),
          _buildNotificationItem(
            emoji: "🧪",
            title: "Lab Report Ready",
            desc: "Your Blood Test results from 10th May are now available.",
            time: "1 day ago",
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationGroup(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Text(
        title,
        style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String emoji,
    required String title,
    required String desc,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF22D3EE).withOpacity(0.05) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnread ? const Color(0xFF22D3EE).withOpacity(0.2) : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Color(0xFF22D3EE), shape: BoxShape.circle),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

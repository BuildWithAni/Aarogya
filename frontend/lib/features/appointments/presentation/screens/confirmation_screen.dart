import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Center(child: Icon(Icons.check, color: Colors.white, size: 60)),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 30),
              
              Text(
                "Booking Confirmed!",
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 12),
              
              Text(
                "A mobile clinic has been assigned to you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
              ).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(height: 60),
              
              _buildDetailCard("👨‍⚕️ Assigned Doctor", "Dr. Sarah Wilson", "General Physician"),
              const SizedBox(height: 20),
              _buildDetailCard("🚛 Assigned Clinic", "Mobile Clinic #402", "In Transit"),
              const SizedBox(height: 20),
              _buildDetailCard("⏳ Estimated Arrival", "15 - 20 Minutes", "Arriving at your location"),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => context.push('/tracking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22D3EE),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("LIVE TRACKING", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ).animate().fadeIn(delay: 1.seconds),
              
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text("Back to Home", style: TextStyle(color: Colors.white.withOpacity(0.4))),
              ).animate().fadeIn(delay: 1.2.seconds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String mainText, String subText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: const Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(mainText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subText, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

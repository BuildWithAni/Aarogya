import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _consultationType = 'Physical';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Book Appointment", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Describe Symptoms"),
            const SizedBox(height: 12),
            _buildTextField("Tell us how you are feeling...", maxLines: 5),
            
            const SizedBox(height: 30),
            
            _buildSectionHeader("Upload Previous Reports"),
            const SizedBox(height: 12),
            _buildUploadSection(),
            
            const SizedBox(height: 30),
            
            _buildSectionHeader("Consultation Type"),
            const SizedBox(height: 12),
            _buildConsultationTypeSelector(),
            
            const SizedBox(height: 60),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => context.push('/appointment-confirmation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22D3EE),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("CONFIRM BOOKING", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.2), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Text("📄", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text("Tap to upload PDF or Images", style: TextStyle(color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text("CHOOSE FILES"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1),
              foregroundColor: const Color(0xFF22D3EE),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationTypeSelector() {
    return Row(
      children: [
        _buildTypeCard("Physical", "🏠", "Doctor visits you"),
        const SizedBox(width: 16),
        _buildTypeCard("Telemedicine", "💻", "Video Consultation"),
      ],
    );
  }

  Widget _buildTypeCard(String type, String emoji, String subtitle) {
    bool isSelected = _consultationType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _consultationType = type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF22D3EE).withOpacity(0.1) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.05),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

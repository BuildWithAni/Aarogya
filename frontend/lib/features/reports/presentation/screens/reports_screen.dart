import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Medical Reports", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSearchAndFilter(),
          const SizedBox(height: 30),
          _buildSectionHeader("Recent Documents"),
          const SizedBox(height: 16),
          _buildReportCard("Prescription - General Checkup", "12 May 2026", "PDF", "1.2 MB"),
          _buildReportCard("Blood Test Results", "10 May 2026", "PDF", "2.4 MB"),
          _buildReportCard("X-Ray Report - Chest", "05 May 2026", "JPG", "5.1 MB"),
          const SizedBox(height: 30),
          _buildSectionHeader("Archived Reports"),
          const SizedBox(height: 16),
          _buildReportCard("Vaccination Certificate", "15 Jan 2026", "PDF", "0.8 MB"),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search reports...",
          hintStyle: TextStyle(color: Colors.white24),
          prefixIcon: Icon(Icons.search, color: Colors.white38),
          border: InputBorder.none,
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

  Widget _buildReportCard(String title, String date, String type, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF22D3EE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(type == "PDF" ? "📄" : "🖼️", style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("$date • $size", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, color: Color(0xFF22D3EE)),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1)),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.05, end: 0);
  }
}

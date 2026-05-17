import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.white)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildStats(),
            const SizedBox(height: 40),
            _buildMenuSection("ACCOUNT", [
              _buildMenuItem(Icons.person_outline, "Edit Profile", "Change your basic information"),
              _buildMenuItem(Icons.history, "Medical History", "Manage your past health records"),
              _buildMenuItem(Icons.location_on_outlined, "Manage Addresses", "Add or edit visit locations"),
            ]),
            const SizedBox(height: 30),
            _buildMenuSection("SUPPORT", [
              _buildMenuItem(Icons.help_outline, "Help & Support", "Get in touch with us"),
              _buildMenuItem(Icons.description_outlined, "Terms & Policies", "Legal information"),
            ]),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF22D3EE), width: 2),
                color: const Color(0xFF0F172A),
              ),
              child: const Center(child: Text("👤", style: TextStyle(fontSize: 40))),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF22D3EE), shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 14, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Anirudh", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text("+91 98765 43210", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("12", "Consultations"),
        Container(width: 1, height: 40, color: Colors.white10),
        _buildStatItem("05", "Reports"),
        Container(width: 1, height: 40, color: Colors.white10),
        _buildStatItem("A+", "Blood Group"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF22D3EE))),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF22D3EE), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text("LOGOUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }
}

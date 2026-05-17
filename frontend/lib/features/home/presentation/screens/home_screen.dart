import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyCard(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Quick Actions"),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Nearby Clinics"),
                  const SizedBox(height: 16),
                  _buildNearbyClinics(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Upcoming Appointments"),
                  const SizedBox(height: 16),
                  _buildUpcomingAppointment(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: const Color(0xFF020617),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello, Anirudh!", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("How are you feeling today?", style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Badge(
                label: Text("2", style: TextStyle(fontSize: 8)),
                child: Icon(Icons.notifications_none, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Text("🏥", style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFF7F1D1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "EMERGENCY REQUEST",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  "Need immediate help? Request the nearest mobile clinic now.",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7F1D1D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SOS REQUEST", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Text("🆘", style: TextStyle(fontSize: 80)),
        ],
      ),
    ).animate().fadeIn().scale(duration: 400.ms);
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Color(0xFF22D3EE)))),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.push('/booking'),
          child: _buildActionItem("📅", "Book Consultation", const Color(0xFF22D3EE)),
        ),
        _buildActionItem("💊", "Order Medicine", const Color(0xFFFACC15)),
        _buildActionItem("🧪", "Lab Tests", const Color(0xFFC084FC)),
      ],
    );
  }

  Widget _buildActionItem(String emoji, String title, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 80,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildNearbyClinics() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("🚛", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Clinic #402", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("2.4 km away", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("ACTIVE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Spacer(),
                const Text("Next Stop: Sector 4 Community Center", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                const LinearProgressIndicator(value: 0.7, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(Color(0xFF22D3EE))),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildUpcomingAppointment() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFF22D3EE), shape: BoxShape.circle),
            child: const Text("👨‍⚕️", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dr. Sarah Wilson", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("General Physician • Tomorrow, 10:00 AM", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFF22D3EE), size: 16),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

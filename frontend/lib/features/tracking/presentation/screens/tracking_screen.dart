import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Simulated Map Background
          _buildSimulatedMap(),
          
          // Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0F172A),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Text("🚛", style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Mobile Clinic #402", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Arriving in 12 mins", style: TextStyle(color: const Color(0xFF22D3EE), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Clinic Marker on Map (Simulated Movement)
          Positioned(
            top: 300,
            left: 150,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF22D3EE), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Clinic #402", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Text("🚛", style: TextStyle(fontSize: 40)),
              ],
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -20, duration: 2.seconds, curve: Curves.easeInOut)
              .moveX(begin: 0, end: 30, duration: 4.seconds),
          ),
          
          // User Marker
          Positioned(
            bottom: 300,
            right: 100,
            child: Column(
              children: [
                const Text("📍", style: TextStyle(fontSize: 40)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Text("You", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Bottom Info Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
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
                            const Text("Dr. Sarah Wilson", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("On her way with the team", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.call, color: Color(0xFF22D3EE)),
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1)),
                      ),
                    ],
                  ),
                  const Divider(height: 40, color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat("Speed", "34 km/h"),
                      _buildStat("Distance", "4.2 km"),
                      _buildStat("Temp", "24°C"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedMap() {
    return Container(
      color: const Color(0xFF020617),
      child: Stack(
        children: [
          // Simulated Grid Lines
          for (int i = 0; i < 10; i++)
            Positioned(
              left: (i * 50).toDouble(),
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: Colors.white.withOpacity(0.02)),
            ),
          for (int i = 0; i < 20; i++)
            Positioned(
              top: (i * 50).toDouble(),
              left: 0,
              right: 0,
              child: Container(height: 1, color: Colors.white.withOpacity(0.02)),
            ),
          
          // Simulated Roads
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Container(height: 40, color: Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            left: 180,
            top: 0,
            bottom: 0,
            child: Container(width: 40, color: Colors.white.withOpacity(0.05)),
          ),
          
          // Simulated "Buildings" / Text Blocks
          _buildMapLabel(200, 100, "SECTOR 4"),
          _buildMapLabel(500, 250, "PARK AREA"),
          _buildMapLabel(700, 50, "HEALTH HUB"),
        ],
      ),
    );
  }

  Widget _buildMapLabel(double top, double left, String text) {
    return Positioned(
      top: top,
      left: left,
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.05), fontWeight: FontWeight.bold, letterSpacing: 4, fontSize: 12),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

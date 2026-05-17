import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      emoji: "🏥",
      title: "Mobile Clinics",
      description: "Aarogyam brings fully equipped medical clinics directly to your neighborhood.",
    ),
    OnboardingData(
      emoji: "👨‍⚕️",
      title: "Expert Doctors",
      description: "Connect with specialized doctors via telemedicine or physical consultations.",
    ),
    OnboardingData(
      emoji: "🛰️",
      title: "Real-time Tracking",
      description: "Track the medical clinic's location in real-time as it travels to you.",
    ),
    OnboardingData(
      emoji: "🔐",
      title: "Data Privacy",
      description: "Your health records are secure, encrypted, and accessible only by you.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(data: _pages[index]);
            },
          ),
          
          // Navigation Controls
          Positioned(
            bottom: 60,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? const Color(0xFF22D3EE) 
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate().scale(duration: 300.ms),
                  ),
                ),
                
                // Next/Get Started Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _showPermissionsDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22D3EE),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? "GET STARTED" : "NEXT",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "App Permissions",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPermissionItem("📍", "Location", "Required for clinic tracking."),
            _buildPermissionItem("🔔", "Notifications", "Get updates on clinic arrival."),
            _buildPermissionItem("📸", "Camera", "For telemedicine consultations."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text("GRANT PERMISSIONS", style: TextStyle(color: Color(0xFF22D3EE))),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String emoji;
  final String title;
  final String description;

  OnboardingData({required this.emoji, required this.title, required this.description});
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPageWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22D3EE).withOpacity(0.05),
            ),
            child: Center(
              child: Text(
                data.emoji,
                style: const TextStyle(fontSize: 100),
              ).animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

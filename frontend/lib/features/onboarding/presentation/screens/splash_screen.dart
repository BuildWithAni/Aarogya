import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text/Emoji Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22D3EE).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.2)),
              ),
              child: const Center(
                child: Text(
                  "🏥",
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ).animate()
              .scale(duration: 800.ms, curve: Curves.elasticOut)
              .shimmer(delay: 1.seconds, duration: 1.5.seconds),
            
            const SizedBox(height: 40),
            
            Text(
              "AAROGYAM",
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
            
            const SizedBox(height: 12),
            
            Text(
              "HEALTHCARE AT YOUR DOORSTEP",
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 3,
                color: const Color(0xFF22D3EE).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 80),
            
            // Loading Animation
            SizedBox(
              width: 40,
              height: 40,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22D3EE)),
              ).animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1.seconds),
            ),
          ],
        ),
      ),
    );
  }
}

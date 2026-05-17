import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aarogya/routes/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AarogyamApp(),
    ),
  );
}

class AarogyamApp extends StatelessWidget {
  const AarogyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aarogyam - Future of Healthcare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFF22D3EE),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      routerConfig: goRouter,
    );
  }
}

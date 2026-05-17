import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_setup_screen.dart';
import '../features/home/presentation/screens/main_screen.dart';
import '../features/appointments/presentation/screens/booking_screen.dart';
import '../features/appointments/presentation/screens/confirmation_screen.dart';
import '../features/tracking/presentation/screens/tracking_screen.dart';
import '../features/notifications/presentation/screens/notification_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OTPScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) => const BookingScreen(),
    ),
    GoRoute(
      path: '/appointment-confirmation',
      builder: (context, state) => const AppointmentConfirmationScreen(),
    ),
    GoRoute(
      path: '/tracking',
      builder: (context, state) => const TrackingScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);

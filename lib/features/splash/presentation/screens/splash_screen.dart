import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen as soon as initial load is ready
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214), // Faint dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Faint glow logo with icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF81B64C).withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/icon.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1E1E24),
                    child: const Icon(
                      Icons.extension,
                      size: 64,
                      color: Color(0xFF81B64C),
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.0, 1.0),
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            const Text(
              'PeerChess',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

            const SizedBox(height: 36),

            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF81B64C),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

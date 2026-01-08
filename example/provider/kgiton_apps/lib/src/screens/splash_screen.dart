/// ============================================================================
/// Splash Screen
/// ============================================================================
///
/// File: src/screens/splash_screen.dart
/// Deskripsi: Splash screen dengan logo KGiTON dan auto-navigation
///
/// Alur:
/// 1. Tampilkan logo dan loading
/// 2. Cek status autentikasi
/// 3. Navigate ke AuthScreen atau HomeScreen
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../config/theme.dart';
import 'auth/auth_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate after delay
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check auth status
    final authProvider = context.read<AuthProvider>();

    // Wait for auth check to complete
    while (authProvider.status == AuthStatus.initial || authProvider.status == AuthStatus.loading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Navigate based on auth status
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => authProvider.isLoggedIn ? const HomeScreen() : const AuthScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KGiTONColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.scale,
                        size: 60,
                        color: KGiTONColors.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    const Text(
                      'KGiTON',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Smart Scale Solution',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading indicator
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ============================================================================
/// Splash View
/// ============================================================================
/// 
/// File: src/views/splash_view.dart
/// Deskripsi: Splash screen dengan KGiTON branding
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../config/theme.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KGiTONColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(16),
              child: SvgPicture.asset(
                'assets/kgiton_logo.svg',
                colorFilter: const ColorFilter.mode(
                  KGiTONColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            const Text(
              'KGiTON Scale',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'GetX Example',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

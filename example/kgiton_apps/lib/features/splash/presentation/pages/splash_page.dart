import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Splash screen page - shown when app starts
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Request permissions and check auth
    _initializeApp();
  }

  /// Initialize app with permission request
  Future<void> _initializeApp() async {
    // Wait for animation
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Request Bluetooth and Location permissions
    final hasPermissions = await PermissionHelper.checkBLEPermissions();
    if (!hasPermissions) {
      final granted = await PermissionHelper.requestBLEPermissions();
      if (!granted) {
        if (!mounted) return;
        final errorMsg = await PermissionHelper.getPermissionErrorMessage();
        _showPermissionDialog(errorMsg);
        return;
      }
    }

    // Check authentication
    if (!mounted) return;
    context.read<AuthBloc>().add(const CheckAuthStatus());
  }

  /// Show permission dialog
  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Text('Permission Required', style: TextStyle(color: KgitonThemeColors.textPrimary)),
        content: Text(message, style: const TextStyle(color: KgitonThemeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionHelper.openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.primaryGreen),
            child: const Text('Open Settings', style: TextStyle(color: KgitonThemeColors.backgroundDark)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/home');
          } else if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset('assets/logo/kgiton-logo.png', width: 200, height: 200, fit: BoxFit.contain),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'KGiTON',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: KgitonThemeColors.primaryGreen, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Smart Weighing Solution',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: KgitonThemeColors.textSecondary),
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(KgitonThemeColors.primaryGreen)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// Auth Screen - Login & Register
/// ============================================================================
///
/// File: src/screens/auth/auth_screen.dart
/// Deskripsi: Screen untuk autentikasi (login dan register)
///
/// Fitur:
/// - Toggle antara login dan register
/// - Form validation
/// - Scan QR untuk license key (register)
/// - Error handling dengan snackbar
///
/// Cara menggunakan Provider di screen ini:
/// - context.read<AuthProvider>() untuk method calls
/// - context.watch<AuthProvider>() untuk listen state changes
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../home/home_screen.dart';
import 'widgets/login_form.dart';
import 'widgets/register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // ============================================================
                        // Logo Section
                        // ============================================================
                        _buildLogo(),

                        const SizedBox(height: 24),

                        // ============================================================
                        // Tab Bar (Login / Register)
                        // ============================================================
                        _buildTabBar(),

                        const SizedBox(height: 24),

                        // ============================================================
                        // Tab Content
                        // ============================================================
                        Expanded(child: _buildTabContent()),

                        const SizedBox(height: 16),

                        // ============================================================
                        // Error Message
                        // Menggunakan Consumer untuk listen error dari provider
                        // ============================================================
                        _buildErrorMessage(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build logo section
  Widget _buildLogo() {
    return Column(
      children: [
        // Logo icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: KGiTONColors.primary, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.scale, size: 40, color: Colors.white),
        ),

        const SizedBox(height: 16),

        // App name
        Text(
          'KGiTON',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: KGiTONColors.primary, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text('Smart Scale Solution', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  /// Build tab bar untuk switch login/register
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: KGiTONColors.primary, borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: KGiTONColors.textSecondaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }

  /// Build tab content
  Widget _buildTabContent() {
    // Calculate available height based on screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final tabContentHeight = screenHeight * 0.5; // 50% of screen height

    return SizedBox(
      height: tabContentHeight.clamp(350.0, 500.0), // Minimum 350, maximum 500
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Prevent horizontal scroll conflicts
        children: [
          // ================================================================
          // Login Form
          // ================================================================
          LoginForm(onLoginSuccess: () => _navigateToHome()),

          // ================================================================
          // Register Form
          // ================================================================
          RegisterForm(
            onRegisterSuccess: () {
              // Switch ke tab login setelah register
              _tabController.animateTo(0);
              _showMessage('Registrasi berhasil! Silakan verifikasi email Anda.');
            },
          ),
        ],
      ),
    );
  }

  /// Build error message widget
  ///
  /// Menggunakan Consumer untuk efficient rebuild hanya pada bagian ini
  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.errorMessage == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: KGiTONColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: KGiTONColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: KGiTONColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(authProvider.errorMessage!, style: const TextStyle(color: KGiTONColors.error)),
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => authProvider.clearError(), color: KGiTONColors.error),
            ],
          ),
        );
      },
    );
  }

  /// Navigate ke home screen
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  /// Show snackbar message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: KGiTONColors.success));
  }
}

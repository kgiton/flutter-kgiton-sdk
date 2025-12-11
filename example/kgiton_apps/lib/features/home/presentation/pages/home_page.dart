import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Home page - shown after successful authentication
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset('assets/logo/kgiton-logo.png', height: 120, fit: BoxFit.contain),
                      const SizedBox(height: 32),

                      // Welcome message
                      Text(
                        'Welcome!',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // User info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: KgitonThemeColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: KgitonThemeColors.borderDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(context, 'Name', state.user.name),
                            const Divider(color: KgitonThemeColors.divider, height: 24),
                            _buildInfoRow(context, 'Email', state.user.email),
                            const Divider(color: KgitonThemeColors.divider, height: 24),
                            _buildInfoRow(context, 'Role', state.user.role),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KgitonThemeColors.errorRed,
                            foregroundColor: KgitonThemeColors.textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(KgitonThemeColors.primaryGreen)));
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Text('Logout', style: TextStyle(color: KgitonThemeColors.textPrimary)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: KgitonThemeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Logout', style: TextStyle(color: KgitonThemeColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Profile page - user profile and settings
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Text('Logout', style: TextStyle(color: KgitonThemeColors.textPrimary)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: KgitonThemeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.errorRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: KgitonThemeColors.cardBackground, foregroundColor: KgitonThemeColors.textPrimary),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: KgitonThemeColors.cardBackground,
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.person, size: 50, color: KgitonThemeColors.primaryGreen),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.user.name,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(state.user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              state.user.role.toUpperCase(),
                              style: const TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Menu Items
                    _MenuItem(
                      icon: Icons.receipt_long,
                      title: 'Transaction History',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming Soon: Transaction History'),
                            backgroundColor: KgitonThemeColors.primaryGreen,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.inventory_2,
                      title: 'My Items',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming Soon: My Items'),
                            backgroundColor: KgitonThemeColors.primaryGreen,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.vpn_key,
                      title: 'License Keys',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming Soon: License Keys'),
                            backgroundColor: KgitonThemeColors.primaryGreen,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _MenuItem(icon: Icons.lock_outline, title: 'Change Password', onTap: () => context.push('/change-password')),
                    _MenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming Soon: Settings'),
                            backgroundColor: KgitonThemeColors.primaryGreen,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming Soon: Help & Support'),
                            backgroundColor: KgitonThemeColors.primaryGreen,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KgitonThemeColors.errorRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Info
                    Text('KGiTON Apps v1.0.0', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textSecondary)),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator(color: KgitonThemeColors.primaryGreen));
          },
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: KgitonThemeColors.cardBackground, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: KgitonThemeColors.primaryGreen),
        title: Text(
          title,
          style: const TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: KgitonThemeColors.textSecondary, size: 16),
        onTap: onTap,
      ),
    );
  }
}

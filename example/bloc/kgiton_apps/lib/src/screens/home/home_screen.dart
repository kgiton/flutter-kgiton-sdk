/// ============================================================================
/// Home Screen - BLoC Version
/// ============================================================================
/// 
/// Menggunakan BlocBuilder untuk rebuild UI berdasarkan state.
/// BlocSelector untuk select specific property dari state.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/scale/scale_bloc.dart';
import '../../bloc/scale/scale_event.dart';
import '../../bloc/scale/scale_state.dart';
import '../../config/theme.dart';
import '../auth/auth_screen.dart';
import '../device/device_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    // Get auth state synchronously for popup menu
    final authState = context.read<AuthBloc>().state;
    
    return AppBar(
      title: const Text('KGiTON Scale'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add(LogoutEvent());
            }
          },
          itemBuilder: (context) {
            return [
              // Access user data directly from state
              if (authState is AuthAuthenticated)
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        authState.user.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                const PopupMenuItem<String>(enabled: false, child: Text('User')),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: KGiTONColors.error),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthBloc>().add(RefreshUserDataEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 16),
            _buildWeightCard(context),
            const SizedBox(height: 16),
            _buildLicenseCard(context),
            const SizedBox(height: 16),
            _buildDeviceControlCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    /// BlocBuilder untuk rebuild ketika AuthState berubah
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: KGiTONColors.primary,
                  child: Text(
                    state.user.name.isNotEmpty ? state.user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat Datang,', style: Theme.of(context).textTheme.bodyMedium),
                      Text(state.user.name, style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightCard(BuildContext context) {
    /// BlocBuilder untuk ScaleState
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        final isConnected = state.isConnected;
        
        return Card(
          color: isConnected ? KGiTONColors.primary : null,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: isConnected ? Colors.white : KGiTONColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected 
                        ? 'Terhubung: ${state.connectedDevice?.name ?? "Device"}'
                        : 'Tidak Terhubung',
                      style: TextStyle(
                        color: isConnected ? Colors.white : KGiTONColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  state.weightDisplay,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.white : KGiTONColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                if (!isConnected)
                  OutlinedButton.icon(
                    onPressed: () => _navigateToDeviceScreen(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Cari Device'),
                  )
                else
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      return OutlinedButton.icon(
                        onPressed: () {
                          final licenseKey = authState is AuthAuthenticated 
                            ? authState.primaryLicenseKey 
                            : null;
                          context.read<ScaleBloc>().add(DisconnectEvent(licenseKey: licenseKey));
                        },
                        icon: const Icon(Icons.link_off, color: Colors.white),
                        label: const Text('Disconnect', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLicenseCard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        
        final licenses = state.licenses;
        if (licenses.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber, size: 48, color: KGiTONColors.warning),
                  const SizedBox(height: 8),
                  const Text('Belum ada license key'),
                ],
              ),
            ),
          );
        }
        
        final license = licenses.first;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.vpn_key, color: KGiTONColors.primary),
                    const SizedBox(width: 8),
                    Text('License Key', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: license.isActive 
                          ? KGiTONColors.success.withValues(alpha: 0.2)
                          : KGiTONColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        license.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: license.isActive ? KGiTONColors.success : KGiTONColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  license.key,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.token, size: 16, color: KGiTONColors.secondary),
                    const SizedBox(width: 4),
                    Text('Token Balance: ${license.tokenBalance}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceControlCard(BuildContext context) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        if (!state.isConnected) return const SizedBox.shrink();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: KGiTONColors.primary),
                    const SizedBox(width: 8),
                    Text('Device Control', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBuzzerButton(context, 'BEEP', Icons.notifications_active),
                    _buildBuzzerButton(context, 'BUZZ', Icons.vibration),
                    _buildBuzzerButton(context, 'LONG', Icons.timer),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuzzerButton(BuildContext context, String command, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () => context.read<ScaleBloc>().add(TriggerBuzzerEvent(command: command)),
      icon: Icon(icon, size: 18),
      label: Text(command),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        if (state.isConnected) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: () => _navigateToDeviceScreen(context),
          icon: const Icon(Icons.bluetooth_searching),
          label: const Text('Scan Device'),
        );
      },
    );
  }

  void _navigateToDeviceScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeviceScreen()),
    );
  }
}

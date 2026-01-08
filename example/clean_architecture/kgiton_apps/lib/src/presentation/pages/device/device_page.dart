/// ============================================================================
/// Device Page
/// ============================================================================
/// 
/// File: src/presentation/pages/device/device_page.dart
/// Deskripsi: Halaman untuk scan, connect, dan monitor device
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../../domain/entities/scale_device_entity.dart';
import '../../../injection/injection.dart';
import '../../bloc/scale/scale_bloc.dart';
import '../../bloc/scale/scale_event.dart';
import '../../bloc/scale/scale_state.dart';

class DevicePage extends StatelessWidget {
  final String licenseKey;

  const DevicePage({
    super.key,
    required this.licenseKey,
  });

  @override
  Widget build(BuildContext context) {
    // Create new ScaleBloc instance untuk page ini
    return BlocProvider(
      create: (_) => getIt<ScaleBloc>(),
      child: _DevicePageContent(licenseKey: licenseKey),
    );
  }
}

class _DevicePageContent extends StatelessWidget {
  final String licenseKey;

  const _DevicePageContent({required this.licenseKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
        actions: [
          BlocBuilder<ScaleBloc, ScaleState>(
            builder: (context, state) {
              if (state is ScaleConnected) {
                return IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    context.read<ScaleBloc>().add(const TriggerBuzzerEvent());
                  },
                  tooltip: 'Trigger Buzzer',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ScaleBloc, ScaleState>(
        listener: (context, state) {
          if (state is ScaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: KGiTONColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // License Key Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: KGiTONColors.primary.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key, color: KGiTONColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'License Key',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            licenseKey,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: _buildStateContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, ScaleState state) {
    // Initial state - show start scan button
    if (state is ScaleInitial || state is ScaleDisconnected) {
      return _buildInitialState(context);
    }
    
    // Scanning state - show device list
    if (state is ScaleScanning) {
      return _buildScanningState(context, state);
    }
    
    // Connecting state - show loading
    if (state is ScaleConnecting) {
      return _buildConnectingState(state);
    }
    
    // Connected state - show weight monitor
    if (state is ScaleConnected) {
      return _buildConnectedState(context, state);
    }
    
    // Error state
    if (state is ScaleError) {
      return _buildErrorState(context, state);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: KGiTONColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bluetooth_searching,
              size: 64,
              color: KGiTONColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Siap untuk scan device',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan Bluetooth aktif dan\ndevice dalam jangkauan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Mulai Scan'),
            onPressed: () {
              context.read<ScaleBloc>().add(const StartScanEvent());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState(BuildContext context, ScaleScanning state) {
    return Column(
      children: [
        // Scanning indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              const Text('Scanning...'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<ScaleBloc>().add(const StopScanEvent());
                },
                child: const Text('Stop'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Device list
        Expanded(
          child: state.devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_searching, 
                           size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Mencari device...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: state.devices.length,
                  itemBuilder: (context, index) {
                    final device = state.devices[index];
                    return _buildDeviceItem(context, device);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDeviceItem(BuildContext context, ScaleDeviceEntity device) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: KGiTONColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.scale, color: KGiTONColors.primary),
        ),
        title: Text(device.name),
        subtitle: Row(
          children: [
            Icon(
              Icons.signal_cellular_alt,
              size: 14,
              color: _getSignalColor(device.signalQuality),
            ),
            const SizedBox(width: 4),
            Text(
              '${device.rssi} dBm',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            context.read<ScaleBloc>().add(ConnectDeviceEvent(
              deviceId: device.id,
              licenseKey: licenseKey,
            ));
          },
          child: const Text('Connect'),
        ),
      ),
    );
  }

  Color _getSignalColor(SignalQuality quality) {
    switch (quality) {
      case SignalQuality.excellent:
        return KGiTONColors.success;
      case SignalQuality.good:
        return KGiTONColors.primaryLight;
      case SignalQuality.fair:
        return KGiTONColors.warning;
      case SignalQuality.poor:
        return KGiTONColors.error;
    }
  }

  Widget _buildConnectingState(ScaleConnecting state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Connecting to ${state.device.name}...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedState(BuildContext context, ScaleConnected state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Connection status
          Card(
            color: KGiTONColors.success.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: KGiTONColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: KGiTONColors.success,
                          ),
                        ),
                        Text(
                          state.device.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Weight display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: KGiTONColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: KGiTONColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Current Weight',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.currentWeight.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'kg',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Disconnect button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect'),
              onPressed: () {
                context.read<ScaleBloc>().add(DisconnectDeviceEvent(
                  licenseKey: licenseKey,
                ));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: KGiTONColors.error,
                side: const BorderSide(color: KGiTONColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ScaleError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed: () {
              context.read<ScaleBloc>().add(const StartScanEvent());
            },
          ),
        ],
      ),
    );
  }
}

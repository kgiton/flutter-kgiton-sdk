import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/widgets/add_to_cart_bottom_sheet.dart';
import '../../../item/presentation/bloc/item_bloc.dart';

/// Scale weighing page - main page for weighing items
class ScaleWeighingPage extends StatefulWidget {
  const ScaleWeighingPage({super.key});

  @override
  State<ScaleWeighingPage> createState() => _ScaleWeighingPageState();
}

class _ScaleWeighingPageState extends State<ScaleWeighingPage> with WidgetsBindingObserver {
  late final KGiTONScaleService _scaleService;

  WeightData? _currentWeight;
  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  bool _hasItems = false; // Track if user has items

  @override
  void initState() {
    super.initState();
    _scaleService = sl<KGiTONScaleService>();
    WidgetsBinding.instance.addObserver(this);
    _initializeScale();
    _checkItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Don't dispose singleton service
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload items when app returns to foreground
      _checkItems();
    }
  }

  void _checkItems() {
    // Load items to check if any exist
    context.read<ItemBloc>().add(const LoadItemsEvent());
  }

  void _initializeScale() {
    // Listen to weight stream
    _scaleService.weightStream.listen((weight) {
      setState(() {
        _currentWeight = weight;
      });
    });

    // Listen to connection state
    _scaleService.connectionStateStream.listen((state) {
      setState(() {
        _connectionState = state;
      });

      // Redirect to connection page if disconnected
      if (state == ScaleConnectionState.disconnected && mounted) {
        context.go('/scale-connection');
      }

      // Reload items when authenticated to update hasItems flag
      if (state == ScaleConnectionState.authenticated) {
        _checkItems();
      }
    });
  }

  Future<void> _disconnect() async {
    await _scaleService.disconnect();
    if (mounted) {
      context.go('/scale-connection');
    }
  }

  void _showAddToCartSheet() {
    // Get bloc instances from the current context before opening bottom sheet
    final itemBloc = context.read<ItemBloc>();
    final cartBloc = context.read<CartBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: itemBloc),
            BlocProvider.value(value: cartBloc),
          ],
          child: AddToCartBottomSheet(currentWeight: _currentWeight?.weight, scrollController: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Scale Weighing'),
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.textPrimary,
      ),
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          // Reload items when item is created or items are loaded
          if (state is ItemCreated || state is ItemsLoaded) {
            if (state is ItemsLoaded) {
              setState(() {
                _hasItems = state.items.isNotEmpty;
              });
            } else if (state is ItemCreated) {
              // Reload items after creation
              _checkItems();
            }
          }
        },
        child: Column(
          children: [
            // Connection Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KgitonThemeColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor(), width: 2),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        if (_scaleService.connectedDevice != null)
                          Text(
                            _scaleService.connectedDevice!.name,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Disconnect Button
                  ElevatedButton.icon(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.bluetooth_disabled, size: 18),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KgitonThemeColors.errorRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            // Weight Display
            Expanded(
              child: BlocListener<ItemBloc, ItemState>(
                listener: (context, state) {
                  if (state is ItemsLoaded) {
                    setState(() {
                      _hasItems = state.items.isNotEmpty;
                    });
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(48),
                              decoration: BoxDecoration(
                                color: KgitonThemeColors.cardBackground,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _currentWeight?.weight.toStringAsFixed(3) ?? '0.000',
                                    style: TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: _currentWeight != null && _currentWeight!.weight > 0
                                          ? KgitonThemeColors.primaryGreen
                                          : KgitonThemeColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _currentWeight?.unit ?? 'kg',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(color: KgitonThemeColors.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Buzzer controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _BuzzerButton(
                                  label: 'Beep',
                                  icon: Icons.notifications_outlined,
                                  onPressed: () => _scaleService.triggerBuzzer('BEEP'),
                                ),
                                const SizedBox(width: 12),
                                _BuzzerButton(label: 'Buzz', icon: Icons.vibration, onPressed: () => _scaleService.triggerBuzzer('BUZZ')),
                                const SizedBox(width: 12),
                                _BuzzerButton(label: 'Long', icon: Icons.notifications_active, onPressed: () => _scaleService.triggerBuzzer('LONG')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Add to Cart Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: KgitonThemeColors.cardBackground,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          // Info message if no items
                          if (!_hasItems)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: KgitonThemeColors.warningYellow.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: KgitonThemeColors.warningYellow.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: KgitonThemeColors.warningYellow, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'No items available',
                                          style: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Add at least 1 item to use cart',
                                          style: TextStyle(color: KgitonThemeColors.textSecondary.withValues(alpha: 0.8), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => context.push('/items'),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Item'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: KgitonThemeColors.primaryGreen,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _hasItems ? _showAddToCartSheet : null,
                              icon: const Icon(Icons.add_shopping_cart, size: 24),
                              label: const Text('Add to Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KgitonThemeColors.primaryGreen,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: KgitonThemeColors.textDisabled,
                                disabledForegroundColor: KgitonThemeColors.backgroundDark,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: _hasItems ? 4 : 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (_connectionState) {
      case ScaleConnectionState.disconnected:
        return Icons.bluetooth_disabled;
      case ScaleConnectionState.scanning:
        return Icons.bluetooth_searching;
      case ScaleConnectionState.connecting:
        return Icons.bluetooth_connected;
      case ScaleConnectionState.connected:
        return Icons.bluetooth_connected;
      case ScaleConnectionState.authenticated:
        return Icons.bluetooth_connected;
      case ScaleConnectionState.error:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    switch (_connectionState) {
      case ScaleConnectionState.disconnected:
        return KgitonThemeColors.textSecondary;
      case ScaleConnectionState.scanning:
        return KgitonThemeColors.warningYellow;
      case ScaleConnectionState.connecting:
        return KgitonThemeColors.warningYellow;
      case ScaleConnectionState.connected:
        return KgitonThemeColors.warningYellow;
      case ScaleConnectionState.authenticated:
        return KgitonThemeColors.successGreen;
      case ScaleConnectionState.error:
        return KgitonThemeColors.errorRed;
    }
  }

  String _getStatusText() {
    switch (_connectionState) {
      case ScaleConnectionState.disconnected:
        return 'Disconnected';
      case ScaleConnectionState.scanning:
        return 'Scanning...';
      case ScaleConnectionState.connecting:
        return 'Connecting...';
      case ScaleConnectionState.connected:
        return 'Connected';
      case ScaleConnectionState.authenticated:
        return 'Connected & Ready';
      case ScaleConnectionState.error:
        return 'Connection Error';
    }
  }
}

class _BuzzerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _BuzzerButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: KgitonThemeColors.primaryGreen, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

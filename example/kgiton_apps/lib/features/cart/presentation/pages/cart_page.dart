import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_bloc.dart';

/// Cart page - displays shopping cart items
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String _cartId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      debugPrint('=== CART PAGE: Starting _initializeCart ===');
      // Get license key to use as cartId
      String? licenseKey = await sl<AuthRepository>().getLicenseKey();
      debugPrint('=== CART PAGE: First attempt - License key: ${licenseKey ?? 'NULL'} ===');

      // Retry if license key is null (might be loading from cache)
      if (licenseKey == null || licenseKey.isEmpty) {
        debugPrint('=== CART PAGE: License key null/empty, waiting 500ms and retrying... ===');
        await Future.delayed(const Duration(milliseconds: 500));
        licenseKey = await sl<AuthRepository>().getLicenseKey();
        debugPrint('=== CART PAGE: Second attempt - License key: ${licenseKey ?? 'NULL'} ===');
      }

      if (licenseKey == null || licenseKey.isEmpty) {
        debugPrint('=== CART PAGE: ERROR - License key still null/empty after retry! ===');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to load cart: No license key found'), backgroundColor: KgitonThemeColors.errorRed));
        }
        return;
      }

      debugPrint('=== CART PAGE: SUCCESS - Cart initialized with license key: $licenseKey ===');

      if (mounted) {
        setState(() {
          _cartId = licenseKey!; // Already null-checked above
          _isLoading = false;
        });
        debugPrint('=== CART PAGE: Dispatching LoadCartEvent with cartId: $_cartId ===');
        // Load cart items
        context.read<CartBloc>().add(LoadCartEvent(_cartId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: KgitonThemeColors.errorRed));
      }
    }
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: KgitonThemeColors.warningYellow),
            SizedBox(width: 12),
            Text('Clear Cart', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          ],
        ),
        content: const Text('Are you sure you want to clear all items from cart?', style: TextStyle(color: KgitonThemeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartBloc>().add(ClearCartEvent(_cartId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.errorRed),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _removeItem(String cartItemId, String itemName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: KgitonThemeColors.warningYellow),
            SizedBox(width: 12),
            Text('Remove Item', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          ],
        ),
        content: Text('Are you sure you want to remove "$itemName" from cart?', style: const TextStyle(color: KgitonThemeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartBloc>().add(RemoveFromCartEvent(cartId: _cartId, cartItemId: cartItemId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.errorRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    String selectedPaymentMethod = 'CASH';
    String selectedPaymentGateway = 'external';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: KgitonThemeColors.cardBackground,
          title: const Row(
            children: [
              Icon(Icons.payment, color: KgitonThemeColors.primaryGreen),
              SizedBox(width: 12),
              Text('Select Payment Method', style: TextStyle(color: KgitonThemeColors.textPrimary)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Payment Method Options
                Column(
                  children: [
                    InkWell(
                      onTap: () => setDialogState(() => selectedPaymentMethod = 'CASH'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: selectedPaymentMethod == 'CASH'
                                  ? const Icon(Icons.radio_button_checked, color: KgitonThemeColors.primaryGreen, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: KgitonThemeColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.money, color: KgitonThemeColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            const Text('Cash', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setDialogState(() => selectedPaymentMethod = 'QRIS'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: selectedPaymentMethod == 'QRIS'
                                  ? const Icon(Icons.radio_button_checked, color: KgitonThemeColors.primaryGreen, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: KgitonThemeColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.qr_code, color: KgitonThemeColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            const Text('QRIS', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setDialogState(() => selectedPaymentMethod = 'BANK_TRANSFER'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: selectedPaymentMethod == 'BANK_TRANSFER'
                                  ? const Icon(Icons.radio_button_checked, color: KgitonThemeColors.primaryGreen, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: KgitonThemeColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.account_balance, color: KgitonThemeColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            const Text('Bank Transfer', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: KgitonThemeColors.borderDefault),
                const SizedBox(height: 16),
                const Text(
                  'Payment Gateway',
                  style: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Payment Gateway Options
                Column(
                  children: [
                    InkWell(
                      onTap: () => setDialogState(() => selectedPaymentGateway = 'internal'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: selectedPaymentGateway == 'internal'
                                  ? const Icon(Icons.radio_button_checked, color: KgitonThemeColors.primaryGreen, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: KgitonThemeColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Text('Internal', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setDialogState(() => selectedPaymentGateway = 'external'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: selectedPaymentGateway == 'external'
                                  ? const Icon(Icons.radio_button_checked, color: KgitonThemeColors.primaryGreen, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: KgitonThemeColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Text('External', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setDialogState(() => selectedPaymentGateway = 'xendit'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: selectedPaymentGateway == 'xendit'
                                  ? const Icon(Icons.radio_button_checked, color: KgitonThemeColors.primaryGreen, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: KgitonThemeColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Text('Xendit', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setDialogState(() => selectedPaymentGateway = 'midtrans'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: selectedPaymentGateway == 'midtrans'
                                  ? const Icon(Icons.radio_button_checked, color: KgitonThemeColors.primaryGreen, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: KgitonThemeColors.textSecondary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Text('Midtrans', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Trigger checkout event with selected payment method and gateway
                context.read<CartBloc>().add(
                  CheckoutCartEvent(
                    cartId: _cartId,
                    paymentMethod: selectedPaymentMethod,
                    paymentGateway: selectedPaymentGateway,
                    notes: 'Checkout from cart',
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.primaryGreen),
              child: const Text('Confirm Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.textPrimary,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final hasItems = state is CartLoaded && state.items.isNotEmpty;
              return IconButton(icon: const Icon(Icons.delete_outline), onPressed: hasItems ? _clearCart : null, tooltip: 'Clear Cart');
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: KgitonThemeColors.errorRed));
          } else if (state is CartCleared) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Cart cleared'), backgroundColor: KgitonThemeColors.successGreen));
          } else if (state is CartItemRemoved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Item removed from cart'), backgroundColor: KgitonThemeColors.successGreen));
          } else if (state is CartCheckedOut) {
            // Show success message with transaction number
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Checkout successful! Transaction: ${state.transactionNumber}'),
                backgroundColor: KgitonThemeColors.successGreen,
              ),
            );
            // Navigate to transaction page
            context.goNamed('transaction');
          }
        },
        builder: (context, state) {
          if (_isLoading || state is CartLoading) {
            return const Center(child: CircularProgressIndicator(color: KgitonThemeColors.primaryGreen));
          }

          if (state is CartLoaded) {
            if (state.isEmpty) {
              return _buildEmptyCart();
            }

            return Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = state.items[index];
                      return _CartItemCard(
                        cartItem: cartItem,
                        onRemove: () => _removeItem(cartItem.id, cartItem.item?.name ?? 'this item'),
                        currencyFormat: _currencyFormat,
                      );
                    },
                  ),
                ),

                // Cart summary
                _buildCartSummary(state),
              ],
            );
          }

          return _buildEmptyCart();
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: KgitonThemeColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Add items from weighing page', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: KgitonThemeColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Items', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary)),
                  Text(
                    '${state.itemCount} items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total Amount', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary)),
                  Text(
                    _currencyFormat.format(state.totalAmount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCheckoutDialog,
              icon: const Icon(Icons.payment),
              label: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: KgitonThemeColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final NumberFormat currencyFormat;

  const _CartItemCard({required this.cartItem, required this.onRemove, required this.currencyFormat});

  String _getPricingTypeLabel() {
    switch (cartItem.pricingType) {
      case PricingType.perKg:
        return 'Per Kg';
      case PricingType.perPcs:
        return 'Per Pcs';
      case PricingType.dualPrice:
        return 'Dual Price';
    }
  }

  String _getQuantityLabel() {
    switch (cartItem.pricingType) {
      case PricingType.perKg:
        // Show 3 decimal places for kg
        return '${cartItem.quantity.toStringAsFixed(3)} kg';
      case PricingType.dualPrice:
        // Show both kg and pcs for dual price items
        final kgText = '${cartItem.quantity.toStringAsFixed(3)} kg';
        final pcsText = cartItem.quantityPcs != null ? '${cartItem.quantityPcs!.toStringAsFixed(0)} pcs' : '0 pcs';
        return '$kgText • $pcsText';
      case PricingType.perPcs:
        // Show as whole number for pieces
        return '${(cartItem.quantityPcs ?? cartItem.quantity).toStringAsFixed(0)} pcs';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDualPrice = cartItem.pricingType == PricingType.dualPrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: KgitonThemeColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: KgitonThemeColors.borderDefault.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.inventory_2, color: KgitonThemeColors.primaryGreen, size: 32),
            ),

            const SizedBox(width: 16),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.item?.name ?? 'Unknown Item',
                    style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getPricingTypeLabel(),
                          style: const TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(_getQuantityLabel(), style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 14)),
                      ),
                    ],
                  ),
                  // Show breakdown for all items
                  if (cartItem.item != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: KgitonThemeColors.backgroundDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: KgitonThemeColors.borderDefault.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show kg breakdown for dual price and per kg items
                          if (cartItem.pricingType == PricingType.dualPrice || cartItem.pricingType == PricingType.perKg) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${cartItem.quantity.toStringAsFixed(3)} kg × ${currencyFormat.format(cartItem.item!.price)}',
                                  style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 11),
                                ),
                                Text(
                                  currencyFormat.format(cartItem.quantity * cartItem.item!.price),
                                  style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (cartItem.pricingType == PricingType.dualPrice) const SizedBox(height: 4),
                          ],
                          // Show pcs breakdown for dual price and per pcs items
                          if (cartItem.pricingType == PricingType.dualPrice || cartItem.pricingType == PricingType.perPcs) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(cartItem.quantityPcs ?? 0).toStringAsFixed(0)} pcs × ${currencyFormat.format(cartItem.item!.pricePerPcs ?? 0)}',
                                  style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 11),
                                ),
                                Text(
                                  currencyFormat.format((cartItem.quantityPcs ?? 0) * (cartItem.item!.pricePerPcs ?? 0)),
                                  style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isDualPrice ? 'Total:' : 'Price:', style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12)),
                      Text(
                        currencyFormat.format(cartItem.totalPrice),
                        style: const TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: KgitonThemeColors.errorRed),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';

/// Cart page - displays shopping cart items
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming Soon: Clear Cart'),
                  backgroundColor: KgitonThemeColors.primaryGreen,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Clear Cart',
          ),
        ],
      ),
      body: Center(
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
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KgitonThemeColors.cardBackground,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Rp 0',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming Soon: Checkout'),
                        backgroundColor: KgitonThemeColors.primaryGreen,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KgitonThemeColors.primaryGreen,
                    disabledBackgroundColor: KgitonThemeColors.buttonDisabled,
                    foregroundColor: KgitonThemeColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../item/domain/entities/item.dart';
import '../../../item/presentation/bloc/item_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_bloc.dart';

/// Bottom sheet for selecting item and adding to cart
class AddToCartBottomSheet extends StatefulWidget {
  final double? currentWeight; // Current weight from scale in kg
  final ScrollController? scrollController;

  const AddToCartBottomSheet({super.key, this.currentWeight, this.scrollController});

  @override
  State<AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
  Item? _selectedItem;
  PricingType? _selectedPricingType;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _useScaleWeight = false;

  @override
  void initState() {
    super.initState();
    // Load items when bottom sheet opens
    context.read<ItemBloc>().add(const LoadItemsEvent());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  PricingType _determinePricingType(Item item) {
    final hasKgPrice = item.price > 0;
    final hasPcsPrice = item.pricePerPcs != null && item.pricePerPcs! > 0;

    if (hasKgPrice && hasPcsPrice) {
      return PricingType.dualPrice;
    } else if (hasPcsPrice) {
      return PricingType.perPcs;
    } else {
      return PricingType.perKg;
    }
  }

  void _addToCart() {
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an item'), backgroundColor: KgitonThemeColors.errorRed));
      return;
    }

    double quantity = 0;
    double? quantityPcs;

    // Handle based on pricing type
    if (_selectedPricingType == PricingType.dualPrice) {
      // For dual price: use scale weight for kg + manual input for pcs
      if (widget.currentWeight != null && widget.currentWeight! > 0) {
        quantity = widget.currentWeight!;
      }

      // Parse quantity pcs from input
      final quantityText = _quantityController.text.trim();
      if (quantityText.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter quantity (pcs)'), backgroundColor: KgitonThemeColors.errorRed));
        return;
      }

      quantityPcs = double.tryParse(quantityText) ?? 0;
      if (quantityPcs <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Quantity (pcs) must be greater than 0'), backgroundColor: KgitonThemeColors.errorRed));
        return;
      }
      debugPrint('=== ADD TO CART: Dual Price - weight: ${quantity.toStringAsFixed(3)} kg, pcs: $quantityPcs ===');
    } else if (_selectedPricingType == PricingType.perKg) {
      // For per kg pricing, ALWAYS use scale weight if available
      if (widget.currentWeight != null && widget.currentWeight! > 0) {
        quantity = widget.currentWeight!;
        debugPrint('=== ADD TO CART: Using scale weight: ${quantity.toStringAsFixed(3)} kg ===');
      } else {
        // Parse quantity from input
        final quantityText = _quantityController.text.trim();
        if (quantityText.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Please enter quantity'), backgroundColor: KgitonThemeColors.errorRed));
          return;
        }

        quantity = double.tryParse(quantityText) ?? 0;
        if (quantity <= 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Quantity must be greater than 0'), backgroundColor: KgitonThemeColors.errorRed));
          return;
        }
        debugPrint('=== ADD TO CART: Using manual quantity: ${quantity.toStringAsFixed(3)} ===');
      }
    } else {
      // For per pcs pricing
      final quantityText = _quantityController.text.trim();
      if (quantityText.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter quantity'), backgroundColor: KgitonThemeColors.errorRed));
        return;
      }

      quantityPcs = double.tryParse(quantityText) ?? 0;
      if (quantityPcs <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Quantity must be greater than 0'), backgroundColor: KgitonThemeColors.errorRed));
        return;
      }
      debugPrint('=== ADD TO CART: Per Pcs - quantityPcs: $quantityPcs ===');
    }

    // Get license key and add to cart via SDK
    _addToCartWithSdk(quantity, quantityPcs);
  }

  Future<void> _addToCartWithSdk(double quantity, double? quantityPcs) async {
    try {
      debugPrint('=== ADD TO CART: Starting SDK add ===');
      // Get license key from auth repository
      final licenseKey = await sl<AuthRepository>().getLicenseKey();
      debugPrint('=== ADD TO CART: License key: ${licenseKey ?? "NULL"} ===');

      if (licenseKey == null || licenseKey.isEmpty) {
        debugPrint('=== ADD TO CART: ERROR - License key is null or empty ===');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get license key: No license key found'), backgroundColor: KgitonThemeColors.errorRed),
          );
        }
        return;
      }

      if (mounted) {
        debugPrint(
          '=== ADD TO CART: Dispatching AddToCartEvent with itemId: ${_selectedItem!.id}, item: ${_selectedItem!.name}, quantity: $quantity kg, quantityPcs: $quantityPcs ===',
        );
        // Add to cart using SDK
        context.read<CartBloc>().add(
          AddToCartEvent(
            cartId: licenseKey, // Use license key as cartId
            licenseKey: licenseKey,
            itemId: _selectedItem!.id,
            quantity: quantity,
            quantityPcs: quantityPcs,
            notes: null,
          ),
        );

        // Close bottom sheet
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${_selectedItem!.name} added to cart'), backgroundColor: KgitonThemeColors.successGreen));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: KgitonThemeColors.errorRed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KgitonThemeColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: KgitonThemeColors.textDisabled, borderRadius: BorderRadius.circular(2)),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.add_shopping_cart, color: KgitonThemeColors.primaryGreen),
                const SizedBox(width: 12),
                Text(
                  'Add to Cart',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Content
          Flexible(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item selection
                  Text(
                    'Select Item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  BlocBuilder<ItemBloc, ItemState>(
                    builder: (context, state) {
                      if (state is ItemLoading) {
                        return const Center(child: CircularProgressIndicator(color: KgitonThemeColors.primaryGreen));
                      }

                      if (state is ItemsLoaded) {
                        if (state.items.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: KgitonThemeColors.backgroundDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: KgitonThemeColors.borderDefault),
                            ),
                            child: const Center(
                              child: Text('No items available', style: TextStyle(color: KgitonThemeColors.textSecondary)),
                            ),
                          );
                        }

                        // Filter items based on search query
                        final filteredItems = _searchQuery.isEmpty
                            ? state.items
                            : state.items.where((item) {
                                return item.name.toLowerCase().contains(_searchQuery) ||
                                    (item.description?.toLowerCase().contains(_searchQuery) ?? false) ||
                                    item.unit.toLowerCase().contains(_searchQuery);
                              }).toList();

                        return Column(
                          children: [
                            // Search field
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(color: KgitonThemeColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search items...',
                                hintStyle: const TextStyle(color: KgitonThemeColors.textSecondary),
                                prefixIcon: const Icon(Icons.search, color: KgitonThemeColors.primaryGreen),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: KgitonThemeColors.textSecondary),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: KgitonThemeColors.backgroundDark,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: KgitonThemeColors.borderDefault),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: KgitonThemeColors.borderDefault),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: KgitonThemeColors.primaryGreen, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Items list
                            Container(
                              constraints: const BoxConstraints(maxHeight: 300),
                              decoration: BoxDecoration(
                                color: KgitonThemeColors.backgroundDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: KgitonThemeColors.borderDefault),
                              ),
                              child: filteredItems.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text('No items found', style: TextStyle(color: KgitonThemeColors.textSecondary)),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: filteredItems.length,
                                      separatorBuilder: (_, _) => const Divider(height: 1, color: KgitonThemeColors.borderDefault),
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        final isSelected = _selectedItem?.id == item.id;
                                        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedItem = item;
                                              final pricingType = _determinePricingType(item);
                                              _selectedPricingType = pricingType;

                                              // ALWAYS auto-enable scale weight for per kg ONLY items
                                              if (pricingType == PricingType.perKg) {
                                                _useScaleWeight = true;
                                                // Pre-fill quantity with current weight
                                                if (widget.currentWeight != null) {
                                                  _quantityController.text = widget.currentWeight!.toStringAsFixed(3);
                                                }
                                              } else {
                                                // For dual price and per pcs, clear quantity
                                                _useScaleWeight = false;
                                                _quantityController.clear();
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            color: isSelected ? KgitonThemeColors.primaryGreen.withValues(alpha: 0.1) : null,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                                  color: isSelected ? KgitonThemeColors.primaryGreen : KgitonThemeColors.textDisabled,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: TextStyle(
                                                          color: isSelected ? KgitonThemeColors.primaryGreen : KgitonThemeColors.textPrimary,
                                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Builder(
                                                        builder: (context) {
                                                          switch (item.unit) {
                                                            case 'kg-pcs':
                                                              return Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    ' • ${currencyFormatter.format(item.price)} / kg',
                                                                    style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12),
                                                                  ),
                                                                  Text(
                                                                    ' • ${currencyFormatter.format(item.pricePerPcs)} / pcs',
                                                                    style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12),
                                                                  ),
                                                                ],
                                                              );
                                                            case 'pcs':
                                                              return Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    ' • ${currencyFormatter.format(item.pricePerPcs)} / pcs',
                                                                    style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12),
                                                                  ),
                                                                ],
                                                              );
                                                            default:
                                                              return Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    ' • ${currencyFormatter.format(item.price)} / kg',
                                                                    style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12),
                                                                  ),
                                                                ],
                                                              );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  if (_selectedItem != null) ...[
                    const SizedBox(height: 20),

                    // Item details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: KgitonThemeColors.backgroundDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedItem!.name,
                                style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedItem!.unit,
                                  style: const TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: KgitonThemeColors.primaryGreen, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Rp ${_selectedItem!.price.toStringAsFixed(0)}/kg',
                                style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 14),
                              ),
                              if (_selectedItem!.pricePerPcs != null && _selectedItem!.pricePerPcs! > 0) ...[
                                const SizedBox(width: 16),
                                const Icon(Icons.shopping_basket, color: KgitonThemeColors.primaryGreen, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Rp ${_selectedItem!.pricePerPcs!.toStringAsFixed(0)}/pcs',
                                  style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 14),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dual price info
                    if (_selectedPricingType == PricingType.dualPrice) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: KgitonThemeColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dual Price Item',
                                    style: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Berat dari timbangan: ${widget.currentWeight != null ? widget.currentWeight!.toStringAsFixed(3) : '0.000'} kg',
                                    style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 11),
                                  ),
                                  const Text('Input jumlah pcs di bawah', style: TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Quantity input
                    Text(
                      _selectedPricingType == PricingType.dualPrice ? 'Quantity (Pcs)' : 'Quantity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Use scale weight checkbox (for per kg items ONLY - not for dual price)
                    if (_selectedPricingType == PricingType.perKg) ...[
                      if (widget.currentWeight != null && widget.currentWeight! > 0)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _useScaleWeight,
                                onChanged: (value) {
                                  setState(() {
                                    _useScaleWeight = value ?? false;
                                    if (_useScaleWeight) {
                                      _quantityController.clear();
                                    }
                                  });
                                },
                                activeColor: KgitonThemeColors.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Use scale weight',
                                      style: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${widget.currentWeight!.toStringAsFixed(3)} kg',
                                      style: const TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],

                    // Manual quantity input
                    if (_selectedPricingType == PricingType.dualPrice ||
                        _selectedPricingType == PricingType.perPcs ||
                        (!_useScaleWeight || widget.currentWeight == null || widget.currentWeight! <= 0))
                      TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}'))],
                        style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: _selectedPricingType == PricingType.dualPrice || _selectedPricingType == PricingType.perPcs
                              ? 'Enter pieces'
                              : 'Enter weight (kg)',
                          hintStyle: const TextStyle(color: KgitonThemeColors.textSecondary),
                          suffixText: _selectedPricingType == PricingType.dualPrice || _selectedPricingType == PricingType.perPcs ? 'pcs' : 'kg',
                          suffixStyle: const TextStyle(color: KgitonThemeColors.primaryGreen, fontWeight: FontWeight.w600),
                          filled: true,
                          fillColor: KgitonThemeColors.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: KgitonThemeColors.borderDefault),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: KgitonThemeColors.borderDefault),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: KgitonThemeColors.primaryGreen, width: 2),
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 24),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectedItem == null ? null : _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KgitonThemeColors.primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: KgitonThemeColors.textDisabled,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

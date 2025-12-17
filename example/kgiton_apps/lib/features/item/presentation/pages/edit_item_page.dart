import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../domain/entities/item.dart';
import '../bloc/item_bloc.dart';

/// Pricing type for item
enum PricingType {
  perKg('Per Kilogram (kg)', 'kg'),
  perPcs('Per Piece (pcs)', 'pcs'),
  dual('Dual Pricing (kg & pcs)', 'kg-pcs');

  final String label;
  final String unit;
  const PricingType(this.label, this.unit);
}

/// Page to edit an existing item
class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _pricePerPcsController;
  late TextEditingController _descriptionController;
  late PricingType _selectedPricingType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description ?? '');

    // Number formatter for displaying prices
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

    // Determine pricing type from existing item
    if (widget.item.unit == 'kg' || (widget.item.price > 0 && (widget.item.pricePerPcs == null || widget.item.pricePerPcs == 0))) {
      _selectedPricingType = PricingType.perKg;
      _priceController = TextEditingController(text: currencyFormatter.format(widget.item.price).trim());
      _pricePerPcsController = TextEditingController();
    } else if (widget.item.unit == 'pcs' || ((widget.item.price == 0) && (widget.item.pricePerPcs != null && widget.item.pricePerPcs! > 0))) {
      _selectedPricingType = PricingType.perPcs;
      _priceController = TextEditingController();
      _pricePerPcsController = TextEditingController(text: currencyFormatter.format(widget.item.pricePerPcs ?? 0).trim());
    } else {
      _selectedPricingType = PricingType.dual;
      _priceController = TextEditingController(text: currencyFormatter.format(widget.item.price).trim());
      _pricePerPcsController = TextEditingController(text: currencyFormatter.format(widget.item.pricePerPcs ?? 0).trim());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pricePerPcsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      double price = 0;
      double? pricePerPcs;

      // Set prices based on pricing type (extract numeric values from formatted text)
      switch (_selectedPricingType) {
        case PricingType.perKg:
          price = CurrencyInputFormatter.getNumericValue(_priceController.text);
          pricePerPcs = 0;
          break;
        case PricingType.perPcs:
          price = 0;
          pricePerPcs = CurrencyInputFormatter.getNumericValue(_pricePerPcsController.text);
          break;
        case PricingType.dual:
          price = CurrencyInputFormatter.getNumericValue(_priceController.text);
          pricePerPcs = CurrencyInputFormatter.getNumericValue(_pricePerPcsController.text);
          break;
      }

      context.read<ItemBloc>().add(
        UpdateItemEvent(
          itemId: widget.item.id,
          name: _nameController.text.trim(),
          unit: _selectedPricingType.unit,
          price: price,
          pricePerPcs: pricePerPcs,
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Text('Edit Item', style: TextStyle(color: KgitonThemeColors.textPrimary)),
        iconTheme: const IconThemeData(color: KgitonThemeColors.textPrimary),
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemUpdated) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Item updated successfully'), backgroundColor: KgitonThemeColors.successGreen));
            if (context.mounted) {
              context.pop(true); // Return true to indicate success
            }
          } else if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: KgitonThemeColors.errorRed));
          }
        },
        builder: (context, state) {
          final isLoading = state is ItemLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Item Name',
                      hint: 'e.g., Apple, Banana',
                      enabled: !isLoading,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pricing Type Selection
                    Text(
                      'Pricing Type',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: KgitonThemeColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KgitonThemeColors.borderDefault),
                      ),
                      child: Column(
                        children: PricingType.values.map((type) {
                          final isSelected = _selectedPricingType == type;
                          return ListTile(
                            title: Text(type.label, style: const TextStyle(color: KgitonThemeColors.textPrimary)),
                            subtitle: Text('Unit: ${type.unit}', style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12)),
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? KgitonThemeColors.primaryGreen : KgitonThemeColors.textSecondary, width: 2),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: KgitonThemeColors.primaryGreen),
                                      ),
                                    )
                                  : null,
                            ),
                            onTap: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _selectedPricingType = type;
                                      if (type == PricingType.perKg) {
                                        _pricePerPcsController.clear();
                                      } else if (type == PricingType.perPcs) {
                                        _priceController.clear();
                                      }
                                    });
                                  },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Price Per Kg (shown for perKg and dual)
                    if (_selectedPricingType == PricingType.perKg || _selectedPricingType == PricingType.dual) ...[
                      CustomTextField(
                        controller: _priceController,
                        label: 'Price Per Kilogram (Rp)',
                        hint: 'e.g., 15.000',
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price per kg';
                          }
                          final price = CurrencyInputFormatter.getNumericValue(value);
                          if (price <= 0) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Price Per Pcs (shown for perPcs and dual)
                    if (_selectedPricingType == PricingType.perPcs || _selectedPricingType == PricingType.dual) ...[
                      CustomTextField(
                        controller: _pricePerPcsController,
                        label: 'Price Per Piece (Rp)',
                        hint: 'e.g., 2.500',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        enabled: !isLoading,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price per pcs';
                          }
                          final price = CurrencyInputFormatter.getNumericValue(value);
                          if (price <= 0) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description (Optional)
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Enter item description',
                      maxLines: 3,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),

                    // Update Button
                    CustomButton(text: 'Update Item', onPressed: isLoading ? null : _handleUpdate, isLoading: isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

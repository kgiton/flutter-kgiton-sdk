import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../domain/entities/item.dart';
import '../bloc/item_bloc.dart';

/// Item page - manage items for weighing
class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadItems();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload items when returning to foreground
      _loadItems();
    }
  }

  void _loadItems() {
    context.read<ItemBloc>().add(const LoadItemsEvent());
  }

  Future<void> _handleRefresh() async {
    context.read<ItemBloc>().add(const LoadItemsEvent());
    // Wait for state to update
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToCreate() async {
    final result = await context.push<bool>('/items/create');
    // Reload items after returning from create page if successful
    if (mounted && result == true) {
      _loadItems();
    }
  }

  void _navigateToEdit(Item item) async {
    final result = await context.push<bool>('/items/${item.id}/edit', extra: item);
    // Reload items after returning from edit page if successful
    if (mounted && result == true) {
      _loadItems();
    }
  }

  void _showDeleteDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: KgitonThemeColors.errorRed),
            SizedBox(width: 12),
            Text('Delete Item', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          ],
        ),
        content: Text(
          'Permanently delete "${item.name}"?\nThe item will be removed from the database.',
          style: const TextStyle(color: KgitonThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ItemBloc>().add(DeleteItemEvent(item.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.errorRed),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    // Get current items count from state
    final state = context.read<ItemBloc>().state;
    final itemCount = state is ItemsLoaded ? state.items.length : 0;

    if (itemCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No items to delete'), backgroundColor: KgitonThemeColors.warningYellow));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: Row(
          children: [
            const Icon(Icons.warning, color: KgitonThemeColors.errorRed),
            const SizedBox(width: 8),
            const Text('Delete All Items?', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently delete ALL $itemCount item(s)!', style: const TextStyle(color: KgitonThemeColors.textSecondary)),
            const SizedBox(height: 12),
            const Text('Are you absolutely sure?', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ItemBloc>().add(const ClearAllItemsEvent());
            },
            style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.errorRed, foregroundColor: Colors.white),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Items'),
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.textPrimary,
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _showClearAllDialog, tooltip: 'Clear All Items'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadItems, tooltip: 'Refresh'),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: KgitonThemeColors.cardBackground,
            child: TextField(
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
          ),
          // Items list
          Expanded(
            child: BlocConsumer<ItemBloc, ItemState>(
              listener: (context, state) {
                if (state is ItemError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: KgitonThemeColors.errorRed));
                } else if (state is ItemDeleted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Item deleted successfully'), backgroundColor: KgitonThemeColors.successGreen));
                  _loadItems();
                } else if (state is ItemsCleared) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${state.count} item(s) deleted successfully'), backgroundColor: KgitonThemeColors.successGreen),
                  );
                  _loadItems();
                }
              },
              builder: (context, state) {
                if (state is ItemLoading) {
                  return const Center(child: CircularProgressIndicator(color: KgitonThemeColors.primaryGreen));
                }

                if (state is ItemsLoaded) {
                  // Filter items based on search query
                  final filteredItems = _searchQuery.isEmpty
                      ? state.items
                      : state.items.where((item) {
                          return item.name.toLowerCase().contains(_searchQuery) ||
                              (item.description?.toLowerCase().contains(_searchQuery) ?? false) ||
                              item.unit.toLowerCase().contains(_searchQuery);
                        }).toList();

                  if (filteredItems.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: KgitonThemeColors.primaryGreen,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
                                  size: 80,
                                  color: KgitonThemeColors.textDisabled,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ? 'No items found' : 'No items yet',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty ? 'Try different keywords' : 'Tap + to add your first item',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textDisabled),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: KgitonThemeColors.primaryGreen,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _ItemCard(item: item, onTap: () => _navigateToEdit(item), onDelete: () => _showDeleteDialog(context, item));
                      },
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: KgitonThemeColors.primaryGreen,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 80, color: KgitonThemeColors.textDisabled),
                            const SizedBox(height: 16),
                            Text(
                              'Load items to get started',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: KgitonThemeColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        backgroundColor: KgitonThemeColors.primaryGreen,
        foregroundColor: KgitonThemeColors.backgroundDark,
        icon: const Icon(Icons.add),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ItemCard({required this.item, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Determine pricing type based on unit and prices
    final bool isPerKg = item.unit == 'kg' || (item.price > 0 && (item.pricePerPcs == null || item.pricePerPcs == 0));
    final bool isPerPcs = item.unit == 'pcs' || (item.price == 0 && item.pricePerPcs != null && item.pricePerPcs! > 0);
    final bool isDual = item.unit == 'kg-pcs' || (item.price > 0 && item.pricePerPcs != null && item.pricePerPcs! > 0);

    // Currency formatter
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      color: KgitonThemeColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    // Display price based on pricing type
                    if (isPerKg) ...[
                      Text(
                        '${currencyFormatter.format(item.price)} / kg',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.primaryGreen),
                      ),
                    ] else if (isPerPcs) ...[
                      Text(
                        '${currencyFormatter.format(item.pricePerPcs!)} / pcs',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.primaryGreen),
                      ),
                    ] else if (isDual) ...[
                      Text(
                        '${currencyFormatter.format(item.price)} / kg',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.primaryGreen),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currencyFormatter.format(item.pricePerPcs!)} / pcs',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.primaryGreen),
                      ),
                    ],
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          // Show full description in dialog when tapped
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: KgitonThemeColors.cardBackground,
                              title: Text(item.name, style: const TextStyle(color: KgitonThemeColors.textPrimary)),
                              content: SingleChildScrollView(
                                child: Text(item.description!, style: const TextStyle(color: KgitonThemeColors.textSecondary)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close', style: TextStyle(color: KgitonThemeColors.primaryGreen)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          item.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textDisabled),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: KgitonThemeColors.textSecondary),
                color: KgitonThemeColors.cardBackground,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: KgitonThemeColors.primaryGreen, size: 20),
                        SizedBox(width: 12),
                        Text('Edit', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: KgitonThemeColors.errorRed, size: 20),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: KgitonThemeColors.errorRed)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onTap();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

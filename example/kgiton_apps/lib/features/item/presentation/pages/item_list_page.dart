import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../domain/entities/item.dart';
import '../bloc/item_bloc.dart';

/// Page to display list of items
class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    context.read<ItemBloc>().add(const LoadItemsEvent());
  }

  void _showDeleteDialog(BuildContext context, Item item, {bool permanent = false}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: Text(permanent ? 'Permanent Delete' : 'Delete Item', style: const TextStyle(color: KgitonThemeColors.textPrimary)),
        content: Text(
          permanent ? 'Permanently delete "${item.name}"? This action cannot be undone!' : 'Delete "${item.name}"? (Can be restored later)',
          style: const TextStyle(color: KgitonThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (permanent) {
                context.read<ItemBloc>().add(DeleteItemPermanentEvent(item.id));
              } else {
                context.read<ItemBloc>().add(DeleteItemEvent(item.id));
              }
            },
            child: Text('Delete', style: TextStyle(color: permanent ? KgitonThemeColors.errorRed : KgitonThemeColors.primaryGreen)),
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
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Text('Items', style: TextStyle(color: KgitonThemeColors.textPrimary)),
        iconTheme: const IconThemeData(color: KgitonThemeColors.textPrimary),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadItems)],
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: KgitonThemeColors.errorRed));
          } else if (state is ItemDeleted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Item deleted successfully'), backgroundColor: KgitonThemeColors.successGreen));
            _loadItems();
          }
        },
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(child: CircularProgressIndicator(color: KgitonThemeColors.primaryGreen));
          }

          if (state is ItemsLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 80, color: KgitonThemeColors.textDisabled),
                    const SizedBox(height: 16),
                    Text('No items yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first item',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textDisabled),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _ItemCard(
                  item: item,
                  onTap: () {
                    context.push('/items/${item.id}/edit', extra: item);
                  },
                  onDelete: () => _showDeleteDialog(context, item),
                  onDeletePermanent: () => _showDeleteDialog(context, item, permanent: true),
                );
              },
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 80, color: KgitonThemeColors.textDisabled),
                const SizedBox(height: 16),
                Text('Load items to get started', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: KgitonThemeColors.textSecondary)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/items/create');
        },
        backgroundColor: KgitonThemeColors.primaryGreen,
        child: const Icon(Icons.add, color: KgitonThemeColors.backgroundDark),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDeletePermanent;

  const _ItemCard({required this.item, required this.onTap, required this.onDelete, required this.onDeletePermanent});

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'Rp ${item.price.toStringAsFixed(0)} / ${item.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.primaryGreen),
                    ),
                    if (item.pricePerPcs != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${item.pricePerPcs!.toStringAsFixed(0)} / pcs',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textSecondary),
                      ),
                    ],
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textDisabled),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                        Icon(Icons.delete_outline, color: KgitonThemeColors.warningYellow, size: 20),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: KgitonThemeColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_permanent',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: KgitonThemeColors.errorRed, size: 20),
                        SizedBox(width: 12),
                        Text('Delete Permanent', style: TextStyle(color: KgitonThemeColors.errorRed)),
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
                    case 'delete_permanent':
                      onDeletePermanent();
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

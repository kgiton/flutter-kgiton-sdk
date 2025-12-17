import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

/// Transaction page - view transaction history
class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Load transactions on init
    context.read<TransactionBloc>().add(const LoadTransactionsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    switch (_tabController.index) {
      case 0:
        context.read<TransactionBloc>().add(const LoadTransactionsEvent());
        break;
      case 1:
        context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.paid));
        break;
      case 2:
        context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.pending));
        break;
      case 3:
        context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.expired));
        break;
      case 4:
        context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.cancelled));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: KgitonThemeColors.primaryGreen,
          unselectedLabelColor: KgitonThemeColors.textSecondary,
          indicatorColor: KgitonThemeColors.primaryGreen,
          tabAlignment: TabAlignment.start,
          onTap: (index) {
            // Load transactions based on tab
            switch (index) {
              case 0:
                context.read<TransactionBloc>().add(const LoadTransactionsEvent());
                break;
              case 1:
                context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.paid));
                break;
              case 2:
                context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.pending));
                break;
              case 3:
                context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.expired));
                break;
              case 4:
                context.read<TransactionBloc>().add(const LoadTransactionsByStatusEvent(PaymentStatus.cancelled));
                break;
            }
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Paid'),
            Tab(text: 'Pending'),
            Tab(text: 'Expired'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator(color: KgitonThemeColors.primaryGreen));
          }

          if (state is TransactionError) {
            return RefreshIndicator(onRefresh: _onRefresh, color: KgitonThemeColors.primaryGreen, child: _buildErrorState(state.message));
          }

          if (state is TransactionLoaded) {
            if (state.isEmpty) {
              return RefreshIndicator(onRefresh: _onRefresh, color: KgitonThemeColors.primaryGreen, child: _buildEmptyState());
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: KgitonThemeColors.primaryGreen,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = state.transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
            );
          }

          return RefreshIndicator(onRefresh: _onRefresh, color: KgitonThemeColors.primaryGreen, child: _buildEmptyState());
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final statusColor = _getStatusColor(transaction.paymentStatus);

    return Card(
      color: KgitonThemeColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to transaction detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction.transactionNumber,
                      style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      transaction.paymentStatus,
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(dateFormat.format(transaction.createdAt), style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12)),
              Divider(height: 24, color: KgitonThemeColors.textSecondary.withValues(alpha: 0.3)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method', style: TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        transaction.paymentMethod,
                        style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat('#,###').format(transaction.totalAmount)}',
                        style: const TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return KgitonThemeColors.successGreen;
      case 'PENDING':
        return KgitonThemeColors.warningYellow;
      case 'EXPIRED':
        return KgitonThemeColors.expiredOrange;
      case 'CANCELLED':
        return KgitonThemeColors.errorRed;
      default:
        return KgitonThemeColors.textSecondary;
    }
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 100, color: KgitonThemeColors.textSecondary.withValues(alpha: 0.5)),
                const SizedBox(height: 24),
                Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete checkout to create transactions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Text('Pull down to refresh', style: TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 100, color: KgitonThemeColors.errorRed.withValues(alpha: 0.5)),
                const SizedBox(height: 24),
                Text(
                  'Error Loading Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pull down to retry', style: TextStyle(color: KgitonThemeColors.primaryGreen, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

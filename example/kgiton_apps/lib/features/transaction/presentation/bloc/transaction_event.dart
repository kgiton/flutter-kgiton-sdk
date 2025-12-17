import 'package:equatable/equatable.dart';

/// Base transaction event
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Load all transactions
class LoadTransactionsEvent extends TransactionEvent {
  final int? limit;
  final int? offset;

  const LoadTransactionsEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

/// Load transactions by status
class LoadTransactionsByStatusEvent extends TransactionEvent {
  final String status;
  final int? limit;
  final int? offset;

  const LoadTransactionsByStatusEvent(this.status, {this.limit, this.offset});

  @override
  List<Object?> get props => [status, limit, offset];
}

/// Refresh transactions
class RefreshTransactionsEvent extends TransactionEvent {
  const RefreshTransactionsEvent();
}

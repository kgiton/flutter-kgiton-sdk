import 'package:equatable/equatable.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

/// Base transaction state
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TransactionInitial extends TransactionState {}

/// Loading state
class TransactionLoading extends TransactionState {}

/// Loaded state
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final bool isEmpty;

  TransactionLoaded({required this.transactions}) : isEmpty = transactions.isEmpty;

  @override
  List<Object?> get props => [transactions];
}

/// Error state
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_transactions_by_status.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// BLoC for managing transaction state
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final GetTransactionsByStatus getTransactionsByStatus;

  TransactionBloc({required this.getTransactions, required this.getTransactionsByStatus}) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadTransactionsByStatusEvent>(_onLoadTransactionsByStatus);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
  }

  Future<void> _onLoadTransactions(LoadTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());

    final result = await getTransactions(limit: event.limit, offset: event.offset);

    result.fold((failure) => emit(TransactionError(failure.toString())), (transactions) => emit(TransactionLoaded(transactions: transactions)));
  }

  Future<void> _onLoadTransactionsByStatus(LoadTransactionsByStatusEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());

    final result = await getTransactionsByStatus(event.status, limit: event.limit, offset: event.offset);

    result.fold((failure) => emit(TransactionError(failure.toString())), (transactions) => emit(TransactionLoaded(transactions: transactions)));
  }

  Future<void> _onRefreshTransactions(RefreshTransactionsEvent event, Emitter<TransactionState> emit) async {
    // For refresh, we reload all transactions without showing loading state
    final result = await getTransactions();

    result.fold((failure) => emit(TransactionError(failure.toString())), (transactions) => emit(TransactionLoaded(transactions: transactions)));
  }
}

import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/failures.dart';

/// Repository interface for transaction operations
abstract class TransactionRepository {
  /// Get all transactions
  Future<Either<Failure, List<Transaction>>> getTransactions({int? limit, int? offset});

  /// Get transaction by ID
  Future<Either<Failure, Transaction>> getTransactionById(String transactionId);

  /// Get transactions by status
  Future<Either<Failure, List<Transaction>>> getTransactionsByStatus(String status, {int? limit, int? offset});
}

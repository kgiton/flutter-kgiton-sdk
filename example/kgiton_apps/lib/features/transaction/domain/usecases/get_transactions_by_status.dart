import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

/// Use case for getting transactions by status
class GetTransactionsByStatus {
  final TransactionRepository repository;

  GetTransactionsByStatus(this.repository);

  Future<Either<Failure, List<Transaction>>> call(String status, {int? limit, int? offset}) async {
    return await repository.getTransactionsByStatus(status, limit: limit, offset: offset);
  }
}

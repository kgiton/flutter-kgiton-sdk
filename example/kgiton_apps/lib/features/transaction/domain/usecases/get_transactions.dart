import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

/// Use case for getting all transactions
class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<Transaction>>> call({int? limit, int? offset}) async {
    return await repository.getTransactions(limit: limit, offset: offset);
  }
}

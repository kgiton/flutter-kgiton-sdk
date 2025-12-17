import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';

/// Implementation of transaction repository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({int? limit, int? offset}) async {
    try {
      final transactions = await remoteDataSource.getTransactions(limit: limit, offset: offset);
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String transactionId) async {
    try {
      final transaction = await remoteDataSource.getTransactionById(transactionId);
      return Right(transaction);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByStatus(String status, {int? limit, int? offset}) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByStatus(status, limit: limit, offset: offset);
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

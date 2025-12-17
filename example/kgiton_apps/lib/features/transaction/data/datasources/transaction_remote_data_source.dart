import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for transaction operations using KGiTON SDK
abstract class TransactionRemoteDataSource {
  /// Get all transactions
  Future<List<Transaction>> getTransactions({int? limit, int? offset});

  /// Get transaction by ID
  Future<Transaction> getTransactionById(String transactionId);

  /// Get transactions by status
  Future<List<Transaction>> getTransactionsByStatus(String status, {int? limit, int? offset});
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final KgitonApiService apiService;

  TransactionRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<Transaction>> getTransactions({int? limit, int? offset}) async {
    try {
      // SDK uses transaction.listTransactions() to get all user's transactions
      final response = await apiService.transaction.listTransactions(page: (offset ?? 0) ~/ (limit ?? 20) + 1, limit: limit ?? 20);
      return response.transactions;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Transaction> getTransactionById(String transactionId) async {
    try {
      final response = await apiService.transaction.getTransactionById(transactionId);
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByStatus(String status, {int? limit, int? offset}) async {
    try {
      // SDK supports filtering by status
      // API expects lowercase status values: 'paid', 'pending', 'expired', 'cancelled', 'refunded'
      final lowercaseStatus = status.toLowerCase();
      final response = await apiService.transaction.listTransactions(
        page: (offset ?? 0) ~/ (limit ?? 20) + 1,
        limit: limit ?? 20,
        status: lowercaseStatus,
      );
      return response.transactions;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

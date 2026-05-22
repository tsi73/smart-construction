import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

abstract class BudgetRemoteDataSource {
  Future<Map<String, dynamic>> getBudgetSummary(String projectId);
  Future<List<Map<String, dynamic>>> getBudgetItems(String projectId);
  Future<Map<String, dynamic>> addBudgetItem(
      String projectId, double amount, String? description);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final Dio _dio;

  BudgetRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getBudgetSummary(String projectId) async {
    final response = await _dio.get('/projects/$projectId/budget');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getBudgetItems(String projectId) async {
    final response = await _dio.get('/projects/$projectId/budget-items');
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> addBudgetItem(
      String projectId, double amount, String? description) async {
    final response = await _dio.post(
      '/projects/$projectId/budget-items',
      data: {
        'amount': amount,
        if (description != null) 'description': description,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

final budgetRemoteDataSourceProvider = Provider<BudgetRemoteDataSource>((ref) {
  return BudgetRemoteDataSourceImpl(ref.watch(dioProvider));
});

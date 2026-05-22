import 'package:dio/dio.dart';

abstract class ContractorRemoteDataSource {
  Future<List<Map<String, dynamic>>> getContractors(
      {int skip = 0, int limit = 100});
  Future<Map<String, dynamic>> getContractor(String contractorId);
  Future<Map<String, dynamic>> createContractor(String name);
  Future<Map<String, dynamic>> updateContractor(
      String contractorId, String? name);
  Future<void> deleteContractor(String contractorId);
}

class ContractorRemoteDataSourceImpl implements ContractorRemoteDataSource {
  final Dio _dio;

  ContractorRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getContractors({
    int skip = 0,
    int limit = 100,
  }) async {
    final response = await _dio.get(
      '/contractors',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> getContractor(String contractorId) async {
    final response = await _dio.get('/contractors/$contractorId');
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> createContractor(String name) async {
    final response = await _dio.post(
      '/contractors',
      data: {'name': name},
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateContractor(
    String contractorId,
    String? name,
  ) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    final response = await _dio.put(
      '/contractors/$contractorId',
      data: data,
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> deleteContractor(String contractorId) async {
    await _dio.delete('/contractors/$contractorId');
  }
}

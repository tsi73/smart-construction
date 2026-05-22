import 'package:dio/dio.dart';
import '../../domain/entities/daily_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
// ignore_for_file: avoid_print

abstract class DailyLogRemoteDataSource {
  Future<List<DailyLog>> getProjectLogs(String projectId);
  Future<DailyLog> getDailyLog(String logId);
  Future<DailyLog> createDailyLog(String projectId, Map<String, dynamic> data);
  Future<DailyLog> createTaskDailyLog(
      String projectId, String taskId, Map<String, dynamic> data);
  Future<void> submitDailyLog(String logId);
  Future<void> reviewDailyLog(String logId, bool approved);
  Future<void> consultantApprove(String logId);
  Future<void> pmApprove(String logId);
  Future<void> rejectDailyLog(String logId, String reason);
  Future<Map<String, dynamic>> uploadAttachment(String logId, String filePath);

  // Sub-entities
  Future<void> addLabor(String logId, List<Map<String, dynamic>> labor);
  Future<void> addMaterials(String logId, List<Map<String, dynamic>> materials);
  Future<void> addEquipment(String logId, List<Map<String, dynamic>> equipment);
  Future<void> addShifts(String logId, List<Map<String, dynamic>> shifts);
}

class DailyLogRemoteDataSourceImpl implements DailyLogRemoteDataSource {
  final Dio _dio;

  DailyLogRemoteDataSourceImpl(this._dio);

  @override
  Future<List<DailyLog>> getProjectLogs(String projectId) async {
    print('DEBUG: getProjectLogs - projectId: $projectId');
    final response = await _dio.get('/projects/$projectId/daily-logs');
    print('DEBUG: getProjectLogs - response status: ${response.statusCode}');
    print(
        'DEBUG: getProjectLogs - response data type: ${response.data.runtimeType}');
    print('DEBUG: getProjectLogs - response data: ${response.data}');

    if (response.data is List) {
      final list = response.data as List;
      print('DEBUG: getProjectLogs - number of logs: ${list.length}');
      return list.map((e) => DailyLog.fromJson(e)).toList();
    } else {
      print('DEBUG: getProjectLogs - response is not a list, returning empty');
      return [];
    }
  }

  @override
  Future<DailyLog> getDailyLog(String logId) async {
    final response = await _dio.get('/daily-logs/$logId');
    return DailyLog.fromJson(response.data);
  }

  @override
  Future<DailyLog> createDailyLog(
      String projectId, Map<String, dynamic> data) async {
    final response =
        await _dio.post('/projects/$projectId/daily-logs', data: data);
    return DailyLog.fromJson(response.data);
  }

  @override
  Future<DailyLog> createTaskDailyLog(
      String projectId, String taskId, Map<String, dynamic> data) async {
    final response = await _dio
        .post('/projects/$projectId/tasks/$taskId/daily-logs', data: data);
    return DailyLog.fromJson(response.data);
  }

  @override
  Future<void> submitDailyLog(String logId) async {
    await _dio.patch('/daily-logs/$logId/submit');
  }

  @override
  Future<void> reviewDailyLog(String logId, bool approved) async {
    await _dio.patch('/daily-logs/$logId/review', data: {'approved': approved});
  }

  @override
  Future<void> consultantApprove(String logId) async {
    await _dio.patch('/daily-logs/$logId/consultant-approve');
  }

  @override
  Future<void> pmApprove(String logId) async {
    await _dio.patch('/daily-logs/$logId/pm-approve');
  }

  @override
  Future<void> rejectDailyLog(String logId, String reason) async {
    await _dio
        .patch('/daily-logs/$logId/reject', data: {'rejection_reason': reason});
  }

  @override
  Future<void> addLabor(String logId, List<Map<String, dynamic>> labor) async {
    for (final item in labor) {
      final snakeCaseItem = {
        'worker_type': item['workerType'],
        'hours_worked': item['hoursWorked'],
        'cost': item['cost'],
      };
      await _dio.post('/daily-logs/$logId/labor', data: snakeCaseItem);
    }
  }

  @override
  Future<void> addMaterials(
      String logId, List<Map<String, dynamic>> materials) async {
    for (final item in materials) {
      final snakeCaseItem = {
        'name': item['name'],
        'quantity': item['quantity'],
        'unit': item['unit'],
        'cost': item['cost'],
      };
      await _dio.post('/daily-logs/$logId/materials', data: snakeCaseItem);
    }
  }

  @override
  Future<void> addEquipment(
      String logId, List<Map<String, dynamic>> equipment) async {
    for (final item in equipment) {
      final snakeCaseItem = {
        'name': item['name'],
        'hours_used': item['hoursUsed'],
        'cost': item['cost'],
      };
      await _dio.post('/daily-logs/$logId/equipment', data: snakeCaseItem);
    }
  }

  @override
  Future<void> addShifts(
      String logId, List<Map<String, dynamic>> shifts) async {
    for (final item in shifts) {
      final snakeCaseItem = {
        'shift_type': item['shiftType'],
      };
      await _dio.post('/daily-logs/$logId/shifts', data: snakeCaseItem);
    }
  }

  @override
  Future<Map<String, dynamic>> uploadAttachment(
      String logId, String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response =
        await _dio.post('/daily-logs/$logId/attachments', data: formData);
    return response.data;
  }
}

final dailyLogRemoteDataSourceProvider =
    Provider<DailyLogRemoteDataSource>((ref) {
  return DailyLogRemoteDataSourceImpl(ref.watch(dioProvider));
});

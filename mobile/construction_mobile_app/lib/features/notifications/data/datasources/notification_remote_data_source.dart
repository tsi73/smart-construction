import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/databases/api/end_points.dart';

abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMessages();
  Future<void> markAsRead(String messageId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getMessages() async {
    final response = await _dio.get(EndPoints.messages);
    if (response.data is List) {
      return (response.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  @override
  Future<void> markAsRead(String messageId) async {
    await _dio.patch(EndPoints.markMessageRead(messageId));
  }
}

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSourceImpl(ref.watch(dioProvider));
});

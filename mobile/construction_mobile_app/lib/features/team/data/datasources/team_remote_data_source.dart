import 'package:dio/dio.dart';

abstract class TeamRemoteDataSource {
  Future<List<Map<String, dynamic>>> getProjectMembers(String projectId);
  Future<List<Map<String, dynamic>>> getProjectInvitations(String projectId);
  Future<Map<String, dynamic>> inviteMember(
      String projectId, String email, String role);
  Future<Map<String, dynamic>> updateMemberRole(
      String projectId, String userId, String role);
  Future<void> removeMember(String projectId, String userId);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final Dio _dio;

  TeamRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getProjectMembers(String projectId) async {
    final response = await _dio.get('/projects/$projectId/members');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getProjectInvitations(
      String projectId) async {
    final response = await _dio.get('/projects/$projectId/invitations');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> inviteMember(
      String projectId, String email, String role) async {
    final response = await _dio.post('/projects/$projectId/invitations', data: {
      'email': email,
      'role': role,
    });
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> updateMemberRole(
      String projectId, String userId, String role) async {
    final response =
        await _dio.patch('/projects/$projectId/members/$userId', data: {
      'role': role,
    });
    return response.data;
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {
    await _dio.delete('/projects/$projectId/members/$userId');
  }
}

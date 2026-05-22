import 'package:dio/dio.dart';

abstract class ProjectRemoteDataSource {
  Future<List<dynamic>> getProjects();
  Future<Map<String, dynamic>> getProjectById(String id);
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> projectData);
  Future<List<dynamic>> getProjectMembers(String projectId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final Dio _dio;

  ProjectRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> getProjects() async {
    final response = await _dio.get('/projects');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getProjectById(String id) async {
    final response = await _dio.get('/projects/$id');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> createProject(
      Map<String, dynamic> projectData) async {
    final response = await _dio.post('/projects', data: projectData);
    return response.data;
  }

  @override
  Future<List<dynamic>> getProjectMembers(String projectId) async {
    final response = await _dio.get('/projects/$projectId/members');
    return response.data;
  }
}

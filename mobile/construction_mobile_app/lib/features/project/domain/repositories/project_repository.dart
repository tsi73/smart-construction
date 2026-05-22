import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getProjects();
  Future<Either<Failure, Map<String, dynamic>>> getProjectById(String id);
  Future<Either<Failure, Map<String, dynamic>>> createProject(
      Map<String, dynamic> projectData);
  Future<Either<Failure, List<Map<String, dynamic>>>> getProjectMembers(
      String projectId);
}

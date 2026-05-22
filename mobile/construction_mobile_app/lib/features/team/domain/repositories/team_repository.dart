import 'package:dartz/dartz.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/features/team/domain/entities/project_member.dart';

abstract class TeamRepository {
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(
      String projectId);
  Future<Either<Failure, List<ProjectInvitation>>> getProjectInvitations(
      String projectId);
  Future<Either<Failure, ProjectInvitation>> inviteMember(
      String projectId, String email, String role);
  Future<Either<Failure, ProjectMember>> updateMemberRole(
      String projectId, String userId, String role);
  Future<Either<Failure, void>> removeMember(String projectId, String userId);
}

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/core/network/dio_client.dart';
import 'package:construction_mobile_app/core/utils/auth_error_messages.dart';
import 'package:construction_mobile_app/features/team/domain/repositories/team_repository.dart';
import 'package:construction_mobile_app/features/team/data/datasources/team_remote_data_source.dart';
import 'package:construction_mobile_app/features/team/domain/entities/project_member.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource _dataSource;

  TeamRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(
      String projectId) async {
    try {
      final membersRaw = await _dataSource.getProjectMembers(projectId);
      final members = membersRaw.map((m) {
        final user = m['user'] as Map<String, dynamic>? ?? {};
        return ProjectMember(
          id: m['id']?.toString() ?? '',
          projectId: m['project_id']?.toString() ?? '',
          userId: m['user_id']?.toString() ?? '',
          fullName: user['full_name']?.toString() ?? 'Unknown',
          email: user['email']?.toString() ?? '',
          phoneNumber: user['phone_number']?.toString(),
          role: m['role']?.toString() ?? 'site_engineer',
        );
      }).toList();
      return Right(members);
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'team');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<ProjectInvitation>>> getProjectInvitations(
      String projectId) async {
    try {
      final invitesRaw = await _dataSource.getProjectInvitations(projectId);
      final invites = invitesRaw
          .map((m) => ProjectInvitation(
                id: m['id']?.toString() ?? '',
                projectId: m['project_id']?.toString() ?? '',
                email: m['email']?.toString() ?? '',
                role: m['role']?.toString() ?? 'site_engineer',
                token: m['token']?.toString() ?? '',
                status: m['status']?.toString() ?? 'pending',
              ))
          .toList();
      return Right(invites);
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'team');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, ProjectInvitation>> inviteMember(
      String projectId, String email, String role) async {
    try {
      final m = await _dataSource.inviteMember(projectId, email, role);
      return Right(ProjectInvitation(
        id: m['id']?.toString() ?? '',
        projectId: m['project_id']?.toString() ?? '',
        email: m['email']?.toString() ?? '',
        role: m['role']?.toString() ?? 'site_engineer',
        token: m['token']?.toString() ?? '',
        status: m['status']?.toString() ?? 'pending',
      ));
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'team');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, ProjectMember>> updateMemberRole(
      String projectId, String userId, String role) async {
    try {
      final m = await _dataSource.updateMemberRole(projectId, userId, role);
      final user = m['user'] as Map<String, dynamic>? ?? {};
      return Right(ProjectMember(
        id: m['id']?.toString() ?? '',
        projectId: m['project_id']?.toString() ?? '',
        userId: m['user_id']?.toString() ?? '',
        fullName: user['full_name']?.toString() ?? 'Unknown',
        email: user['email']?.toString() ?? '',
        phoneNumber: user['phone_number']?.toString(),
        role: m['role']?.toString() ?? 'site_engineer',
      ));
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'team');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(
      String projectId, String userId) async {
    try {
      await _dataSource.removeMember(projectId, userId);
      return const Right(null);
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'team');
      return Left(ServerFailure(errorMessage));
    }
  }
}

final teamRemoteDataSourceProvider = Provider<TeamRemoteDataSource>((ref) {
  return TeamRemoteDataSourceImpl(ref.watch(dioProvider));
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(ref.watch(teamRemoteDataSourceProvider));
});

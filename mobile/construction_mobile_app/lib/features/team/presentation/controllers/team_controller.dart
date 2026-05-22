import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/features/team/data/repositories/team_repository_impl.dart';
import 'package:construction_mobile_app/features/team/domain/repositories/team_repository.dart';
import 'package:construction_mobile_app/features/team/domain/entities/project_member.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:construction_mobile_app/core/notifications/notification_service.dart';

class TeamState {
  final bool isLoading;
  final List<ProjectMember> members;
  final List<ProjectInvitation> invitations;
  final String? error;

  TeamState({
    this.isLoading = false,
    this.members = const [],
    this.invitations = const [],
    this.error,
  });

  TeamState copyWith({
    bool? isLoading,
    List<ProjectMember>? members,
    List<ProjectInvitation>? invitations,
    String? error,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      members: members ?? this.members,
      invitations: invitations ?? this.invitations,
      error: error,
    );
  }
}

class TeamController extends StateNotifier<TeamState> {
  final TeamRepository _repository;
  final String _projectId;
  final Ref _ref;

  TeamController(this._repository, this._projectId, this._ref)
      : super(TeamState()) {
    loadTeam();
  }

  Future<void> loadTeam() async {
    state = state.copyWith(isLoading: true, error: null);

    final membersResult = await _repository.getProjectMembers(_projectId);
    final invitationsResult =
        await _repository.getProjectInvitations(_projectId);

    membersResult.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (members) {
        invitationsResult.fold(
          (failure) {
            if (failure is AuthFailure) {
              _ref.read(authProvider.notifier).handleSessionExpired();
            }
            state = state.copyWith(
                isLoading: false, members: members, error: failure.message);
          },
          (invitations) => state = state.copyWith(
              isLoading: false, members: members, invitations: invitations),
        );
      },
    );
  }

  Future<bool> inviteMember(String email, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.inviteMember(_projectId, email, role);
    return result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (invitation) {
        _ref.read(notificationServiceProvider.notifier).addLocal(
              type: NotificationType.invitationReceived,
              title: 'Invitation Received',
              message: 'You have a pending project invitation',
              projectId: _projectId,
            );
        loadTeam(); // Refresh
        return true;
      },
    );
  }

  Future<bool> updateMemberRole(String userId, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.updateMemberRole(_projectId, userId, role);
    return result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (member) {
        _ref.read(notificationServiceProvider.notifier).addLocal(
              type: NotificationType.memberAdded,
              title: 'Member Added',
              message: 'You have been added to project',
              projectId: _projectId,
            );
        loadTeam(); // Refresh
        return true;
      },
    );
  }

  Future<bool> removeMember(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.removeMember(_projectId, userId);
    return result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadTeam(); // Refresh
        return true;
      },
    );
  }
}

final teamControllerProvider =
    StateNotifierProvider.family<TeamController, TeamState, String>(
        (ref, projectId) {
  return TeamController(ref.watch(teamRepositoryProvider), projectId, ref);
});

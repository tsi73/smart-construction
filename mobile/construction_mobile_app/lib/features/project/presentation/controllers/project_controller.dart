import 'package:construction_mobile_app/core/storage/secure_token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';

class ProjectState {
  final bool isLoading;
  final String? error;

  ProjectState({this.isLoading = false, this.error});

  ProjectState copyWith({bool? isLoading, String? error}) {
    return ProjectState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProjectController extends StateNotifier<ProjectState> {
  final Ref _ref;

  ProjectController(this._ref) : super(ProjectState());

  Future<Map<String, dynamic>?> createProject({
    required String name,
    required double totalBudget,
    required String clientName,
    required String clientEmail,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = _ref.read(projectRepositoryProvider);

    final projectData = {
      'name': name,
      'total_budget': totalBudget,
      'client_name': clientName,
      'client_email': clientEmail,
      'description': description,
      'location': location,
      'planned_start_date': startDate?.toIso8601String(),
      'planned_end_date': endDate?.toIso8601String(),
      'status': 'planning',
    };

    final result = await repository.createProject(projectData);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (project) {
        if (kDebugMode) {
          debugPrint(
              'ProjectController: Created project: ${project['id']} - ${project['name']}');
          _ref.read(secureTokenStorageProvider).getAccessToken().then((token) {
            debugPrint(
                'ProjectController: Access token available after creation: ${token != null}');
          });
        }
        state = state.copyWith(isLoading: false);
        // Refresh project list
        _ref.invalidate(projectsProvider);

        return project;
      },
    );
  }
}

final projectControllerProvider =
    StateNotifierProvider<ProjectController, ProjectState>((ref) {
  return ProjectController(ref);
});

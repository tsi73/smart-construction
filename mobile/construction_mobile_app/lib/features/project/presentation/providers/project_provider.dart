import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_mobile_app/core/network/dio_client.dart';
import 'package:construction_mobile_app/core/network/network_info.dart';
import 'package:construction_mobile_app/features/project/data/datasources/project_local_data_source.dart';

import 'package:construction_mobile_app/features/project/data/datasources/project_remote_data_source.dart';
import 'package:construction_mobile_app/features/project/data/repositories/project_repository_impl.dart';
import 'package:construction_mobile_app/features/project/domain/repositories/project_repository.dart';
import 'package:construction_mobile_app/core/storage/secure_token_storage.dart';
import 'package:construction_mobile_app/features/auth/presentation/providers/auth_provider.dart';

final projectRemoteDataSourceProvider =
    Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSourceImpl(ref.watch(dioProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    ref.watch(projectRemoteDataSourceProvider),
    ref.watch(projectLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final projectsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (kDebugMode) {
    debugPrint('projectsProvider: Triggered fetch');
  }
  final authState = ref.watch(authProvider);

  // Distinguish between definitively unauthenticated and transitional states
  if (authState.status == AuthStatus.unauthenticated ||
      authState.status == AuthStatus.error) {
    if (kDebugMode) {
      debugPrint(
          'projectsProvider: Definitively NOT authenticated (${authState.status}), returning empty list');
    }
    return [];
  }

  // If initial or loading, we might be in the middle of checkStatus() or getUserMe()
  // We should wait if possible, but for a FutureProvider, we can just proceed if we have tokens,
  // or return empty if we are sure.
  if (authState.status == AuthStatus.initial ||
      authState.status == AuthStatus.loading) {
    if (kDebugMode) {
      debugPrint(
          'projectsProvider: Auth state is ${authState.status}, checking for tokens...');
    }
    final storage = ref.read(secureTokenStorageProvider);
    final token = await storage.getAccessToken();
    if (token == null) {
      if (kDebugMode) {
        debugPrint(
            'projectsProvider: No token found during ${authState.status}, returning empty list');
      }
      return [];
    }
    if (kDebugMode) {
      debugPrint(
          'projectsProvider: Token found during ${authState.status}, proceeding with fetch');
    }
  }

  final repository = ref.watch(projectRepositoryProvider);
  final result = await repository.getProjects();

  return result.fold(
    (failure) {
      if (kDebugMode) {
        debugPrint('projectsProvider: Fetch failed: ${failure.message}');
      }
      throw failure.message;
    },
    (projects) async {
      if (kDebugMode) {
        debugPrint(
            'projectsProvider: Successfully fetched ${projects.length} projects');
      }

      // Fetch membership information for projects where user is not owner
      final user = authState.user;
      if (user != null && user['id'] != null) {
        final currentUserId = user['id'].toString();

        // Fetch members for projects where user is not owner
        final projectsWithMembership = await Future.wait(
          projects.map((project) async {
            final ownerId = project['owner_id']?.toString();
            if (ownerId == currentUserId) {
              // User is owner, no need to fetch members
              return project;
            }

            // Fetch members to check if user is a member
            try {
              final membersResult = await repository.getProjectMembers(project['id'].toString());
              return membersResult.fold(
                (failure) {
                  if (kDebugMode) {
                    debugPrint('projectsProvider: Failed to fetch members for ${project['name']}: ${failure.message}');
                  }
                  return project;
                },
                (members) {
                  final isMember = members.any((m) => m['user_id']?.toString() == currentUserId);
                  if (isMember) {
                    // Add role information to project
                    final member = members.firstWhere((m) => m['user_id']?.toString() == currentUserId);
                    project['role'] = member['role'];
                    if (kDebugMode) {
                      debugPrint('projectsProvider: User is member of ${project['name']} with role ${member['role']}');
                    }
                  }
                  return project;
                },
              );
            } catch (e) {
              if (kDebugMode) {
                debugPrint('projectsProvider: Error fetching members for ${project['name']}: $e');
              }
              return project;
            }
          }),
        );

        return projectsWithMembership;
      }

      return projects;
    },
  );
});

final currentProjectProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);
final currentProjectRoleProvider = StateProvider<String?>((ref) => null);
final isCurrentProjectOwnerProvider = StateProvider<bool>((ref) => false);

final clientsProvider = Provider<AsyncValue<List<Map<String, String>>>>((ref) {
  final projectsAsync = ref.watch(projectsProvider);

  return projectsAsync.whenData((projects) {
    final clientsMap = <String, String>{};
    for (final project in projects) {
      // API might return client_name or nested client.name
      final name = project['client_name']?.toString() ??
          project['client']?['name']?.toString();
      final email = project['client_email']?.toString() ??
          project['client']?['email']?.toString();

      if (name != null && name.isNotEmpty) {
        clientsMap[name] = email ?? '';
      }
    }

    final sortedClients = clientsMap.entries
        .map((e) => {'name': e.key, 'email': e.value})
        .toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));

    return sortedClients;
  });
});

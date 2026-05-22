import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/project/presentation/providers/project_provider.dart';

/// Conditionally shows [child] only if the current user's project role
/// is in [allowedRoles]. Otherwise shows [fallback] or SizedBox.shrink().
class RoleGuard extends ConsumerWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentProjectRoleProvider) ?? '';
    // 'owner' should be treated equivalently to 'project_manager' for most guards
    final effectiveRole = role == 'owner' ? 'project_manager' : role;
    if (allowedRoles.contains(role) || allowedRoles.contains(effectiveRole)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

/// Convenience helper: returns true if the current role is in the allowed list.
/// Uses the same owner→project_manager normalization as RoleGuard.
bool isRoleAllowed(WidgetRef ref, List<String> allowedRoles) {
  final role = ref.read(currentProjectRoleProvider) ?? '';
  final effectiveRole = role == 'owner' ? 'project_manager' : role;
  return allowedRoles.contains(role) || allowedRoles.contains(effectiveRole);
}

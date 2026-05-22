import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard/project_dashboard_shell.dart';

class ProjectDashboardPage extends ConsumerWidget {
  const ProjectDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProjectDashboardShell();
  }
}

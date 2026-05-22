import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import '../../features/auth/presentation/screens/splash_page.dart';
import '../../features/auth/presentation/screens/login_page.dart';
import '../../features/auth/presentation/screens/register_page.dart';
import '../../features/auth/presentation/screens/forgot_password_page.dart';
import '../../features/auth/presentation/screens/reset_password_page.dart';
import '../../features/project/presentation/screens/project_list_page.dart';
import '../../features/project/presentation/screens/project_dashboard_page.dart';
import '../../features/project/presentation/screens/project_creation_page.dart';
import '../../features/project/presentation/screens/contractor_creation_page.dart';
import '../../features/daily_log/presentation/screens/daily_log_list_page.dart';
import '../../features/daily_log/presentation/screens/daily_log_detail_page.dart';
import '../../features/daily_log/presentation/screens/daily_log_wizard_page.dart';
import '../../features/task/presentation/screens/task_list_page.dart';
import '../../features/task/presentation/screens/task_detail_page.dart';
import '../../features/task/presentation/screens/task_creation_page.dart';
import '../../features/settings/presentation/screens/settings_page.dart';
import '../../features/settings/presentation/screens/profile_page.dart';
import '../../features/settings/presentation/screens/sync_queue_page.dart';
import '../../features/team/presentation/screens/team_management_page.dart';
import '../../features/notifications/presentation/screens/notifications_page.dart';
import '../../features/budget/presentation/screens/budget_page.dart';
import '../../features/project/presentation/providers/project_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) => ResetPasswordPage(
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: RouteNames.projects,
        builder: (context, state) => const ProjectListPage(),
      ),
      GoRoute(
        path: '${RouteNames.projects}/new',
        builder: (context, state) => const ProjectCreationPage(),
      ),
      GoRoute(
        path: RouteNames.projectDashboard,
        builder: (context, state) => const ProjectDashboardPage(),
      ),
      GoRoute(
        path: '${RouteNames.projectDashboard}/team',
        builder: (context, state) => const TeamManagementPage(),
      ),
      GoRoute(
        path: RouteNames.contractors,
        builder: (context, state) => const ContractorCreationPage(),
      ),
      GoRoute(
        path: RouteNames.dailyLogs,
        builder: (context, state) {
          final projectId = ref.read(currentProjectProvider)?['id'] ?? '';
          return DailyLogListPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '${RouteNames.dailyLogs}/new',
        builder: (context, state) {
          final projectId = ref.read(currentProjectProvider)?['id'] ?? '';
          final taskId = state.uri.queryParameters['taskId'];
          return DailyLogWizardPage(projectId: projectId, taskId: taskId);
        },
      ),
      GoRoute(
        path: '${RouteNames.dailyLogs}/:logId',
        builder: (context, state) =>
            DailyLogDetailPage(logId: state.pathParameters['logId'] ?? ''),
      ),
      GoRoute(
        path: RouteNames.tasks,
        builder: (context, state) {
          final projectId = ref.read(currentProjectProvider)?['id'] ?? '';
          return TaskListPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/tasks/create',
        builder: (context, state) {
          final project = ref.read(currentProjectProvider);
          final projectId = project?['id']?.toString() ?? '';
          return TaskCreationPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '${RouteNames.tasks}/:taskId',
        builder: (context, state) =>
            TaskDetailPage(taskId: state.pathParameters['taskId'] ?? ''),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteNames.syncQueue,
        builder: (context, state) => const SyncQueuePage(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: RouteNames.budget,
        builder: (context, state) => const BudgetPage(),
      ),
    ],
  );
});

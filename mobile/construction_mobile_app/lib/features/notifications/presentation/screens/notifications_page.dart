import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../../../../core/notifications/notification_service.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_spacing.dart';

import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/routing/route_names.dart';

import '../../../project/presentation/providers/project_provider.dart';

import '../../domain/role_notification_filter.dart';

import '../widgets/notification_tile.dart';



class NotificationsPage extends ConsumerStatefulWidget {

  const NotificationsPage({super.key});



  @override

  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();

}



class _NotificationsPageState extends ConsumerState<NotificationsPage> {

  String? _filterType; // null = All



  @override

  void initState() {

    super.initState();

    // Fetch latest notifications on open

    Future.microtask(() {

      ref.read(notificationServiceProvider.notifier).fetchFromBackend();

    });

  }



  List<AppNotification> _applyTypeFilter(List<AppNotification> notifs) {

    if (_filterType == null) return notifs;

    switch (_filterType) {

      case 'approvals':

        return notifs

            .where((n) =>

                n.type.name.contains('approved') ||

                n.type.name.contains('submitted') ||

                n.type.name.contains('review'))

            .toList();

      case 'rejections':

        return notifs

            .where((n) => n.type.name.contains('rejected'))

            .toList();

      case 'tasks':

        return notifs.where((n) => n.type.name.contains('task')).toList();

      case 'system':

        return notifs

            .where((n) =>

                !n.type.name.contains('approved') &&

                !n.type.name.contains('submitted') &&

                !n.type.name.contains('review') &&

                !n.type.name.contains('rejected') &&

                !n.type.name.contains('task'))

            .toList();

      default:

        return notifs;

    }

  }



  @override

  Widget build(BuildContext context) {

    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;

    final notifState = ref.watch(notificationServiceProvider);

    final role = ref.watch(currentProjectRoleProvider) ?? 'owner';



    // Filter by role, then by type category

    final roleFiltered =

        RoleNotificationFilter.filter(notifState.notifications, role);

    final filtered = _applyTypeFilter(roleFiltered);



    return Scaffold(

      backgroundColor:

          isDark ? AppColors.darkBackground : AppColors.lightBackground,

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pushReplacement(RouteNames.projectDashboard),
        ),
        title: const Text('Notifications'),

        actions: [

          if (notifState.unreadCount > 0)

            TextButton(

              onPressed: () {

                ref.read(notificationServiceProvider.notifier).markAllRead();

              },

              child: Text(

                'Mark all read',

                style: AppTextStyles.label.copyWith(

                  color: AppColors.accentBlue,

                ),

              ),

            ),

        ],

      ),

      body: RefreshIndicator(

        onRefresh: () =>

            ref.read(notificationServiceProvider.notifier).fetchFromBackend(),

        child: Column(

          children: [

            // Category filter bar

            _CategoryFilterBar(

              selected: _filterType,

              onSelected: (v) => setState(() => _filterType = v),

            ),

            // Notification list

            Expanded(

              child: notifState.isLoading && filtered.isEmpty

                  ? const Center(child: CircularProgressIndicator())

                  : filtered.isEmpty

                      ? _EmptyState(isDark: isDark)

                      : _GroupedNotificationList(

                          notifications: filtered,

                          onMarkRead: (id) {

                            ref

                                .read(notificationServiceProvider.notifier)

                                .markAsRead(id);

                          },

                          onDismiss: (id) {

                            ref

                                .read(notificationServiceProvider.notifier)

                                .clearNotification(id);

                          },

                          onNavigate: (route) {

                            if (route != null) {

                              context.push(route);

                            }

                          },

                        ),

            ),

          ],

        ),

      ),

    );

  }

}



// ─── Category Filter Bar ─────────────────────────────────────────────────────



class _CategoryFilterBar extends StatelessWidget {

  final String? selected;

  final ValueChanged<String?> onSelected;



  const _CategoryFilterBar({

    required this.selected,

    required this.onSelected,

  });



  @override

  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final categories = <(String?, String, IconData)>[

      (null, 'All', Icons.list_rounded),

      ('approvals', 'Approvals', Icons.check_circle_outline_rounded),

      ('rejections', 'Rejections', Icons.cancel_outlined),

      ('tasks', 'Tasks', Icons.assignment_rounded),

      ('system', 'System', Icons.info_outline_rounded),

    ];



    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.lg,

        AppSpacing.md,

        AppSpacing.lg,

        0,

      ),

      child: Row(

        children: [

          for (final cat in categories) ...[

            ChoiceChip(

              label: Row(
                mainAxisSize: MainAxisSize.min,

                children: [

                  Icon(cat.$3, size: 14, color: AppColors.primaryTextFor(brightness)), 

                  const SizedBox(width: 4),

                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(cat.$2, style: AppTextStyles.label.copyWith(color: AppColors.primaryTextFor(brightness)),),
                  ),

                ],

              ),

              selected: selected == cat.$1,

              onSelected: (_) => onSelected(cat.$1),

            ),

            const SizedBox(width: AppSpacing.sm),

          ],

        ],

      ),

    );

  }

}



class _GroupedNotificationList extends StatelessWidget {

  final List<AppNotification> notifications;

  final ValueChanged<String> onMarkRead;

  final ValueChanged<String> onDismiss;

  final ValueChanged<String?> onNavigate;



  const _GroupedNotificationList({

    required this.notifications,

    required this.onMarkRead,

    required this.onDismiss,

    required this.onNavigate,

  });



  @override

  Widget build(BuildContext context) {

    final groups = _groupByDate(notifications);



    return ListView(

      children: [

        for (final entry in groups.entries) ...[

          Padding(

            padding: const EdgeInsets.fromLTRB(

              AppSpacing.lg,

              AppSpacing.lg,

              AppSpacing.lg,

              AppSpacing.sm,

            ),

            child: Text(

              entry.key,

              style: AppTextStyles.caption.copyWith(

                color: AppColors.mutedTextFor(Theme.of(context).brightness),

                fontWeight: FontWeight.w700,

              ),

            ),

          ),

          for (final notification in entry.value)

            NotificationTile(

              notification: notification,

              onTap: () {

                onMarkRead(notification.id);

                onNavigate(notification.actionRoute);

              },

            ),

          const Divider(height: 1),

        ],

      ],

    );

  }



  Map<String, List<AppNotification>> _groupByDate(

      List<AppNotification> notifs) {

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));



    final groups = <String, List<AppNotification>>{};

    for (final n in notifs) {

      final date =

          DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);

      String label;

      if (date == today) {

        label = 'Today';

      } else if (date == yesterday) {

        label = 'Yesterday';

      } else {

        label = 'Earlier';

      }

      groups.putIfAbsent(label, () => []).add(n);

    }

    return groups;

  }

}



class _EmptyState extends StatelessWidget {

  final bool isDark;

  const _EmptyState({required this.isDark});



  @override

  Widget build(BuildContext context) {

    return ListView(

      children: [

        SizedBox(

          height: MediaQuery.sizeOf(context).height * 0.5,

          child: Center(

            child: Padding(

              padding: const EdgeInsets.all(AppSpacing.xxl),

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Icon(

                    Icons.notifications_none_rounded,

                    size: 64,

                    color: AppColors.mutedTextFor(Theme.of(context).brightness),

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(

                    'No notifications yet',

                    style: AppTextStyles.sectionTitle.copyWith(

                      color: isDark

                          ? AppColors.darkTextPrimary

                          : AppColors.lightTextPrimary,

                    ),

                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(

                    'Notifications about your projects, tasks, and daily logs will appear here.',

                    textAlign: TextAlign.center,

                    style: AppTextStyles.bodyMuted.copyWith(

                      color: AppColors.secondaryTextFor(

                          Theme.of(context).brightness),

                    ),

                  ),

                ],

              ),

            ),

          ),

        ),

      ],

    );

  }

}


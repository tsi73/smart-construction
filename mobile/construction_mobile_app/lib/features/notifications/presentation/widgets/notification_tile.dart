import 'package:flutter/material.dart';

import '../../../../core/notifications/notification_service.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_spacing.dart';

import '../../../../core/theme/app_text_styles.dart';



class NotificationTile extends StatelessWidget {

  final AppNotification notification;

  final VoidCallback onTap;



  const NotificationTile({

    super.key,

    required this.notification,

    required this.onTap,

  });



  @override

  Widget build(BuildContext context) {

    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;

    final isUnread = !notification.isRead;



    return Dismissible(

      key: ValueKey(notification.id),

      direction: DismissDirection.endToStart,

      onDismissed: (_) {

        // Local-only clear handled by parent via notification service

      },

      background: Container(

        alignment: Alignment.centerRight,

        padding: const EdgeInsets.only(right: AppSpacing.xl),

        color: AppColors.error.withValues(alpha: 0.12),

        child: const Icon(Icons.delete_outline, color: AppColors.error),

      ),

      child: InkWell(

        onTap: onTap,

        child: Container(

          padding: const EdgeInsets.symmetric(

            horizontal: AppSpacing.lg,

            vertical: AppSpacing.md,

          ),

          color: isUnread

              ? AppColors.accentBlue.withValues(alpha: isDark ? 0.08 : 0.05)

              : Colors.transparent,

          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              _TypeIcon(type: notification.type),

              const SizedBox(width: AppSpacing.md),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        Expanded(

                          child: Text(

                            notification.title,

                            style: AppTextStyles.label.copyWith(

                              color: isDark

                                  ? AppColors.darkTextPrimary

                                  : AppColors.lightTextPrimary,

                              fontWeight:

                                  isUnread ? FontWeight.w700 : FontWeight.w500,

                            ),

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                          ),

                        ),

                        if (isUnread) ...[

                          const SizedBox(width: AppSpacing.sm),

                          Container(

                            width: 8,

                            height: 8,

                            decoration: const BoxDecoration(

                              color: AppColors.accentBlue,

                              shape: BoxShape.circle,

                            ),

                          ),

                        ],

                      ],

                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(

                      notification.message,

                      style: AppTextStyles.bodyMuted.copyWith(

                        color: AppColors.secondaryTextFor(brightness),

                      ),

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(

                      _timeAgo(notification.createdAt),

                      style: AppTextStyles.caption.copyWith(

                        color: AppColors.mutedTextFor(brightness),

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }



  String _timeAgo(DateTime dateTime) {

    final diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';

    if (diff.inHours < 24) return '${diff.inHours}h ago';

    if (diff.inDays == 1) return 'Yesterday';

    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';

  }

}



class _TypeIcon extends StatelessWidget {

  final NotificationType type;

  const _TypeIcon({required this.type});



  @override

  Widget build(BuildContext context) {

    final iconData = _iconForType(type);

    final color = _colorForType(type);



    return Container(

      width: 40,

      height: 40,

      decoration: BoxDecoration(

        color: color.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(10),

      ),

      child: Icon(iconData, size: 20, color: color),

    );

  }



  IconData _iconForType(NotificationType type) {

    switch (type) {

      case NotificationType.logSubmitted:

        return Icons.upload_rounded;

      case NotificationType.logConsultantApproved:

      case NotificationType.logPmApproved:

        return Icons.check_circle_rounded;

      case NotificationType.logRejected:

        return Icons.cancel_rounded;

      case NotificationType.taskAssigned:

      case NotificationType.taskStatusChanged:

        return Icons.assignment_ind_rounded;

      case NotificationType.memberAdded:

        return Icons.person_add_rounded;

      case NotificationType.invitationReceived:

        return Icons.mail_outline_rounded;

      case NotificationType.budgetAlert:

        return Icons.warning_amber_rounded;

      case NotificationType.delayRiskDetected:

        return Icons.speed_rounded;

      case NotificationType.syncFailure:

        return Icons.sync_problem_rounded;

    }

  }



  Color _colorForType(NotificationType type) {

    switch (type) {

      case NotificationType.logSubmitted:

        return AppColors.accentBlue;

      case NotificationType.logConsultantApproved:

      case NotificationType.logPmApproved:

        return AppColors.success;

      case NotificationType.logRejected:

        return AppColors.error;

      case NotificationType.taskAssigned:

      case NotificationType.taskStatusChanged:

        return AppColors.accentBlue;

      case NotificationType.memberAdded:

        return AppColors.constructProBlue;

      case NotificationType.invitationReceived:

        return AppColors.accentBlueStrong;

      case NotificationType.budgetAlert:

        return AppColors.warning;

      case NotificationType.delayRiskDetected:

        return AppColors.error;

      case NotificationType.syncFailure:

        return AppColors.accentAmber;

    }

  }

}


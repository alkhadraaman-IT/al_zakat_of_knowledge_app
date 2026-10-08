import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_top_header.dart';

/// Notification data model.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });
}

/// Notification type enum — determines icon and accent color.
enum NotificationType {
  session,
  material,
  article,
  booking,
  system,
}

/// Notifications screen — Stitch Design System.
/// Dark/light theme support, rounded cards, RTL layout.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _mockNotifications();
  }

  // ── Mock Data ──────────────────────────────────────────────────
  static List<AppNotification> _mockNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: '1',
        title: 'جلسة جديدة متاحة للحجز',
        body: 'تم فتح التسجيل في جلسة "أصول الفقه العظيم — المجلس الثالث". احجز مقعدك الآن قبل اكتمال العدد.',
        type: NotificationType.session,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 15)),
        data: {'session_id': 'session-abc-123'},
      ),
      AppNotification(
        id: '2',
        title: 'تم تأكيد حجزك',
        body: 'تم تأكيد حجزك في جلسة "شرح كتاب التوحيد". نراك يوم الأحد بعد المغرب بإذن الله.',
        type: NotificationType.booking,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
        data: {'session_id': 'session-def-456'},
      ),
      AppNotification(
        id: '3',
        title: 'مادة علمية جديدة',
        body: 'أُضيفت مادة جديدة بعنوان "مختصر في مصطلح الحديث" ضمن مكتبة زكاة العلم.',
        type: NotificationType.material,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 5)),
        data: {'material_id': 'material-xyz-789'},
      ),
      AppNotification(
        id: '4',
        title: 'مقال جديد من معلمك المفضل',
        body: 'نشر الشيخ د. أحمد المالكي مقالاً جديداً بعنوان "فضل طلب العلم في الإسلام".',
        type: NotificationType.article,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: '5',
        title: 'تذكير بموعد الجلسة',
        body: 'جلسة "فقه المعاملات المعاصرة" تبدأ بعد ساعة واحدة. لا تتأخر.',
        type: NotificationType.session,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
        data: {'session_id': 'session-ghi-012'},
      ),
      AppNotification(
        id: '6',
        title: 'تحديث سياسة الخصوصية',
        body: 'قمنا بتحديث سياسة الخصوصية الخاصة بالتطبيق. يرجى الاطلاع على التغييرات الجديدة.',
        type: NotificationType.system,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  // ── Helpers ───────────────────────────────────────────────────
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _onNotificationTap(AppNotification notification) {
    // Mark as read if unread
    if (!notification.isRead) {
      setState(() => notification.isRead = true);
    }

    // Navigate based on data payload
    final data = notification.data;
    if (data != null) {
      final sessionId = data['session_id'] as String?;
      final materialId = data['material_id'] as String?;

      if (sessionId != null) {
        context.go('/session-details/$sessionId');
      } else if (materialId != null) {
        context.go('/material-details/$materialId');
      }
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'منذ يوم واحد';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.session:
        return Icons.groups_2_outlined;
      case NotificationType.material:
        return Icons.menu_book_outlined;
      case NotificationType.article:
        return Icons.article_outlined;
      case NotificationType.booking:
        return Icons.event_available_outlined;
      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTopHeader(
              context: context,
              onBack: () => Navigator.pop(context),
              trailing: _unreadCount > 0
                  ? TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(
                        'تحديد الكل كمقروء',
                        style: AppTypography.arabicLabel(
                          color: cs.primary,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState(cs)
                  : _buildNotificationList(cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                color: cs.onSurfaceVariant,
                size: 36.w,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'لا توجد إشعارات',
              style: AppTypography.arabicTitle(
                color: cs.onSurface,
                fontSize: 18,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'عندما تصلك إشعارات جديدة ستظهر هنا',
              style: AppTypography.arabicBody(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(ColorScheme cs) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      itemCount: _notifications.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _NotificationCard(
          notification: notification,
          icon: _iconForType(notification.type),
          timeAgo: _timeAgo(notification.createdAt),
          onTap: () => _onNotificationTap(notification),
        );
      },
    );
  }
}

/// Individual notification card widget.
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isUnread
                ? cs.primary.withValues(alpha: 0.06)
                : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isUnread
                  ? cs.primary.withValues(alpha: 0.25)
                  : cs.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: isUnread
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isUnread ? cs.primary : cs.onSurfaceVariant,
                  size: 22.w,
                ),
              ),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.arabicTitle(
                              color: cs.onSurface,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          timeAgo,
                          style: AppTypography.arabicCaption(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.body,
                      style: AppTypography.arabicBody(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Unread indicator dot
              if (isUnread) ...[
                SizedBox(width: 8.w),
                Container(
                  width: 10.w,
                  height: 10.w,
                  margin: EdgeInsets.only(top: 4.h),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.4),
                        blurRadius: 6.r,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

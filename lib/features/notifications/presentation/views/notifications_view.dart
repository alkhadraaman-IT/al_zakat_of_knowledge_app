import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_failure.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_card.dart';
import '../widgets/notifications_empty_state.dart';
import '../widgets/notifications_failure_texts.dart';
import '../widgets/notifications_stale_banner.dart';
import 'notifications_error_view.dart';

/// يوفّر الـ Cubit ويشغّله. هذا ما تسجّله بالـ router.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..start(),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  void _onTap(BuildContext context, AppNotification n) {
    final cubit = context.read<NotificationsCubit>();
    if (!n.isRead) cubit.markAsRead(n.id);

    // push (وليس go) ليبقى زر الرجوع يعيد لقائمة الإشعارات
    if (n.sessionId != null) {
      context.push('/session-details/${n.sessionId}');
    } else if (n.materialId != null) {
      context.push('/material-details/${n.materialId}');
    } else if (n.articleId != null) {
      context.push('/article-details/${n.articleId}'); // TODO: تأكد من اسم المسار
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocSelector<NotificationsCubit, NotificationsState, int>(
              selector: (s) => s.unreadCount,
              builder: (context, unread) => AppTopHeader(
                context: context,
                onBack: () => Navigator.pop(context),
                trailing: unread > 0
                    ? TextButton(
                        onPressed: () =>
                            context.read<NotificationsCubit>().markAllAsRead(),
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
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocConsumer<NotificationsCubit, NotificationsState>(
                // فشل عملية (تحديد/حذف) والقائمة معروضة: رسالة صريحة مع إعادة المحاولة
                listenWhen: (p, c) =>
                    c.status == NotificationsStatus.failure &&
                    c.notifications.isNotEmpty &&
                    (p.status != NotificationsStatus.failure || p.failure != c.failure),
                listener: (context, state) {
                  final kind = state.failure!;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('فشلت العملية. ${kind.message}'),
                      action: kind.isRetryable
                          ? SnackBarAction(
                              label: 'إعادة المحاولة',
onPressed: () => context.read<NotificationsCubit>().retry(),
                            )
                          : null,
                    ));
                },
                builder: (context, state) {
                  final cubit = context.read<NotificationsCubit>();

                  if (state.notifications.isEmpty) {
                    if (state.status == NotificationsStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == NotificationsStatus.failure) {
                      // فشل صريح، وليس "لا توجد إشعارات"
                      return NotificationsErrorView(
                        kind: state.failure!,
                        onRetry: cubit.retry,
                      );
                    }
                    return const NotificationsEmptyState();
                  }

                  return _NotificationsList(
                    items: state.notifications,
                    staleFailure: state.partialFailure,
                    onRetry: cubit.retry,
                    onTap: (n) => _onTap(context, n),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<AppNotification> items;
  final NotificationsFailureKind? staleFailure;
  final VoidCallback onRetry;
  final void Function(AppNotification) onTap;

  const _NotificationsList({
    required this.items,
    required this.staleFailure,
    required this.onRetry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasBanner = staleFailure != null;

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationsCubit>().refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        itemCount: items.length + (hasBanner ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          if (hasBanner && i == 0) {
            return NotificationsStaleBanner(kind: staleFailure!, onRetry: onRetry);
          }
          final n = items[hasBanner ? i - 1 : i];
          return Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => context.read<NotificationsCubit>().delete(n.id),
            background: _deleteBg(cs, AlignmentDirectional.centerStart),
            secondaryBackground: _deleteBg(cs, AlignmentDirectional.centerEnd),
            child: NotificationCard(notification: n, onTap: () => onTap(n)),
          );
        },
      ),
    );
  }

  Widget _deleteBg(ColorScheme cs, AlignmentGeometry alignment) => Container(
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      );
}

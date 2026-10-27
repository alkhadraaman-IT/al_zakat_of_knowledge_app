import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_card.dart';
import '../widgets/notifications_empty_state.dart';
import '../widgets/notifications_error_view.dart';

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
                // لو فيه قائمة معروضة وصار خطأ، أظهر SnackBar بدل استبدال الشاشة
                listenWhen: (p, c) =>
                    c.status == NotificationsStatus.failure &&
                    c.notifications.isNotEmpty,
                listener: (context, state) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(notificationsErrorText(state.errorMessage))),
                  );
                },
                builder: (context, state) {
                  if (state.status == NotificationsStatus.loading &&
                      state.notifications.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == NotificationsStatus.failure &&
                      state.notifications.isEmpty) {
                    return NotificationsErrorView(
                      code: state.errorMessage,
onRetry: () => context.read<NotificationsCubit>().start(),
                    );
                  }
                  if (state.notifications.isEmpty) {
                    return const NotificationsEmptyState();
                  }
                  return _NotificationsList(
                    items: state.notifications,
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
  final void Function(AppNotification) onTap;

  const _NotificationsList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationsCubit>().refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final n = items[i];
          return Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => context.read<NotificationsCubit>().delete(n.id),
            background: Container(
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
            ),
            secondaryBackground: Container(
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
            ),
            child: NotificationCard(notification: n, onTap: () => onTap(n)),
          );
        },
      ),
    );
  }
}

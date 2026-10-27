import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/notification_failure.dart';
import '../widgets/notifications_failure_texts.dart';

/// شاشة فشل التحميل: تقول صراحةً أن التحميل فشل، مع السبب وزر إعادة المحاولة.
/// (لا نعرض "لا توجد إشعارات" عند الفشل لأنه مضلِّل.)
class NotificationsErrorView extends StatelessWidget {
  final NotificationsFailureKind kind;
  final VoidCallback onRetry;

  const NotificationsErrorView({super.key, required this.kind, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(kind.icon, color: cs.error, size: 44),
            SizedBox(height: AppSpacing.md),
            Text(
              'فشل تحميل الإشعارات',
              style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              kind.message,
              style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (kind.isRetryable) ...[
              SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'إعادة المحاولة',
                  style: AppTypography.arabicLabel(color: cs.onPrimary, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

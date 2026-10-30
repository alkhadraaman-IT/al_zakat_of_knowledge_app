import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/notification_failure.dart';
import 'notifications_failure_texts.dart';

/// يظهر أعلى القائمة حين فشل تحديثها من الخادم وما نعرضه هو المحفوظ فقط.
class NotificationsStaleBanner extends StatelessWidget {
  final NotificationsFailureKind kind;
  final VoidCallback onRetry;

  const NotificationsStaleBanner({super.key, required this.kind, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(kind.icon, color: cs.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'notifications.stale'.tr(
                namedArgs: {'error': kind.message},
              ),
              style: AppTypography.arabicBody(color: cs.onErrorContainer, fontSize: 12),
            ),
          ),
          if (kind.isRetryable)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'common.retry'.tr(),
                style: AppTypography.arabicLabel(color: cs.onErrorContainer, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

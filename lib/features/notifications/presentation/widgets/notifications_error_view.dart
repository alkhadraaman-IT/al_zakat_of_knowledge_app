import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

/// يحوّل رمز الخطأ القادم من الخادم لنص مفهوم.
/// لاحقاً انقل النصوص لملفات الترجمة (ar/en).
String notificationsErrorText(String? code) => switch (code) {
      'network_error' => 'تعذّر الاتصال بالإنترنت',
      'not_authenticated' => 'سجّل الدخول أولاً',
      'account_restricted' => 'الحساب موقوف',
      _ => 'حدث خطأ غير متوقع',
    };

class NotificationsErrorView extends StatelessWidget {
  final String? code;
  final VoidCallback onRetry;

  const NotificationsErrorView({super.key, this.code, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, color: cs.onSurfaceVariant, size: 40),
            SizedBox(height: AppSpacing.md),
            Text(
              notificationsErrorText(code),
              style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(
                'إعادة المحاولة',
                style: AppTypography.arabicLabel(color: cs.primary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

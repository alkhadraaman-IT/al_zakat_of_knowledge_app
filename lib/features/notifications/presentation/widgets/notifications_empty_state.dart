import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
              style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 18),
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
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_typography.dart';

Future<void> showSuccessDialog(
  BuildContext context, {
  String? title,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      final cs = Theme.of(dialogCtx).colorScheme;
      return AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 20.r,
                  ),
                ],
              ),
              child: Icon(Icons.check, color: cs.onPrimary, size: 44.w),
            ),
            SizedBox(height: 20.h),
            Text(
              title ?? 'تم النشر بنجاح',
              style: AppTypography.arabicHeadline(
                color: cs.onSurface,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'بارك الله في علمك ونفعنا وإياك به، وهذه صدقة جارية بإذن الله',
              style: AppTypography.arabicBody(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: cs.primary,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  onTap: () => Navigator.of(dialogCtx).pop(),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Center(
                      child: Text(
                        'تم',
                        style: AppTypography.arabicTitle(
                          color: cs.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
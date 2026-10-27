import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_typography.dart';

/// Dua success dialog — shown after a successful
/// article publication with the fixed supplication:
/// "بارك الله في علمك ونفعنا وإياك به".
Future<void> showDuaSuccessDialog(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 30.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing checkmark circle
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.45),
                      blurRadius: 30.r,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: colorScheme.onPrimary,
                  size: 40.w,
                ),
              ),
              SizedBox(height: 20.h),
              // Success title
              Text(
                'article.dua_title'.tr(),
                style: AppTypography.arabicHeadline(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              // Fixed dua message
              Text(
                'article.dua_message'.tr(),
                style: AppTypography.arabicBody(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Done button
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Center(
                        child: Text(
                          'article.dua_done'.tr(),
                          style: AppTypography.arabicTitle(
                            color: colorScheme.onPrimary,
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
        ),
      );
    },
  );
}

/// Success confirmation dialog — Stitch Design System.
/// Shows a glowing checkmark, success message, and home button.
void showSuccessDialog(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 30.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing checkmark circle
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.45),
                      blurRadius: 30.r,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: colorScheme.onPrimary,
                  size: 40.w,
                ),
              ),
              SizedBox(height: 20.h),
              // Success message
              Text(
                'بارك الله في علمك',
                style: AppTypography.arabicHeadline(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'ونفع بك... هذه صدقة جارية',
                style: AppTypography.arabicBody(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Home button
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home');
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Center(
                        child: Text(
                          'الرئيسية',
                          style: AppTypography.arabicTitle(
                            color: colorScheme.onPrimary,
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
        ),
      );
    },
  );
}

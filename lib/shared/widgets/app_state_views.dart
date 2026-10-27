import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';

/// حاوية مشتركة للحالات (تحميل / فارغ / خطأ).
/// [height] = null: تتمركز بكل المساحة المتاحة (شاشة كاملة).
/// [height] محدد: ارتفاع ثابت، للاستخدام داخل Scroll (مثل HomeView).
class _StateBox extends StatelessWidget {
  final double? height;
  final List<Widget> children;

  const _StateBox({required this.height, required this.children});

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
    return height == null ? content : SizedBox(height: height, child: content);
  }
}

/// مؤشر تحميل.
class AppLoadingState extends StatelessWidget {
  final double? height;
  const AppLoadingState({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    const indicator = Center(child: CircularProgressIndicator());
    return height == null ? indicator : SizedBox(height: height, child: indicator);
  }
}

/// حالة فارغة: أيقونة + عنوان + نص مساعد اختياري.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  final double? height;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _StateBox(
      height: height,
      children: [
        Icon(icon, color: cs.onSurfaceVariant, size: 64.w),
        SizedBox(height: 16.h),
        Text(
          title,
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        if (hint != null) ...[
          SizedBox(height: 8.h),
          Text(
            hint!,
            style: AppTypography.arabicCaption(
              color: cs.onSurfaceVariant,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// حالة خطأ مع زر إعادة المحاولة.
class AppErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final String retryLabel;
  final VoidCallback onRetry;
  final double? height;

  const AppErrorState({
    super.key,
    required this.title,
    required this.retryLabel,
    required this.onRetry,
    this.message,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _StateBox(
      height: height,
      children: [
        Icon(Icons.error_outline, color: cs.error, size: 56.w),
        SizedBox(height: 12.h),
        Text(
          title,
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        if (message != null && message!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            message!,
            style: AppTypography.arabicCaption(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: 20.h),
        Material(
          color: cs.primary,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
Icon(Icons.refresh, color: cs.onPrimary, size: 18.w),
                  SizedBox(width: 8.w),
                  Text(
                    retryLabel,
                    style: AppTypography.arabicLabel(
                      color: cs.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
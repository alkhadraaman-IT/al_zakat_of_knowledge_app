import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class OnboardingPageData {
  final String imagePath;
  final String title;
  final String description;
  final String badge;

  const OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.badge,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الصورة
          Container(
            height: 220.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_outlined,
                  size: 64.w,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // الشارة (Badge)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              data.badge,
              style: AppTypography.arabicCaption(
                color: cs.primary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // العنوان (الحديث)
          Text(
            data.title,
            style: AppTypography.arabicHeadline(
              color: cs.onSurface,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),

          // الوصف
          Text(
            data.description,
            style: AppTypography.arabicBody(
              color: cs.onSurfaceVariant,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
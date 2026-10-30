import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // الشعار (logo.png) — على خلفية بيضاء لأن اللوجو ملوّن
        Container(
          width: 88.w,
          height: 88.w,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: cs.primary.withAlpha(8),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.3),
                blurRadius: 24.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo_app.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.school_outlined,
              size: 44.w,
              color: cs.primary,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          title.tr(),
          style: AppTypography.arabicDisplay(
            color: cs.onSurface,
            fontSize: 32,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          subtitle.tr(),
          style: AppTypography.arabicBody(
            color: cs.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
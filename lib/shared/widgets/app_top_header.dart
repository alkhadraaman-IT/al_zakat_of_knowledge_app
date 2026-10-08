import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';

/// Reusable top header — brand row with optional back button and trailing widget.
/// Used across Profile, Notifications, Session Details, and other screens.
class AppTopHeader extends StatelessWidget {
  final BuildContext context;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppTopHeader({
    super.key,
    required this.context,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.4),
                  blurRadius: 15.r,
                ),
              ],
            ),
            child: Icon(
              Icons.school_outlined,
              color: cs.onPrimary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'app.name'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onSurface,
                  fontSize: 19,
                ),
              ),
              Text(
                'app.header_tagline'.tr(),
                style: AppTypography.arabicCaption(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_ios, color: cs.onSurface),
            ),
        ],
      ),
    );
  }
}

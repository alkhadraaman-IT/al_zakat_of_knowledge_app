import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/session_with_profile.dart';

class SessionTitleSection extends StatelessWidget {
  final SessionWithProfile details;
  final VoidCallback onShare;

  const SessionTitleSection({
    super.key,
    required this.details,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final session = details.session;
    final category = details.categoryNameFor(context.locale.languageCode) ??
        'session.default_category'.tr();
    final createdAt = DateTime.tryParse(session.createdAt?.toString() ?? '');
    final isNew = createdAt != null &&
        DateTime.now().difference(createdAt).inHours < 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _pill(
              cs: cs,
              background: cs.primary.withValues(alpha: 0.1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 14.w, color: cs.primary),
                  SizedBox(width: 4.w),
                  Text(
                    category,
                    style: AppTypography.arabicLabel(
                      color: cs.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isNew)
              _pill(
                cs: cs,
                background: cs.surfaceContainerHigh,
                child: Text(
                  'session.new_badge'.tr(),
                  style: AppTypography.arabicLabel(
                    color: cs.secondary,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                session.title,
                style: AppTypography.arabicHeadline(
                  color: cs.onSurface,
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Material(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: onShare,
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Icon(Icons.share, color: cs.primary, size: 20.w),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pill({
    required ColorScheme cs,
    required Color background,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: child,
    );
  }
}
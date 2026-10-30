import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class AuthTermsCharter extends StatelessWidget {
  final bool accepted;
  final bool hasError;
  final ValueChanged<bool> onChanged;

  const AuthTermsCharter({
    super.key,
    required this.accepted,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onChanged(!accepted),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: accepted
              ? cs.primary.withValues(alpha: 0.05)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasError
                ? cs.error
                : (accepted ? cs.primary : cs.outline),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: accepted,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'auth.terms_agreement'.tr(),
                    style: AppTypography.arabicLabel(
                      color: cs.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.terms_description'.tr(),
                    style: AppTypography.arabicCaption(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
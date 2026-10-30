import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/session_with_profile.dart';

class SessionLecturerCard extends StatelessWidget {
  final SessionWithProfile details;
  const SessionLecturerCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final publisher = details.publisher;
    final name = publisher?.name ?? 'session.unknown'.tr();
    final role = publisher?.university ?? '';
    final initial = name.trim().isNotEmpty ? name.trim()[0] : 'د';
    final publisherId = publisher?.id ?? details.session.publisherId;

    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: publisherId.isEmpty
            ? null
            : () => context.push('/profile/$publisherId'),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isLight
                ? Border.all(color: cs.outline.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: AppTypography.arabicDisplay(
                          color: cs.onPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -4.h,
                    left: -4.w,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: cs.primary,
                        size: 14.w,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.arabicTitle(
                        color: cs.onSurface,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (role.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        role,
                        style: AppTypography.arabicBody(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: cs.onSurfaceVariant, size: 20.w),
            ],
          ),
        ),
      ),
    );
  }
}
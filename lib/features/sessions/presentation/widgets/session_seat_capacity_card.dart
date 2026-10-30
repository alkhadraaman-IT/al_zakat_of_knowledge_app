import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/session_entity.dart';

class SessionSeatCapacityCard extends StatelessWidget {
  final SessionEntity session;
  const SessionSeatCapacityCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final booked = session.bookedCount;
    final max = session.maxSeats;
    final quorumReached = booked >= max;
    final percent = max > 0 ? (booked / max) : 0.0;
    final percentLabel = '${(percent * 100).round()}%';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: isLight ? Border.all(color: cs.outline.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 10.w, height: 10.w, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
              SizedBox(width: 8.w),
              Text('session.seats_status'.tr(), style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 15)),
              const Spacer(),
              Text('$booked', style: AppTypography.monoLabel(color: cs.primary, fontSize: 15)),
              Text(' / ', style: AppTypography.monoCaption(color: cs.onSurfaceVariant, fontSize: 13)),
              Text('$max ${'session.seats'.tr()}', style: AppTypography.monoCaption(color: cs.onSurfaceVariant, fontSize: 13)),
              SizedBox(width: 6.w),
              Text('($percentLabel)', style: AppTypography.monoLabel(color: cs.primary, fontSize: 13)),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            height: 12.h, padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(color: cs.surfaceContainerLowest, borderRadius: BorderRadius.circular(999.r)),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: percent.clamp(0.0, 1.0).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: quorumReached ? [cs.primary, cs.secondary] : [cs.secondary, cs.secondary.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(quorumReached ? Icons.check_circle : Icons.verified_user, color: cs.primary, size: 17.w),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  quorumReached ? 'session.quorum_reached'.tr() : 'session.quorum_waiting'.tr(),
                  style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 11),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: quorumReached ? cs.primary.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  quorumReached ? 'session.completed'.tr() : 'session.awaiting'.tr(),
                  style: AppTypography.monoCaption(color: quorumReached ? cs.primary : cs.onSurfaceVariant, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
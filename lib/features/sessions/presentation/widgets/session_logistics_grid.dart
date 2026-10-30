import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/session_entity.dart';

class SessionLogisticsGrid extends StatelessWidget {
  final SessionEntity session;
  const SessionLogisticsGrid({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final startTime = DateTime.tryParse(session.startsAt)?.toLocal();

    final weekdays = [
      'session.day_sunday'.tr(), 'session.day_monday'.tr(),
      'session.day_tuesday'.tr(), 'session.day_wednesday'.tr(),
      'session.day_thursday'.tr(), 'session.day_friday'.tr(),
      'session.day_saturday'.tr(),
    ];
    final months = [
      'session.month_january'.tr(), 'session.month_february'.tr(),
      'session.month_march'.tr(), 'session.month_april'.tr(),
      'session.month_may'.tr(), 'session.month_june'.tr(),
      'session.month_july'.tr(), 'session.month_august'.tr(),
      'session.month_september'.tr(), 'session.month_october'.tr(),
      'session.month_november'.tr(), 'session.month_december'.tr(),
    ];

    String dateValue = 'session.unspecified'.tr();
    String dateSub = '—';
    if (startTime != null) {
      dateValue = '${weekdays[startTime.weekday % 7]} ${startTime.day} ${months[startTime.month - 1]}';
      dateSub = '${startTime.year}/${startTime.month}/${startTime.day}';
    }

    final hour = startTime?.hour ?? 18;
    final minute = startTime?.minute ?? 15;
    final timeValue = startTime != null
        ? '${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr()}'
        : 'session.unspecified'.tr();

    return Row(
      children: [
        Expanded(
          child: _logisticsCard(
            cs: cs, isLight: isLight,
            icon: Icons.calendar_today_outlined,
            label: 'session.date_label'.tr(),
            value: dateValue, sub: dateSub,
            subColor: cs.primary,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _logisticsCard(
            cs: cs, isLight: isLight,
            icon: Icons.schedule,
            label: 'session.time_label'.tr(),
            value: timeValue,
            sub: '${session.durationMinutes} ${'session.duration_minutes'.tr()}',
            subColor: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _logisticsCard(
            cs: cs, isLight: isLight,
            icon: Icons.meeting_room_outlined,
            label: 'session.place_label'.tr(),
            value: session.placeName,
            sub: session.city,
            subColor: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _logisticsCard({
    required ColorScheme cs, required bool isLight,
    required IconData icon, required String label,
    required String value, required String sub, required Color subColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        border: isLight ? Border.all(color: cs.outline.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        children: [
          Container(
            width: 32.w, height: 32.w,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: cs.primary, size: 18.w),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 11)),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 13),
            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            sub,
            style: AppTypography.monoCaption(color: subColor, fontSize: 10),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
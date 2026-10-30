import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/session_with_profile.dart';
import '../booking_cubit/booking_cubit.dart';
import '../booking_cubit/booking_state.dart';

class SessionBottomBar extends StatelessWidget {
  final SessionWithProfile details;
  final VoidCallback onBook;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const SessionBottomBar({
    super.key,
    required this.details,
    required this.onBook,
    required this.onCancel,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: cs.shadow.withValues(alpha: isLight ? 0.06 : 0.4), blurRadius: 24.r, offset: Offset(0, 8.h)),
            ],
          ),
          child: details.isPublisher
              ? _buildPublisherActions(context, cs)
              : _buildAttendeeActions(context, cs),
        ),
      ),
    );
  }

  Widget _buildPublisherActions(BuildContext context, ColorScheme cs) {
    final startTime = DateTime.tryParse(details.session.startsAt)?.toLocal();
    final hasStarted = startTime != null && !startTime.isAfter(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: _barButton(
            cs: cs, label: 'session.edit'.tr(), icon: Icons.edit_outlined,
            background: hasStarted ? cs.surfaceContainerHighest : cs.primary,
            foreground: hasStarted ? cs.onSurfaceVariant : cs.onPrimary,
            onTap: hasStarted
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('session.edit_locked'.tr())),
                    );
                  }
                : onEdit,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _barButton(
            cs: cs, label: 'session.delete'.tr(), icon: Icons.delete_outline,
            background: cs.error.withValues(alpha: 0.12), foreground: cs.error,
            onTap: onDelete,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeActions(BuildContext context, ColorScheme cs) {
    final status = details.session.status;
    final startTime = DateTime.tryParse(details.session.startsAt)?.toLocal();
    final isCancelled = status == 'cancelled';
    final hasStarted = startTime != null && !startTime.isAfter(DateTime.now());
    final unavailable = !details.isBooked && (isCancelled || hasStarted);
    final seatsDisabled = unavailable;

    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final isBooking = state is BookingLoading;
        final ctaBg = isBooking
            ? cs.surfaceContainerHighest
            : details.isBooked
                ? cs.surfaceContainerLowest
                : seatsDisabled ? cs.surfaceContainerHighest : cs.primary;
        final ctaFg = isBooking
            ? cs.onSurfaceVariant
            : details.isBooked
                ? cs.primary
                : seatsDisabled ? cs.onSurfaceVariant : cs.onPrimary;

        final ctaLabel = isBooking
            ? 'booking.booking'.tr()
            : details.isBooked
                ? 'booking.cancel'.tr()
                : unavailable
                    ? (isCancelled ? 'session.cancelled'.tr() : 'session.ended'.tr())
                    : 'booking.book_seat'.tr();

        final ctaIcon = isBooking
            ? Icons.hourglass_empty
            : details.isBooked
                ? Icons.cancel_outlined
                : seatsDisabled ? Icons.event_busy : Icons.how_to_reg;

        return Row(
          children: [
            Tooltip(
              message: 'report.title'.tr(),
              child: Material(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: isBooking ? null : onReport,
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 48.w, height: 48.w,
                    child: Icon(Icons.flag_outlined, color: cs.onSurfaceVariant, size: 24.w),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Material(
                color: ctaBg, borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: seatsDisabled || isBooking ? null : (details.isBooked ? onCancel : onBook),
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    height: 56.h,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isBooking
                              ? SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(strokeWidth: 2.w, color: ctaFg))
                              : Icon(ctaIcon, color: ctaFg, size: 20.w),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(ctaLabel, style: AppTypography.arabicTitle(color: ctaFg, fontSize: 15), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _barButton({
    required ColorScheme cs, required String label, required IconData icon,
    required Color background, required Color foreground, required VoidCallback onTap,
  }) {
    return Material(
      color: background, borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 56.h,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: 20.w),
                SizedBox(width: 8.w),
                Flexible(child: Text(label, style: AppTypography.arabicTitle(color: foreground, fontSize: 15), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_refresh.dart';
import '../../../../features/reports/presentation/widgets/report_sheet.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../domain/entities/session_with_profile.dart';
import '../../domain/usecases/get_session_by_id_usecase.dart';
import '../booking_cubit/booking_cubit.dart';
import '../booking_cubit/booking_state.dart';
import '../session_cubit/session_cubit.dart';
import '../session_cubit/session_state.dart';
import '../session_details_cubit/session_details_cubit.dart';
import '../session_details_cubit/session_details_state.dart';
import '../widgets/edit_session_sheet.dart';
import '../widgets/session_bottom_bar.dart';
import '../widgets/session_lecturer_card.dart';
import '../widgets/session_logistics_grid.dart';
import '../widgets/session_map_card.dart';
import '../widgets/session_seat_capacity_card.dart';
import '../widgets/session_share_sheet.dart';
import '../widgets/session_title_section.dart';

class SessionDetailsView extends StatelessWidget {
  final String sessionId;
  final bool isPublisherView;

  const SessionDetailsView({
    super.key,
    required this.sessionId,
    this.isPublisherView = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SessionDetailsCubit(
            getSessionByIdUseCase: sl<GetSessionByIdUseCase>(),
            sessionId: sessionId,
          )..load(),
        ),
        BlocProvider(create: (_) => sl<BookingCubit>()),
        BlocProvider.value(value: sl<SessionCubit>()),
      ],
      child: _SessionDetailsContent(
        sessionId: sessionId,
        isPublisherView: isPublisherView,
      ),
    );
  }
}

class _SessionDetailsContent extends StatelessWidget {
  final String sessionId;
  final bool isPublisherView;

  const _SessionDetailsContent({
    required this.sessionId,
    required this.isPublisherView,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              // تحديث الواجهة محلياً عبر Cubit بدل setState
              context
                  .read<SessionDetailsCubit>()
                  .onBookingChanged(isBooked: state.isBooked);
              AppRefresh.refreshSessions();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isBooked
                        ? 'booking.booked_success'.tr()
                        : 'booking.canceled_success'.tr(),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_bookingErrorMessage(state.message)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (_, current) => current is SessionUpdateSuccess,
          listener: (context, state) {
            if (state is SessionUpdateSuccess &&
                state.session.id == sessionId) {
              context.read<SessionDetailsCubit>().refresh();
            }
          },
        ),
      ],
      child: BlocBuilder<SessionDetailsCubit, SessionDetailsState>(
        builder: (context, state) {
          final cs = Theme.of(context).colorScheme;

          if (state is SessionDetailsLoading ||
              state is SessionDetailsInitial) {
            return Scaffold(
              backgroundColor: cs.surface,
              body: Center(
                child: CircularProgressIndicator(color: cs.primary),
              ),
            );
          }

          if (state is SessionDetailsError) {
            return _buildErrorView(context, state.message);
          }

          final details = (state as SessionDetailsLoaded).details;
          final effectivePublisher =
              details.isPublisher || isPublisherView;

          return _SessionDetailsBody(
            details: details,
            isPublisherEffective: effectivePublisher,
            sessionId: sessionId,
          );
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64.w, color: cs.error),
              SizedBox(height: 16.h),
              Text(
                message.isNotEmpty ? message : 'errors.load_failed'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onSurface,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text('errors.back_home'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _bookingErrorMessage(String raw) {
    const messages = {
      'session_full': 'اكتملت مقاعد هذه الجلسة',
      'already_booked': 'أنت حاجز لهذه الجلسة مسبقاً',
      'session_started': 'بدأت هذه الجلسة أو انتهت',
      'session_not_active': 'هذه الجلسة ملغاة',
      'session_not_found': 'الجلسة غير موجودة',
      'own_session': 'لا يمكنك حجز جلستك',
      'not_allowed': 'غير مسموح لك بحجز هذه الجلسة',
      'account_restricted': 'حسابك موقوف حالياً',
      'not_authenticated': 'سجّل الدخول أولاً',
      'cancel_window_passed': 'انتهت مهلة الإلغاء (قبل الموعد بـ 24 ساعة)',
      'booking_not_found': 'لا يوجد حجز مؤكد لإلغائه',
    };
    for (final entry in messages.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }
    return raw;
  }
}

// ─────────────────────────────────────────────
// جسم الشاشة (Loaded State)
// ─────────────────────────────────────────────
class _SessionDetailsBody extends StatelessWidget {
  final SessionWithProfile details;
  final bool isPublisherEffective;
  final String sessionId;

  const _SessionDetailsBody({
    required this.details,
    required this.isPublisherEffective,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopHeader(
                context: context,
                onBack: () => Navigator.maybePop(context),
              ),
              SizedBox(height: AppSpacing.sm),

              SessionTitleSection(
                details: details,
                onShare: () =>
                    showSessionShareSheet(context, details.session),
              ),
              SizedBox(height: AppSpacing.md),

              if (!isPublisherEffective) ...[
                SessionLecturerCard(details: details),
                SizedBox(height: AppSpacing.md),
              ],

              Text(
                details.session.description,
                style: AppTypography.arabicBody(
                  color: cs.onSurface.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: AppSpacing.md),

              SessionLogisticsGrid(session: details.session),
              SizedBox(height: AppSpacing.sm),

              SessionMapCard(session: details.session),
              SizedBox(height: AppSpacing.md),

              SessionSeatCapacityCard(session: details.session),
              SizedBox(height: 140.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SessionBottomBar(
        details: details,
        onBook: () => context
            .read<BookingCubit>()
            .bookSession(sessionId),
        onCancel: () => _showCancelConfirmation(context),
        onEdit: () => _openEditSheet(context),
        onDelete: () => _confirmDelete(context),
        onReport: () => showReportSheet(
          context: context,
          targetType: 'session',
          targetId: sessionId,
        ),
      ),
    );
  }

  Future<void> _showCancelConfirmation(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'booking.cancel_title'.tr(),
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
        ),
        content: Text(
          'booking.cancel_message'.tr(),
          style: AppTypography.arabicBody(
            color: cs.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'booking.keep'.tr(),
              style: AppTypography.arabicLabel(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'booking.cancel'.tr(),
              style: AppTypography.arabicLabel(color: cs.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<BookingCubit>().cancelBooking(sessionId);
    }
  }

  Future<void> _openEditSheet(BuildContext context) async {
    final updated = await showEditSessionSheet(
      context,
      sessionId: sessionId,
      sessionData: details.session.toEditMap(),
    );
    if (updated == true && context.mounted) {
      context.read<SessionDetailsCubit>().refresh();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'session.delete_confirm_title'.tr(),
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
        ),
        content: Text(
          'session.delete_confirm_message'.tr(),
          style: AppTypography.arabicBody(
            color: cs.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'common.cancel'.tr(),
              style: AppTypography.arabicLabel(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'common.delete'.tr(),
              style: AppTypography.arabicLabel(color: cs.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await Supabase.instance.client
            .from('sessions')
            .update({'status': 'cancelled'})
            .eq('id', sessionId);
        AppRefresh.refreshSessions();
        if (context.mounted) context.go('/home');
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تعذّر إلغاء الجلسة، حاول مرة أخرى'),
              backgroundColor: cs.error,
            ),
          );
        }
      }
    }
  }
}
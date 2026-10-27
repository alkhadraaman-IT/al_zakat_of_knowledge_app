// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../app/theme/app_typography.dart';
// import '../../../reports/presentation/widgets/report_sheet.dart';
// import '../booking_cubit/booking_cubit.dart';

// class SessionDetailsContent extends StatefulWidget {
//   final String sessionId;
//   final bool isPublisherView;

//   const SessionDetailsContent({
//     required this.sessionId,
//     this.isPublisherView = false,
//   });

//   @override
//   State<SessionDetailsContent> createState() => SessionDetailsContentState();
// }

// class SessionDetailsContentState extends State<SessionDetailsContent> {
//   SessionDetailsEntity? get _details {
//     final state = context.read<SessionDetailsCubit>().state;
//     return state is SessionDetailsLoaded ? state.details : null;
//   }

//   Map<String, dynamic>? get _session => _details?.toViewMap();
//   Map<String, dynamic>? get _publisher =>
//       _session?['publisher'] as Map<String, dynamic>?;

//   bool get _isBooked => _details?.isBooked ?? false;
//   bool get _isPublisher => _details?.isPublisher ?? false;
//   bool get _isPublisherEffective => _isPublisher || widget.isPublisherView;

//   String get _categoryName {
//     final raw = _session?['category'];
//     if (raw is Map) {
//       final isEn = context.locale.languageCode == 'en';
//       final value = isEn ? raw['name_en'] : raw['name_ar'];
//       if (value != null && value.toString().isNotEmpty) return value.toString();
//     } else if (raw is String && raw.isNotEmpty) {
//       return raw;
//     }
//     return 'session.default_category'.tr();
//   }

//   bool get _isLight => Theme.of(context).brightness == Brightness.light;

//   List<String> get _weekdays => [
//     'session.day_sunday'.tr(),
//     'session.day_monday'.tr(),
//     'session.day_tuesday'.tr(),
//     'session.day_wednesday'.tr(),
//     'session.day_thursday'.tr(),
//     'session.day_friday'.tr(),
//     'session.day_saturday'.tr(),
//   ];

//   List<String> get _months => [
//     'session.month_january'.tr(),
//     'session.month_february'.tr(),
//     'session.month_march'.tr(),
//     'session.month_april'.tr(),
//     'session.month_may'.tr(),
//     'session.month_june'.tr(),
//     'session.month_july'.tr(),
//     'session.month_august'.tr(),
//     'session.month_september'.tr(),
//     'session.month_october'.tr(),
//     'session.month_november'.tr(),
//     'session.month_december'.tr(),
//   ];

//   String _bookingErrorMessage(String raw) {
//     const messages = {
//       'اكتملت مقاعد هذه الجلسة': 'session_full',
//       'أنت حاجز لهذه الجلسة مسبقاً': 'already_booked',
//       'بدأت هذه الجلسة أو انتهت': 'session_started',
//       'هذه الجلسة ملغاة': 'session_not_active',
//       'الجلسة غير موجودة': 'session_not_found',
//       'لا يمكنك حجز جلستك': 'own_session',
//       'غير مسموح لك بحجز هذه الجلسة': 'not_allowed',
//       'حسابك موقوف حالياً': 'account_restricted',
//       'سجل الدخول': 'not_authenticated',
//       'انتهت مهلة الإلغاء قبل الموعد بـ 24 ساعة': 'cancel_window_passed',
//       'لا يوجد حجز مؤكد لإلغائه': 'booking_not_found',
//     };
//     for (final entry in messages.entries) {
//       if (raw.contains(entry.key)) return entry.value;
//     }
//     return raw;
//   }

//   Future<void> _toggleBooking() async {
//     if (_isBooked) {
//       final confirmed = await _showCancelConfirmation();
//       if (confirmed != true || !mounted) return;
//     }
//     final cubit = context.read<BookingCubit>();
//     if (_isBooked) {
//       await cubit.cancelBooking(widget.sessionId);
//     } else {
//       await cubit.bookSession(widget.sessionId);
//     }
//   }

//   Future<bool?> _showCancelConfirmation() {
//     final cs = Theme.of(context).colorScheme;
//     return showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: cs.surfaceContainerHigh,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         title: Text(
//           'booking.cancel_title'.tr(),
//           style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
//         ),
//         content: Text(
//           'booking.cancel_message'.tr(),
//           style: AppTypography.arabicBody(
//             color: cs.onSurfaceVariant,
//             fontSize: 14,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: Text(
//               'booking.keep'.tr(),
//               style: AppTypography.arabicLabel(
//                 color: cs.onSurfaceVariant,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: Text(
//               'booking.cancel'.tr(),
//               style: AppTypography.arabicLabel(color: cs.error, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _openReportSheet() async {
//     final reported = await showReportSheet(
//       context: context,
//       targetType: 'session',
//       targetId: widget.sessionId,
//     );
//     if (reported && mounted) {}
//   }
// }

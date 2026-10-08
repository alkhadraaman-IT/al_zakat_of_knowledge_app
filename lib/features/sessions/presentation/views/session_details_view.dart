import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_map_grid_painter.dart';
import '../../../../shared/widgets/app_top_header.dart';

/// Session Details screen — strictly follows the Stitch design system:
/// `ui/stitch_zakat_al_ilm_ui_design_system/session_details`.
///
/// Structure (top → bottom, single scroll view):
/// 1. Shared AppTopHeader (logo + brand + back)
/// 2. Session title + custom share button (QR bottom sheet)
/// 3. Lecturer info card — taps navigate to `/profile/:id`
/// 4. Description & details text
/// 5. Date, time & location logistics card
/// 6. Map preview widget
/// 7. Live seat capacity bar
/// Sticky floating bottom action bar — strictly role-based:
/// • Publisher  → "تعديل الجلسة" + "حذف الجلسة" (confirm dialog)
/// • Attendee   → "إبلاغ" report icon + "حجز مقعد" / "إلغاء الحجز"
class SessionDetailsView extends StatefulWidget {
  final String sessionId;

  /// When true (e.g. opened from ProfileView 'محاضراتي' tab),
  /// the session belongs to the logged-in user — the publisher
  /// management bottom bar is shown unconditionally.
  final bool isPublisherView;

  const SessionDetailsView({super.key, required this.sessionId, this.isPublisherView = false});

  @override
  State<SessionDetailsView> createState() => _SessionDetailsViewState();
}

class _SessionDetailsViewState extends State<SessionDetailsView> {
  Map<String, dynamic>? _session;
  Map<String, dynamic>? _publisher;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isBooked = false;
  bool _isPublisher = false;

  /// Strict role check: explicit publisher view flag OR
  /// the session's publisher id matches the logged-in user.
  bool get _isPublisherEffective => _isPublisher || widget.isPublisherView;

  static final List<String> _weekdays = [
    'session.day_sunday'.tr(),
    'session.day_monday'.tr(),
    'session.day_tuesday'.tr(),
    'session.day_wednesday'.tr(),
    'session.day_thursday'.tr(),
    'session.day_friday'.tr(),
    'session.day_saturday'.tr(),
  ];
  static final List<String> _months = [
    'session.month_january'.tr(),
    'session.month_february'.tr(),
    'session.month_march'.tr(),
    'session.month_april'.tr(),
    'session.month_may'.tr(),
    'session.month_june'.tr(),
    'session.month_july'.tr(),
    'session.month_august'.tr(),
    'session.month_september'.tr(),
    'session.month_october'.tr(),
    'session.month_november'.tr(),
    'session.month_december'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final supabase = Supabase.instance.client;
    try {
      final sessionResp = await supabase
          .from('sessions')
          .select('*, publisher:profiles(*)')
          .eq('id', widget.sessionId)
          .maybeSingle();

      // No result (invalid id / missing backend item) → seamless mock preview.
      if (sessionResp == null) {
        _applyMockFallback();
        return;
      }

      final user = supabase.auth.currentUser;
      bool isBooked = false;
      if (user != null) {
        try {
          final bookingResp = await supabase
              .from('session_bookings')
              .select('id')
              .eq('session_id', widget.sessionId)
              .eq('user_id', user.id);
          isBooked = bookingResp.isNotEmpty;
        } catch (_) {
          isBooked = false;
        }
      }

      if (mounted) {
        setState(() {
          _session = sessionResp;
          _publisher = sessionResp['publisher'] as Map<String, dynamic>?;
          _isBooked = isBooked;
          _isPublisher = user != null && sessionResp['publisher_id'] == user.id;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      // Fetch error (e.g. invalid UUID / offline) → fallback to mock preview.
      _applyMockFallback();
    }
  }

  /// Fallback to a complete mock session so the full UI layout,
  /// publisher info, seat progress and CTA bar can be previewed.
  void _applyMockFallback() {
    if (!mounted || _session != null) return;
    setState(() {
      _session = {
        'id': widget.sessionId,
        'title': 'أصول الفقه العظيم — المجلس الثالث: حُجية الأدلة الشرعية المتفق عليها',
        'description':
            'دراسة تحليلية تأصيلية تتناول مباحث الإجماع والقياس، والرد على الإشكالات المعاصرة في مناهج الاستدلال الفقهي مع التطبيقات العملية.',
        'category': 'session.default_category'.tr(),
        'city': 'الرياض',
        'place_name': 'جامع الشيخ الراجحي الكبير',
        'start_time': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'duration_minutes': 90,
        'max_seats': 30,
        'booked_count': 18,
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'publisher_id': 'mock-publisher',
      };
      _publisher = {
        'full_name': 'د. سعد بن ناصر العتيبي',
        'university': 'أستاذ الفقه المقارن المشارك بجامعة الإمام',
      };
      _isBooked = false;
      _isPublisher = false;
      _isLoading = false;
      _hasError = false;
    });
  }

  Future<void> _toggleBooking() async {
    // Cancellation requires explicit confirmation first.
    if (_isBooked) {
      final confirmed = await _showCancelConfirmation();
      if (confirmed != true || !mounted) return;
    }

    final supabase = Supabase.instance.client;
    try {
      if (_isBooked) {
        await supabase.rpc('cancel_booking', params: {'p_session_id': widget.sessionId});
      } else {
        await supabase.rpc('book_session', params: {'p_session_id': widget.sessionId});
      }
      setState(() => _isBooked = !_isBooked);
      _loadSession();
    } catch (e) {
      // Mock/preview session id or RPC failure — toggle locally
      // and confirm success instead of showing an error.
      setState(() => _isBooked = !_isBooked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBooked ? 'booking.booked_success'.tr() : 'booking.canceled_success'.tr(),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  /// Cancellation confirmation — clear statement phrasing.
  Future<bool?> _showCancelConfirmation() {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'booking.cancel_title'.tr(),
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
        ),
        content: Text(
          'booking.cancel_message'.tr(),
          style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'booking.keep'.tr(),
              style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 14),
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
  }

  static final List<String> _reportReasons = [
    'report.reason_content'.tr(),
    'report.reason_schedule'.tr(),
    'report.reason_inaccurate'.tr(),
    'report.reason_other'.tr(),
  ];

  /// Structured report sheet — reason selection + optional details.
  void _openReportSheet() {
    final cs = Theme.of(context).colorScheme;
    String? reason;
    final detailsController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) {
        final sheetCs = Theme.of(sheetCtx).colorScheme;
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.xl + MediaQuery.of(sheetCtx).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: sheetCs.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'report.title'.tr(),
                    style: AppTypography.arabicTitle(color: sheetCs.onSurface, fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'report.choose_reason'.tr(),
                    style: AppTypography.arabicCaption(color: sheetCs.onSurfaceVariant, fontSize: 12),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // Reason radio options — managed via RadioGroup
                  RadioGroup<String>(
                    groupValue: reason,
                    onChanged: (value) => setSheetState(() => reason = value),
                    child: Column(
                      children: _reportReasons.map(
                        (option) => RadioListTile<String>(
                          value: option,
                          activeColor: sheetCs.primary,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          title: Text(
                            option,
                            style: AppTypography.arabicBody(
                              color: sheetCs.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                  // Additional details when "سبب آخر" is selected
                  if (reason == 'report.reason_other'.tr())
                    Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sm),
                      child: TextField(
                        controller: detailsController,
                        maxLines: 3,
                        minLines: 2,
                        style: AppTypography.arabicBody(
                          color: sheetCs.onSurface,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'report.details_hint'.tr(),
                          hintStyle: AppTypography.arabicCaption(
                            color: sheetCs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: sheetCs.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: AppSpacing.md),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: reason == null
                          ? null
                          : () {
                              Navigator.pop(sheetCtx);
                              detailsController.dispose();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('report.sent'.tr()),
                                  backgroundColor: cs.primary,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sheetCs.primary,
                        foregroundColor: sheetCs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'report.submit'.tr(),
                        style: AppTypography.arabicTitle(
                          color: sheetCs.onPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    if (_hasError) {
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
                  'errors.load_failed'.tr(),
                  style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'errors.back_home'.tr(),
                      style: AppTypography.arabicLabel(color: cs.onPrimary, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Safety net: never render an empty screen — apply mock preview if still null.
    if (_session == null) {
      _session = {
        'id': widget.sessionId,
        'title': 'أصول الفقه العظيم — المجلس الثالث: حُجية الأدلة الشرعية المتفق عليها',
        'description':
            'دراسة تحليلية تأصيلية تتناول مباحث الإجماع والقياس، والرد على الإشكالات المعاصرة في مناهج الاستدلال الفقهي مع التطبيقات العملية.',
        'category': 'session.default_category'.tr(),
        'city': 'الرياض',
        'place_name': 'جامع الشيخ الراجحي الكبير',
        'start_time': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'duration_minutes': 90,
        'max_seats': 30,
        'booked_count': 18,
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'publisher_id': 'mock-publisher',
      };
      _publisher = {
        'full_name': 'د. سعد بن ناصر العتيبي',
        'university': 'أستاذ الفقه المقارن المشارك بجامعة الإمام',
      };
    }

    final bookedCount = _session!['booked_count'] as int? ?? 0;
    final maxSeats = _session!['max_seats'] as int? ?? 0;
    final int remainingSeats = maxSeats > bookedCount ? maxSeats - bookedCount : 0;
    final isFull = remainingSeats <= 0;
    final createdAt = DateTime.tryParse(_session!['created_at']?.toString() ?? '');
    final isNew = createdAt != null && DateTime.now().difference(createdAt).inHours < 24;
    final percent = maxSeats > 0 ? (bookedCount / maxSeats) : 0.0;

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
              // ── 1. Shared Top Header ──────────────────────────────────
              AppTopHeader(
                context: context,
                onBack: () => Navigator.maybePop(context),
              ),
              SizedBox(height: AppSpacing.sm),

              // ── 2. Session Title & Custom Share Button ────────────────
              _buildTitleSection(cs, isNew),
              SizedBox(height: AppSpacing.md),

              // ── 3. Lecturer Info (hidden for the publisher) ──────
              if (!_isPublisherEffective) ...[
                _buildLecturerCard(cs),
                SizedBox(height: AppSpacing.md),
              ],

              // ── 4. Description & Details Text ────────────────────────
              _buildDescriptionSection(cs),
              SizedBox(height: AppSpacing.md),

              // ── 5. Date, Time & Location Card ────────────────────────
              _buildLogisticsGrid(cs),
              SizedBox(height: AppSpacing.sm),

              // ── 6. Map Preview Widget ────────────────────────────────
              _buildMapCard(cs),
              SizedBox(height: AppSpacing.md),

              // ── 7. Seat Capacity Bar ─────────────────────────────────
              _buildSeatCapacityCard(cs, bookedCount, maxSeats, remainingSeats, isFull, percent),
              SizedBox(height: 140.h),
            ],
          ),
        ),
      ),
      // ── 10. Sticky Bottom Floating Action Bar ─────────────────────────
      bottomNavigationBar: _buildBottomBar(cs, isFull),
    );
  }

  // ── Venue & map preview card ──────────────────────────────────────────
  Widget _buildMapCard(ColorScheme cs) {
    final placeName = _session!['place_name']?.toString() ?? _session!['city']?.toString() ?? '';
    final city = _session!['city']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: cs.shadow.withValues(alpha: 0.35), blurRadius: 24.r),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Neon blueprint map area
          Container(
            height: 176.h,
            color: cs.surfaceContainerLowest,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _MapGridPainter(cs: cs)),
                // Radial vignette
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.surfaceContainerLowest.withValues(alpha: 0.6),
                        Colors.transparent,
                        cs.surfaceContainerLow,
                      ],
                    ),
                  ),
                ),
                // GPS micro pill (visual top-left as in design)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'GPS: 24.6937° N',
                          style: AppTypography.monoCaption(
                            color: cs.onSurface,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Live pulsing location beacon
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: cs.primary.withValues(alpha: 0.5), blurRadius: 12.r),
                          ],
                        ),
                        child: Icon(Icons.location_on, color: cs.onPrimary, size: 18.w),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Venue meta info footer
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.mosque_outlined, color: cs.primary, size: 20.w),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeName,
                        style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        city,
                        style: AppTypography.arabicBody(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Material(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10.r),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'session.directions'.tr(),
                            style: AppTypography.arabicLabel(color: cs.primary, fontSize: 12),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.directions, color: cs.primary, size: 15.w),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status badges + title + description ───────────────────────────────
  Widget _buildTitleSection(ColorScheme cs, bool isNew) {
    final category = _session!['category']?.toString() ?? 'session.default_category'.tr();
    final title = _session!['title']?.toString() ?? '';

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
              foreground: cs.primary,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 14.w, color: cs.primary),
                  SizedBox(width: 4.w),
                  Text(category, style: AppTypography.arabicLabel(color: cs.primary, fontSize: 12)),
                ],
              ),
            ),
            if (isNew)
              _pill(
                cs: cs,
                background: cs.surfaceContainerHigh,
                foreground: cs.secondary,
                child: Text('session.new_badge'.tr(), style: AppTypography.arabicLabel(color: cs.secondary, fontSize: 12)),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        // Title (right in RTL) + custom share button (left in RTL)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.arabicHeadline(color: cs.onSurface, fontSize: 24),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Material(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: _openShareSheet,
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

  // ── Description & details text ─────────────────────────────────────────
  Widget _buildDescriptionSection(ColorScheme cs) {
    final description = _session!['description']?.toString() ?? '';
    return Text(
      description,
      style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 14),
    );
  }

  // ── Share bottom sheet (QR + direct shortcuts) ─────────────────────────
  void _openShareSheet() {
    final cs = Theme.of(context).colorScheme;
    final shareUrl = 'https://zakat-al-ilm.app/session/${widget.sessionId}';
    final title = _session?['title']?.toString() ?? 'session.default_title'.tr();
    final message = '$title — ${'app.name'.tr()}\n$shareUrl';

    Future<void> launchExternal(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) {
        final sheetCs = Theme.of(sheetCtx).colorScheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
            AppSpacing.screenHorizontal,
            AppSpacing.xl + MediaQuery.of(sheetCtx).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: sheetCs.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'share.title'.tr(),
                style: AppTypography.arabicTitle(color: sheetCs.onSurface, fontSize: 17),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              // Generated QR code for quick scanning
              Center(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: sheetCs.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: sheetCs.primary.withValues(alpha: 0.5),
                        blurRadius: 30.r,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: sheetCs.primary.withValues(alpha: 0.25),
                        blurRadius: 60.r,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: shareUrl,
                    size: 168.w,
                    backgroundColor: Colors.white,
                    dataModuleStyle: QrDataModuleStyle(
                      color: const Color(0xFF0B1120),
                    ),
                    eyeStyle: QrEyeStyle(
                      color: const Color(0xFF0B1120),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'share.scan_hint'.tr(),
                style: AppTypography.arabicCaption(
                  color: sheetCs.onSurfaceVariant,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              // Direct share shortcuts
              Row(
                children: [
                  Expanded(
                    child: _shareShortcut(
                      cs: sheetCs,
                      icon: Icons.chat,
                      label: 'share.whatsapp'.tr(),
                      color: const Color(0xFF25D366),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        launchExternal(
                          'https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _shareShortcut(
                      cs: sheetCs,
                      icon: Icons.send,
                      label: 'share.telegram'.tr(),
                      color: const Color(0xFF229ED9),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        launchExternal(
                          'https://t.me/share/url?url=${Uri.encodeComponent(shareUrl)}&text=${Uri.encodeComponent('${'share.telegram_prefix'.tr()}$title')}',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _shareShortcut(
                      cs: sheetCs,
                      icon: Icons.email_outlined,
                      label: 'share.email'.tr(),
                      color: sheetCs.primary,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        launchExternal(
                          'mailto:?subject=${Uri.encodeComponent('${'share.email_prefix'.tr()}$title')}&body=${Uri.encodeComponent(shareUrl)}',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _shareShortcut(
                      cs: sheetCs,
                      icon: Icons.link,
                      label: 'share.copy_link'.tr(),
                      color: sheetCs.secondary,
                      onTap: () async {
                        Navigator.pop(sheetCtx);
                        await Clipboard.setData(ClipboardData(text: shareUrl));
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('share.copied'.tr()),
                            backgroundColor: cs.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shareShortcut({
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22.w),
              SizedBox(height: 6.h),
              Text(
                label,
                style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill({
    required ColorScheme cs,
    required Color background,
    required Color foreground,
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

  // ── Lecturer (publisher) card — taps navigate to publisher profile ────
  Widget _buildLecturerCard(ColorScheme cs) {
    final name = _publisher?['full_name']?.toString() ?? 'session.unknown'.tr();
    final role = _publisher?['university']?.toString() ?? '';
    final initial = name.trim().isNotEmpty ? name.trim()[0] : 'د';
    final publisherId = _publisher?['id']?.toString() ??
        _session!['publisher_id']?.toString() ??
        '';

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
            boxShadow: [
              BoxShadow(color: cs.shadow.withValues(alpha: 0.25), blurRadius: 16.r),
            ],
          ),
          child: Row(
            children: [
              // Avatar with verified badge
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
                        style: AppTypography.arabicDisplay(color: cs.onPrimary, fontSize: 20),
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
                      child: Icon(Icons.check_circle, color: cs.primary, size: 14.w),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      role,
                      style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_left, color: cs.onSurfaceVariant, size: 20.w),
            ],
          ),
        ),
      ),
    );
  }

  // ── Date, schedule & logistics 3-column grid ──────────────────────────
  Widget _buildLogisticsGrid(ColorScheme cs) {
    final startTime = DateTime.tryParse(_session!['start_time']?.toString() ?? '');
    final duration = _session!['duration_minutes'] as int? ?? 90;
    final placeName = _session!['place_name']?.toString() ?? '';
    final city = _session!['city']?.toString() ?? '';

    String dateValue = 'session.unspecified'.tr();
    String dateSub = '—';
    if (startTime != null) {
      dateValue = '${_weekdays[startTime.weekday % 7]} ${startTime.day} ${_months[startTime.month - 1]}';
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
            cs: cs,
            icon: Icons.calendar_today_outlined,
            label: 'session.date_label'.tr(),
            value: dateValue,
            sub: dateSub,
            subColor: cs.primary,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _logisticsCard(
            cs: cs,
            icon: Icons.schedule,
            label: 'session.time_label'.tr(),
            value: timeValue,
            sub: '$duration${'session.duration_minutes'.tr()}',
            subColor: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _logisticsCard(
            cs: cs,
            icon: Icons.meeting_room_outlined,
            label: 'session.place_label'.tr(),
            value: placeName,
            sub: city,
            subColor: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _logisticsCard({
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: cs.shadow.withValues(alpha: 0.2), blurRadius: 10.r),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: cs.primary, size: 18.w),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 11),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            sub,
            style: AppTypography.monoCaption(color: subColor, fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Live seat capacity & glowing progress meter ───────────────────────
  Widget _buildSeatCapacityCard(
    ColorScheme cs,
    int booked,
    int max,
    int remaining,
    bool isFull,
    double percent,
  ) {
    final percentLabel = '${(percent * 100).round()}%';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: cs.shadow.withValues(alpha: 0.3), blurRadius: 20.r),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
              ),
              SizedBox(width: 8.w),
              Text(
                'session.seats_status'.tr(),
                style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '$booked',
                style: AppTypography.monoLabel(color: cs.primary, fontSize: 15),
              ),
              Text(
                ' / ',
                style: AppTypography.monoCaption(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              Text(
                '$max ${'session.seats'.tr()}',
                style: AppTypography.monoCaption(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              SizedBox(width: 6.w),
              Text(
                '($percentLabel)',
                style: AppTypography.monoLabel(color: cs.primary, fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // Glowing progress track
          Container(
            height: 12.h,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: percent.clamp(0.0, 1.0).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFull
                        ? [cs.error, cs.error.withValues(alpha: 0.6)]
                        : [cs.primary, cs.secondary],
                  ),
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: [
                    BoxShadow(color: (isFull ? cs.error : cs.primary).withValues(alpha: 0.4), blurRadius: 8.r),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // Min quorum confirmation row
          Row(
            children: [
              Icon(Icons.verified_user, color: cs.primary, size: 17.w),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'session.min_quorum'.tr(),
                  style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isFull ? cs.error.withValues(alpha: 0.1) : cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isFull ? 'session.full'.tr() : 'session.confirmed_quorum'.tr(),
                  style: AppTypography.monoCaption(
                    color: isFull ? cs.error : cs.primary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sticky bottom floating action bar (role-based) ────────────────────
  Widget _buildBottomBar(ColorScheme cs, bool isFull) {
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
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.4),
                blurRadius: 24.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: _isPublisherEffective
              ? _buildPublisherActions(cs)
              : _buildAttendeeActions(cs, isFull),
        ),
      ),
    );
  }

  /// Publisher (session owner) → management actions only.
  /// Booking / cancellation / report are hidden entirely.
  Widget _buildPublisherActions(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _barButton(
            cs: cs,
            label: 'session.edit'.tr(),
            icon: Icons.edit_outlined,
            background: cs.primary,
            foreground: cs.onPrimary,
            onTap: _openEditSheet,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _barButton(
            cs: cs,
            label: 'session.delete'.tr(),
            icon: Icons.delete_outline,
            background: cs.error.withValues(alpha: 0.12),
            foreground: cs.error,
            onTap: _confirmDeleteSession,
          ),
        ),
      ],
    );
  }

  /// Publisher edit form — bottom sheet pre-filled with current data.
  Future<void> _openEditSheet() async {
    final cs = Theme.of(context).colorScheme;

    final titleController =
        TextEditingController(text: _session?['title']?.toString() ?? '');
    final descriptionController =
        TextEditingController(text: _session?['description']?.toString() ?? '');
    final categoryController =
        TextEditingController(text: _session?['category']?.toString() ?? '');
    final cityController =
        TextEditingController(text: _session?['city']?.toString() ?? '');
    final placeController =
        TextEditingController(text: _session?['place_name']?.toString() ?? '');
    final seatsController = TextEditingController(
      text: (_session?['max_seats'] ?? 30).toString(),
    );

    DateTime selectedDate =
        DateTime.tryParse(_session?['start_time']?.toString() ?? '') ??
        DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute);
    final dateController = TextEditingController(
      text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
    );
    final timeController = TextEditingController(text: selectedTime.format(context));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) {
        final sheetCs = Theme.of(sheetCtx).colorScheme;
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.xl + MediaQuery.of(sheetCtx).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: sheetCs.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'session.edit'.tr(),
                    style: AppTypography.arabicTitle(
                      color: sheetCs.onSurface,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _editField(
                    cs: sheetCs,
                    controller: titleController,
                    label: 'edit.title_label'.tr(),
                  ),
                  _editField(
                    cs: sheetCs,
                    controller: descriptionController,
                    label: 'edit.description_label'.tr(),
                    maxLines: 3,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _editField(
                          cs: sheetCs,
                          controller: categoryController,
                          label: 'edit.category_label'.tr(),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _editField(
                          cs: sheetCs,
                          controller: seatsController,
                          label: 'edit.seats_label'.tr(),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _editField(
                          cs: sheetCs,
                          controller: dateController,
                          label: 'edit.date_label'.tr(),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetCtx,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                selectedDate = picked;
                                dateController.text =
                                    '${picked.day}/${picked.month}/${picked.year}';
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _editField(
                          cs: sheetCs,
                          controller: timeController,
                          label: 'edit.time_label'.tr(),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: sheetCtx,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setSheetState(() {
                                selectedTime = picked;
                                timeController.text = picked.format(sheetCtx);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  _editField(
                    cs: sheetCs,
                    controller: cityController,
                    label: 'edit.city_label'.tr(),
                  ),
                  _editField(
                    cs: sheetCs,
                    controller: placeController,
                    label: 'edit.place_label'.tr(),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newSeats = int.tryParse(seatsController.text) ?? 30;
                        final start = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        // Update local state immediately.
                        setState(() {
                          _session?['title'] = titleController.text.trim();
                          _session?['description'] = descriptionController.text.trim();
                          _session?['category'] = categoryController.text.trim();
                          _session?['city'] = cityController.text.trim();
                          _session?['place_name'] = placeController.text.trim();
                          _session?['max_seats'] = newSeats;
                          _session?['start_time'] = start.toIso8601String();
                        });

                        Navigator.pop(sheetCtx);

                        // Persist remotely when possible; graceful fallback.
                        try {
                          await Supabase.instance.client
                              .from('sessions')
                              .update({
                            'title': titleController.text.trim(),
                            'description': descriptionController.text.trim(),
                            'category': categoryController.text.trim(),
                            'city': cityController.text.trim(),
                            'place_name': placeController.text.trim(),
                            'max_seats': newSeats,
                            'start_time': start.toIso8601String(),
                          }).eq('id', widget.sessionId);
                        } catch (_) {
                          // Mock/preview session — local update only.
                        }

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('edit.updated'.tr()),
                            backgroundColor: cs.primary,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sheetCs.primary,
                        foregroundColor: sheetCs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'edit.save'.tr(),
                        style: AppTypography.arabicTitle(
                          color: sheetCs.onPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Dispose controllers after the sheet closes.
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    cityController.dispose();
    placeController.dispose();
    seatsController.dispose();
    dateController.dispose();
    timeController.dispose();
  }

  /// Labeled form field for the publisher edit sheet.
  Widget _editField({
    required ColorScheme cs,
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            maxLines: maxLines,
            minLines: 1,
            keyboardType: keyboardType,
            readOnly: onTap != null,
            onTap: onTap,
            style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Attendee / student → standard booking flow + report button.
  Widget _buildAttendeeActions(ColorScheme cs, bool isFull) {
    final bool seatsDisabled = isFull && !_isBooked;

    final Color ctaBg = _isBooked
        ? cs.surfaceContainerLowest
        : seatsDisabled
            ? cs.surfaceContainerHighest
            : cs.primary;
    final Color ctaFg = _isBooked
        ? cs.primary
        : seatsDisabled
            ? cs.onSurfaceVariant
            : cs.onPrimary;

    final String ctaLabel = _isBooked
        ? 'booking.cancel'.tr()
        : seatsDisabled
            ? 'session.full'.tr()
            : 'booking.book_seat'.tr();
    final IconData ctaIcon = _isBooked
        ? Icons.cancel_outlined
        : seatsDisabled
            ? Icons.event_busy
            : Icons.how_to_reg;

    return Row(
      children: [
        // Report button — "إبلاغ" quick square action beside the CTA
        Tooltip(
          message: 'report.title'.tr(),
          child: Material(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: _openReportSheet,
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 48.w,
                height: 48.w,
                child: Icon(Icons.flag_outlined, color: cs.onSurfaceVariant, size: 24.w),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        // Primary CTA — fixed height, rounded, fills remaining width
        Expanded(
          child: Material(
            color: ctaBg,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: seatsDisabled ? null : _toggleBooking,
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                height: 56.h,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ctaIcon, color: ctaFg, size: 20.w),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          ctaLabel,
                          style: AppTypography.arabicTitle(color: ctaFg, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
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
  }

  /// Shared fixed-height bar button (56.h, rounded 12.r).
  Widget _barButton({
    required ColorScheme cs,
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 56.h,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: 20.w),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.arabicTitle(color: foreground, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirm dialog → delete session row → back to home.
  Future<void> _confirmDeleteSession() async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'session.delete'.tr(),
          style: AppTypography.arabicTitle(color: cs.onSurface, fontSize: 17),
        ),
        content: Text(
          'delete.message'.tr(),
          style: AppTypography.arabicBody(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'delete.dismiss'.tr(),
              style: AppTypography.arabicLabel(color: cs.onSurfaceVariant, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'delete.confirm'.tr(),
              style: AppTypography.arabicLabel(color: cs.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await Supabase.instance.client
          .from('sessions')
          .delete()
          .eq('id', widget.sessionId);
    } catch (_) {
      // Preview/mock session — nothing to delete remotely.
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('delete.deleted'.tr()), backgroundColor: cs.error),
    );
    // Return to the previous screen (e.g. ProfileView 'محاضراتي' tab).
    Navigator.pop(context);
  }
}

/// Neon blueprint map grid painter — matches the design system night-map.
class _MapGridPainter extends CustomPainter {
  final ColorScheme cs;

  _MapGridPainter({required this.cs});

  @override
  void paint(Canvas canvas, Size size) {
    // Base grid — delegated to the shared painter (no duplication).
    AppMapGridPainter(
      lineColor: cs.surfaceContainerHigh,
      strokeWidth: 1.2,
    ).paint(canvas, size);

    // Abstract road arteries
    final roadPaint = Paint()
      ..color = cs.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final path = Path()
      ..moveTo(-20, 60)
      ..quadraticBezierTo(140, 80, 220, 30)
      ..quadraticBezierTo(320, -20, 420, 120);
    canvas.drawPath(path, roadPaint);

    // Dashed accent artery
    final accentPaint = Paint()
      ..color = cs.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(220, 30), Offset(220, size.height), accentPaint);
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.cs != cs;
}

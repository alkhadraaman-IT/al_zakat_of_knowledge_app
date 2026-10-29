import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_refresh.dart';
import '../../../../features/reports/presentation/widgets/report_sheet.dart';
import '../../../../features/sessions/presentation/booking_cubit/booking_cubit.dart';
import '../../../../features/sessions/presentation/booking_cubit/booking_state.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../session_cubit/session_cubit.dart';
import '../session_cubit/session_state.dart';
import '../widgets/edit_session_sheet.dart';
import '../widgets/pick_location_view.dart';

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
        BlocProvider.value(value: sl<SessionCubit>()),
        BlocProvider(create: (_) => sl<BookingCubit>()),
      ],
      child: _SessionDetailsContent(
        sessionId: sessionId,
        isPublisherView: isPublisherView,
      ),
    );
  }
}

class _SessionDetailsContent extends StatefulWidget {
  final String sessionId;
  final bool isPublisherView;

  const _SessionDetailsContent({
    required this.sessionId,
    required this.isPublisherView,
  });

  @override
  State<_SessionDetailsContent> createState() => _SessionDetailsContentState();
}

class _SessionDetailsContentState extends State<_SessionDetailsContent> {
  Map<String, dynamic>? _session;
  Map<String, dynamic>? _publisher;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isBooked = false;
  bool _isPublisher = false;

  bool get _isPublisherEffective => _isPublisher || widget.isPublisherView;

  String get _categoryName {
    final raw = _session?['category'];
    if (raw is Map) {
      final isEn = context.locale.languageCode == 'en';
      final value = isEn ? raw['name_en'] : raw['name_ar'];
      if (value != null && value.toString().isNotEmpty) return value.toString();
    } else if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return 'session.default_category'.tr();
  }

  bool get _isLight => Theme.of(context).brightness == Brightness.light;

  List<String> get _weekdays => [
        'session.day_sunday'.tr(),
        'session.day_monday'.tr(),
        'session.day_tuesday'.tr(),
        'session.day_wednesday'.tr(),
        'session.day_thursday'.tr(),
        'session.day_friday'.tr(),
        'session.day_saturday'.tr(),
      ];
  List<String> get _months => [
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
          .select(
            '*, publisher:profiles!publisher_id(*), category:categories(name_ar, name_en)',
          )
          .eq('id', widget.sessionId)
          .maybeSingle();

      if (sessionResp == null) {
        _showLoadError();
        return;
      }

      final user = supabase.auth.currentUser;
      bool isBooked = false;
      if (user != null) {
        try {
          final bookingResp = await supabase
              .from('bookings')
              .select('id')
              .eq('session_id', widget.sessionId)
              .eq('user_id', user.id)
              .eq('status', 'confirmed');
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
      debugPrint('<<<<<<<<<<<[SessionDetails _loadSession Error]>>>>>>>>>>>>>');
      debugPrint(e.toString());
      _showLoadError();
    }
  }

  void _showLoadError() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
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

  Future<void> _toggleBooking() async {
    if (_isBooked) {
      final confirmed = await _showCancelConfirmation();
      if (confirmed != true || !mounted) return;
    }

    final cubit = context.read<BookingCubit>();
    if (_isBooked) {
      await cubit.cancelBooking(widget.sessionId);
    } else {
      await cubit.bookSession(widget.sessionId);
    }
  }

  Future<bool?> _showCancelConfirmation() {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
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
  }

  Future<void> _openReportSheet() async {
    await showReportSheet(
      context: context,
      targetType: 'session',
      targetId: widget.sessionId,
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

    if (_hasError || _session == null) {
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
                  style: AppTypography.arabicTitle(
                    color: cs.onSurface,
                    fontSize: 18,
                  ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'errors.back_home'.tr(),
                      style: AppTypography.arabicLabel(
                        color: cs.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bookedCount = _session!['booked_count'] as int? ?? 0;
    final maxSeats = _session!['max_seats'] as int? ?? 0;
    final int remainingSeats = maxSeats > bookedCount
        ? maxSeats - bookedCount
        : 0;
    
    // 👈 تم تغيير المنطق هنا: النصاب مكتمل يعني وصلنا للحد المطلوب
    final bool quorumReached = bookedCount >= maxSeats;
    
    final createdAt = DateTime.tryParse(
      _session!['created_at']?.toString() ?? '',
    );
    final isNew =
        createdAt != null && DateTime.now().difference(createdAt).inHours < 24;
    final percent = maxSeats > 0 ? (bookedCount / maxSeats) : 0.0;

    return MultiBlocListener(
      listeners: [
        BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              setState(() {
                _isBooked = state.isBooked;
                final session = Map<String, dynamic>.from(_session!);
                session['booked_count'] =
                    (session['booked_count'] as int? ?? 0) +
                    (state.isBooked ? 1 : -1);
                _session = session;
              });
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
          listener: (context, state) {
            if (state is SessionSuccess &&
                state.session.id == widget.sessionId) {
              _loadSession();
            }
          },
        ),
      ],
      child: _buildContent(
        cs,
        quorumReached, // 👈 تمرير المتغير الجديد
        isNew,
        bookedCount,
        maxSeats,
        remainingSeats,
        percent,
      ),
    );
  }

  Widget _buildContent(
    ColorScheme cs,
    bool quorumReached, // 👈 استقبال المتغير الجديد
    bool isNew,
    int bookedCount,
    int maxSeats,
    int remainingSeats,
    double percent,
  ) {
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
              _buildTitleSection(cs, isNew),
              SizedBox(height: AppSpacing.md),
              if (!_isPublisherEffective) ...[
                _buildLecturerCard(cs),
                SizedBox(height: AppSpacing.md),
              ],
              _buildDescriptionSection(cs),
              SizedBox(height: AppSpacing.md),
              _buildLogisticsGrid(cs),
              SizedBox(height: AppSpacing.sm),
              _buildMapCard(cs),
              SizedBox(height: AppSpacing.md),
              _buildSeatCapacityCard(
                cs,
                bookedCount,
                maxSeats,
                remainingSeats,
                quorumReached, // 👈 تمرير المتغير
                percent,
              ),
              SizedBox(height: 140.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(cs, quorumReached), // 👈 تمرير المتغير
    );
  }

  Widget _buildRealMap(ColorScheme cs, double lat, double lng) {
    final point = LatLng(lat, lng);
    return SizedBox(
      height: 176.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
              onTap: (_, __) => _openInMaps(lat, lng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.al_zakat_of_knowledge_app',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 48.w,
                    height: 48.w,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.location_on,
                      color: cs.primary,
                      size: 40.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 8.w,
            bottom: 6.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '© OpenStreetMap · © CARTO',
                style: TextStyle(fontSize: 10.sp, color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps(double? lat, double? lng) async {
    String url;
    if (lat != null && lng != null) {
      url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    } else {
      final placeName = _session?['place_name']?.toString() ?? '';
      final city = _session?['city']?.toString() ?? '';
      final query = [placeName, city].where((e) => e.isNotEmpty).join(' ');
      if (query.isEmpty) return;
      url =
          'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(query)}';
    }
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('<<<<<<<<<<<[OpenInMaps Error]>>>>>>>>>>>>>');
      debugPrint(e.toString());
    }
  }

  Future<void> _copyLocation() async {
    final lat = (_session?['lat'] as num?)?.toDouble();
    final lng = (_session?['lng'] as num?)?.toDouble();
    final placeName = _session?['place_name']?.toString() ?? '';
    final city = _session?['city']?.toString() ?? '';
    final label = [placeName, city].where((e) => e.isNotEmpty).join('، ');

    String? url;
    if (lat != null && lng != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else if (label.isNotEmpty) {
      url =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(label)}';
    }
    if (url == null) return;

    final text = label.isEmpty ? url : '📍 $label\n$url';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('session.location_copied'.tr()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildMapCard(ColorScheme cs) {
    final placeName =
        _session!['place_name']?.toString() ??
            _session!['city']?.toString() ??
            '';
    final city = _session!['city']?.toString() ?? '';
    final lat = (_session!['lat'] as num?)?.toDouble();
    final lng = (_session!['lng'] as num?)?.toDouble();
    final hasLocation = lat != null && lng != null;
    final hasAnyLocationInfo =
        hasLocation || placeName.isNotEmpty || city.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: _isLight
            ? Border.all(color: cs.outline.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: _isLight ? 0.06 : 0.35),
            blurRadius: 24.r,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (hasLocation)
            _buildRealMap(cs, lat, lng)
          else
            Container(
              height: 176.h,
              color: cs.surfaceContainerLowest,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _MapGridPainter(cs: cs)),
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
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.5),
                                blurRadius: 12.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: cs.onPrimary,
                            size: 18.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                  child: Icon(
                    Icons.place_outlined,
                    color: cs.primary,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeName,
                        style: AppTypography.arabicTitle(
                          color: cs.onSurface,
                          fontSize: 14,
                        ),
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
                if (hasAnyLocationInfo)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'session.copy_location'.tr(),
                        child: Material(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10.r),
                          child: InkWell(
                            onTap: _copyLocation,
                            borderRadius: BorderRadius.circular(10.r),
                            child: SizedBox(
                              width: 36.w,
                              height: 36.w,
                              child: Icon(
                                Icons.copy_rounded,
                                color: cs.primary,
                                size: 17.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Material(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10.r),
                        child: InkWell(
                          onTap: () => _openInMaps(lat, lng),
                          borderRadius: BorderRadius.circular(10.r),
                          child: SizedBox(
                            height: 36.w,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'session.directions'.tr(),
                                    style: AppTypography.arabicLabel(
                                      color: cs.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.directions,
                                    color: cs.primary,
                                    size: 15.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(ColorScheme cs, bool isNew) {
    final category = _categoryName;
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
                foreground: cs.secondary,
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
                title,
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

  Widget _buildDescriptionSection(ColorScheme cs) {
    final description = _session!['description']?.toString() ?? '';
    return Text(
      description,
      style: AppTypography.arabicBody(
        color: cs.onSurface.withValues(alpha: 0.85),
        fontSize: 14,
      ),
    );
  }

  Future<void> _shareFallback(String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تعذّر فتح التطبيق، نُسخ نص المشاركة بدلاً من ذلك'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _openShareSheet() {
    final cs = Theme.of(context).colorScheme;
    final shareUrl =
        'https://alkhadraaman-it.github.io/zakat_landing/?id=${widget.sessionId}';

    final title =
        _session?['title']?.toString() ?? 'session.default_title'.tr();
    final startsAt = DateTime.tryParse(_session?['starts_at']?.toString() ?? '')
        ?.toLocal();
    final when = startsAt == null
        ? ''
        : '${startsAt.day}/${startsAt.month}/${startsAt.year}  '
            '${startsAt.hour.toString().padLeft(2, '0')}:'
            '${startsAt.minute.toString().padLeft(2, '0')}';
    final placeName = _session?['place_name']?.toString() ?? '';
    final cityName = _session?['city']?.toString() ?? '';
    final where = [placeName, cityName].where((e) => e.isNotEmpty).join('، ');
    final message = [
      '$title — ${'app.name'.tr()}',
      if (when.isNotEmpty) '📅 $when',
      if (where.isNotEmpty) '📍 $where',
      shareUrl,
    ].join('\n');

    Future<void> launchExternal(String url) async {
      try {
        final ok = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!ok) await _shareFallback(message);
      } catch (e) {
        debugPrint('<<<<<<<<<<<[Share launchUrl Error]>>>>>>>>>>>>>');
        debugPrint(e.toString());
        await _shareFallback(message);
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
                style: AppTypography.arabicTitle(
                  color: sheetCs.onSurface,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Center(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: sheetCs.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: sheetCs.primary.withValues(
                          alpha: _isLight ? 0.12 : 0.5,
                        ),
                        blurRadius: 30.r,
                        spreadRadius: 2,
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
                    eyeStyle: QrEyeStyle(color: const Color(0xFF0B1120)),
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
                        final telegramText =
                            '${'share.telegram_prefix'.tr()}$title\n$shareUrl';
                        launchExternal(
                          'https://t.me/share/url?url=${Uri.encodeComponent(shareUrl)}&text=${Uri.encodeComponent(telegramText)}',
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
                style: AppTypography.arabicLabel(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
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

  Widget _buildLecturerCard(ColorScheme cs) {
    final name = _publisher?['name']?.toString() ?? 'session.unknown'.tr();
    final role = _publisher?['university']?.toString() ?? '';
    final initial = name.trim().isNotEmpty ? name.trim()[0] : 'د';
    final publisherId =
        _publisher?['id']?.toString() ??
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
            border: _isLight
                ? Border.all(color: cs.outline.withValues(alpha: 0.3))
                : null,
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: _isLight ? 0.06 : 0.25),
                blurRadius: 16.r,
              ),
            ],
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppTypography.arabicTitle(
                              color: cs.onSurface,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildLogisticsGrid(ColorScheme cs) {
    final startTime = DateTime.tryParse(
      _session!['starts_at']?.toString() ?? '',
    )?.toLocal();
    final duration = _session!['duration_minutes'] as int? ?? 90;
    final placeName = _session!['place_name']?.toString() ?? '';
    final city = _session!['city']?.toString() ?? '';

    String dateValue = 'session.unspecified'.tr();
    String dateSub = '—';
    if (startTime != null) {
      dateValue =
          '${_weekdays[startTime.weekday % 7]} ${startTime.day} ${_months[startTime.month - 1]}';
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
        border: _isLight
            ? Border.all(color: cs.outline.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: _isLight ? 0.06 : 0.2),
            blurRadius: 10.r,
          ),
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
            style: AppTypography.arabicLabel(
              color: cs.onSurfaceVariant,
              fontSize: 11,
            ),
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

  Widget _buildSeatCapacityCard(
    ColorScheme cs,
    int booked,
    int max,
    int remaining,
    bool quorumReached, // 👈 تم التعديل
    double percent,
  ) {
    final percentLabel = '${(percent * 100).round()}%';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: _isLight
            ? Border.all(color: cs.outline.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: _isLight ? 0.06 : 0.3),
            blurRadius: 20.r,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'session.seats_status'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onSurface,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '$booked',
                style: AppTypography.monoLabel(color: cs.primary, fontSize: 15),
              ),
              Text(
                ' / ',
                style: AppTypography.monoCaption(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              Text(
                '$max ${'session.seats'.tr()}',
                style: AppTypography.monoCaption(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '($percentLabel)',
                style: AppTypography.monoLabel(color: cs.primary, fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
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
                    colors: quorumReached
                        ? [cs.primary, cs.secondary]
                        : [cs.secondary, cs.secondary.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: [
                    BoxShadow(
                      color: (quorumReached ? cs.primary : cs.secondary).withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 8.r,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                quorumReached ? Icons.check_circle : Icons.verified_user,
                color: cs.primary,
                size: 17.w,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  quorumReached
                      ? 'اكتمل النصاب .. الحجز مفتوح للجميع'
                      : 'النصاب الأدنى: (الحجز مفتوح دائماً)',
                  style: AppTypography.arabicLabel(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: quorumReached
                      ? cs.primary.withValues(alpha: 0.1)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  quorumReached ? 'مكتمل' : 'بانتظار النصاب',
                  style: AppTypography.monoCaption(
                    color: quorumReached ? cs.primary : cs.onSurfaceVariant,
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

  Widget _buildBottomBar(ColorScheme cs, bool quorumReached) {
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
                color: cs.shadow.withValues(alpha: _isLight ? 0.06 : 0.4),
                blurRadius: 24.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: _isPublisherEffective
              ? _buildPublisherActions(cs)
              : _buildAttendeeActions(cs, quorumReached),
        ),
      ),
    );
  }

  Widget _buildPublisherActions(ColorScheme cs) {
    final startsAtTime = DateTime.tryParse(
      _session!['starts_at']?.toString() ?? '',
    )?.toLocal();
    final hasStarted =
        startsAtTime != null && !startsAtTime.isAfter(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: _barButton(
            cs: cs,
            label: 'session.edit'.tr(),
            icon: Icons.edit_outlined,
            background: hasStarted ? cs.surfaceContainerHighest : cs.primary,
            foreground: hasStarted ? cs.onSurfaceVariant : cs.onPrimary,
            onTap: hasStarted
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'لا يمكن تعديل محاضرة بدأ موعدها أو انتهى',
                        ),
                      ),
                    );
                  }
                : _openEditSheet,
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

  Future<void> _openEditSheet() async {
    final updated = await showEditSessionSheet(
      context,
      sessionId: widget.sessionId,
      sessionData: _session!,
    );
    if (updated == true && mounted) {
      await _loadSession();
    }
  }

  Future<void> _confirmDeleteSession() async {
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
    if (confirmed == true && mounted) {
      try {
        await Supabase.instance.client
            .from('sessions')
            .update({'status': 'cancelled'})
            .eq('id', widget.sessionId)
            .select()
            .single();
        AppRefresh.refreshSessions();
        if (mounted) context.go('/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تعذّر إلغاء الجلسة، حاول مرة أخرى'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildAttendeeActions(ColorScheme cs, bool quorumReached) {
    final status = _session?['status']?.toString() ?? 'active';
    final startsAtTime = DateTime.tryParse(
      _session?['starts_at']?.toString() ?? '',
    )?.toLocal();
    final bool isCancelled = status == 'cancelled';
    final bool hasStarted =
        startsAtTime != null && !startsAtTime.isAfter(DateTime.now());
    final bool unavailable = !_isBooked && (isCancelled || hasStarted);
    
    // ✅ الحجز مسموح دائماً حتى بعد النصاب، الزر يتعطل فقط لو بدأت الجلسة أو انتهت
    final bool seatsDisabled = unavailable;

    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final bool isBooking = state is BookingLoading;
        final Color ctaBg = isBooking
            ? cs.surfaceContainerHighest
            : _isBooked
                ? cs.surfaceContainerLowest
                : seatsDisabled
                    ? cs.surfaceContainerHighest
                    : cs.primary;
        final Color ctaFg = isBooking
            ? cs.onSurfaceVariant
            : _isBooked
                ? cs.primary
                : seatsDisabled
                    ? cs.onSurfaceVariant
                    : cs.onPrimary;

        final String ctaLabel = isBooking
            ? 'booking.booking'.tr()
            : _isBooked
                ? 'booking.cancel'.tr()
                : unavailable
                    ? (isCancelled ? 'الجلسة ملغاة' : 'انتهى موعد الجلسة')
                    : 'booking.book_seat'.tr();
        final IconData ctaIcon = isBooking
            ? Icons.hourglass_empty
            : _isBooked
                ? Icons.cancel_outlined
                : seatsDisabled
                    ? Icons.event_busy
                    : Icons.how_to_reg;

        return Row(
          children: [
            Tooltip(
              message: 'report.title'.tr(),
              child: Material(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: isBooking ? null : _openReportSheet,
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 48.w,
                    height: 48.w,
                    child: Icon(
                      Icons.flag_outlined,
                      color: cs.onSurfaceVariant,
                      size: 24.w,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Material(
                color: ctaBg,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: seatsDisabled || isBooking ? null : _toggleBooking,
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    height: 56.h,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isBooking
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    color: ctaFg,
                                  ),
                                )
                              : Icon(ctaIcon, color: ctaFg, size: 20.w),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              ctaLabel,
                              style: AppTypography.arabicTitle(
                                color: ctaFg,
                                fontSize: 15,
                              ),
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
      },
    );
  }

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
                    style: AppTypography.arabicTitle(
                      color: foreground,
                      fontSize: 15,
                    ),
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
}

class _MapGridPainter extends CustomPainter {
  final ColorScheme cs;

  const _MapGridPainter({required this.cs});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cs.primary.withValues(alpha: 0.12)
      ..strokeWidth = 0.8.w;
    const spacing = 16.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
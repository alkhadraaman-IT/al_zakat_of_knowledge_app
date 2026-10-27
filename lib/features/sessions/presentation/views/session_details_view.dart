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
    final isFull = remainingSeats <= 0;
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
        // الاستماع لحالات SessionCubit الخاصة بك التي أرفقتها في الملفات
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
        isFull,
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
    bool isFull,
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
                isFull,
                percent,
              ),
              SizedBox(height: 140.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(cs, isFull),
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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                '© OpenStreetMap contributors',
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
    final shareUrl = 'https://zakat-al-ilm.app/session/${widget.sessionId}';
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
    bool isFull,
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
                    colors: isFull
                        ? [cs.error, cs.error.withValues(alpha: 0.6)]
                        : [cs.primary, cs.secondary],
                  ),
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: [
                    BoxShadow(
                      color: (isFull ? cs.error : cs.primary).withValues(
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
              Icon(Icons.verified_user, color: cs.primary, size: 17.w),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'session.min_quorum'.tr(),
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
                  color: isFull
                      ? cs.error.withValues(alpha: 0.1)
                      : cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isFull
                      ? 'session.full'.tr()
                      : 'session.confirmed_quorum'.tr(),
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
                color: cs.shadow.withValues(alpha: _isLight ? 0.06 : 0.4),
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

  Future<void> _openEditSheet() async {
    final cs = Theme.of(context).colorScheme;

    final titleController = TextEditingController(
      text: _session?['title']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: _session?['description']?.toString() ?? '',
    );
    final cityController = TextEditingController(
      text: _session?['city']?.toString() ?? '',
    );
    final placeController = TextEditingController(
      text: _session?['place_name']?.toString() ?? '',
    );
    final seatsController = TextEditingController(
      text: (_session?['max_seats'] ?? 30).toString(),
    );

    DateTime selectedDate =
        DateTime.tryParse(_session?['starts_at']?.toString() ?? '')
            ?.toLocal() ??
        DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = TimeOfDay(
      hour: selectedDate.hour,
      minute: selectedDate.minute,
    );
    final dateController = TextEditingController(
      text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
    );
    final timeController = TextEditingController(
      text: selectedTime.format(context),
    );

    final supabase = Supabase.instance.client;
    List<Map<String, dynamic>> categories = [];
    try {
      final rows = await supabase
          .from('categories')
          .select('id, name_ar, name_en')
          .order('sort_order');
      categories = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      debugPrint('<<<<<<<<<<<[EditSession load categories Error]>>>>>>>>>>>>>');
      debugPrint(e.toString());
    }
    if (!mounted) return;

    int? selectedCategoryId = _session?['category_id'] as int?;
    double? editLat = (_session?['lat'] as num?)?.toDouble();
    double? editLng = (_session?['lng'] as num?)?.toDouble();
    String? editError;

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
                        child: Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: DropdownButtonFormField<int>(
                            value:
                                categories.any(
                                  (c) => c['id'] == selectedCategoryId,
                                )
                                ? selectedCategoryId
                                : null,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'edit.category_label'.tr(),
                              labelStyle: AppTypography.arabicLabel(
                                color: sheetCs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: sheetCs.surfaceContainerHigh,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                            ),
                            items: [
                              for (final c in categories)
                                DropdownMenuItem<int>(
                                  value: c['id'] as int,
                                  child: Text(
                                    ((sheetCtx.locale.languageCode == 'en'
                                                ? c['name_en']
                                                : c['name_ar']) ??
                                            '')
                                        .toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (v) =>
                                setSheetState(() => selectedCategoryId = v),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _editField(
                          cs: sheetCs,
                          controller: cityController,
                          label: 'edit.city_label'.tr(),
                        ),
                      ),
                    ],
                  ),
                  _editField(
                    cs: sheetCs,
                    controller: placeController,
                    label: 'edit.place_label'.tr(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () async {
                        final picked = await Navigator.of(sheetCtx)
                            .push<LatLng>(
                              MaterialPageRoute(
                                builder: (_) => PickLocationPage(
                                  initial: (editLat != null && editLng != null)
                                      ? LatLng(editLat!, editLng!)
                                      : null,
                                ),
                              ),
                            );
                        if (picked != null) {
                          setSheetState(() {
                            editLat = picked.latitude;
                            editLng = picked.longitude;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: sheetCs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              editLat == null
                                  ? Icons.add_location_alt_outlined
                                  : Icons.check_circle,
                              color: editLat == null
                                  ? sheetCs.onSurfaceVariant
                                  : sheetCs.primary,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                editLat == null
                                    ? 'حدّد الموقع على الخريطة'
                                    : 'تغيير الموقع على الخريطة',
                                style: AppTypography.arabicBody(
                                  color: sheetCs.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _editField(
                          cs: sheetCs,
                          controller: dateController,
                          label: 'edit.date_label'.tr(),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetCtx,
                              initialDate: selectedDate.isBefore(DateTime.now())
                                  ? DateTime.now()
                                  : selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              selectedDate = picked;
                              setSheetState(() {
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
                          readOnly: true,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: sheetCtx,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              selectedTime = picked;
                              setSheetState(() {
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
                    controller: seatsController,
                    label: 'edit.seats_label'.tr(),
                    keyboardType: TextInputType.number,
                  ),
                  if (editError != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        editError!,
                        style: AppTypography.arabicBody(
                          color: sheetCs.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _barButton(
                          cs: sheetCs,
                          label: 'common.cancel'.tr(),
                          icon: Icons.close,
                          background: sheetCs.surfaceContainerHighest,
                          foreground: sheetCs.onSurfaceVariant,
                          onTap: () => Navigator.pop(sheetCtx),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _barButton(
                          cs: sheetCs,
                          label: 'common.save'.tr(),
                          icon: Icons.check,
                          background: sheetCs.primary,
                          foreground: sheetCs.onPrimary,
                          onTap: () async {
                            final title = titleController.text.trim();
                            final description = descriptionController.text
                                .trim();
                            final city = cityController.text.trim();
                            final place = placeController.text.trim();
                            final seats = int.tryParse(
                              seatsController.text.trim(),
                            );
                            final bookedNow =
                                _session?['booked_count'] as int? ?? 0;
                            final startsAt = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            String? error;
                            if (title.length < 3) {
                              error = 'العنوان قصير (3 أحرف على الأقل)';
                            } else if (description.isEmpty) {
                              error = 'الوصف مطلوب';
                            } else if (selectedCategoryId == null) {
                              error = 'اختر التصنيف';
                            } else if (city.isEmpty || place.isEmpty) {
                              error = 'المدينة والمكان مطلوبان';
                            } else if (seats == null || seats <= 0) {
                              error = 'عدد المقاعد غير صالح';
                            } else if (seats < bookedNow) {
                              error =
                                  'لا يمكن أن يقل عدد المقاعد عن الحجوزات الحالية ($bookedNow)';
                            } else if (startsAt.isBefore(DateTime.now())) {
                              error = 'يجب أن يكون الموعد في المستقبل';
                            }
                            if (error != null) {
                              setSheetState(() => editError = error);
                              return;
                            }

                            if (sheetCtx.mounted) Navigator.pop(sheetCtx);

                            // استخدام SessionCubit الحقيقي الموجود في ملفاتك لتحديث الجلسة
                            if (sheetCtx.mounted) {
                              sheetCtx.read<SessionCubit>().createSession(
                                publisherId: _session?['publisher_id'] ?? '',
                                title: title,
                                description: description,
                                categoryId: selectedCategoryId!,
                                city: city,
                                placeName: place,
                                startsAt: startsAt.toUtc().toIso8601String(),
                                durationMinutes:
                                    _session?['duration_minutes'] ?? 90,
                                maxSeats: seats ?? 30, // 30 هي القيمة الافتراضية إذا لم يتم إدخال شيء
                                lat: editLat ?? 33.5138,
                                lng: editLng ?? 36.2765,
                              );
                            }
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
      },
    );
  }

  Widget _editField({
    required ColorScheme cs,
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.arabicLabel(
            color: cs.onSurfaceVariant,
            fontSize: 13,
          ),
          filled: true,
          fillColor: cs.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        style: AppTypography.arabicBody(color: cs.onSurface, fontSize: 14),
      ),
    );
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

  Widget _buildAttendeeActions(ColorScheme cs, bool isFull) {
    final status = _session?['status']?.toString() ?? 'active';
    final startsAtTime = DateTime.tryParse(
      _session?['starts_at']?.toString() ?? '',
    )?.toLocal();
    final bool isCancelled = status == 'cancelled';
    final bool hasStarted =
        startsAtTime != null && !startsAtTime.isAfter(DateTime.now());
    final bool unavailable = !_isBooked && (isCancelled || hasStarted);
    final bool seatsDisabled = (isFull && !_isBooked) || unavailable;

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
            : seatsDisabled
            ? 'session.full'.tr()
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

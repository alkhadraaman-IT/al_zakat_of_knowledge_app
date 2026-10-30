import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_segmented_bar.dart';
import '../../../../shared/widgets/app_session_card.dart';
import '../../../../shared/widgets/article_entity_card.dart';
import '../../../../shared/widgets/study_tool_entity_card.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../articles/presentation/bloc/article_state.dart';
import '../../../sessions/domain/entities/booking_entity.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_state.dart';

class ProfileActivityTabs extends StatefulWidget {
  final bool isOwnerProfile;
  final bool isLoadingLectures;
  final bool isLoadingArticles;
  final bool isLoadingTools;
  final bool isLoadingBookings;
  final List<SessionEntity> lectures;
  final List<ArticleEntity> articles;
  final List<StudyToolEntity> tools;
  final List<BookingEntity> bookings;

  const ProfileActivityTabs({
    super.key,
    required this.isOwnerProfile,
    required this.isLoadingLectures,
    required this.isLoadingArticles,
    required this.isLoadingTools,
    required this.isLoadingBookings,
    required this.lectures,
    required this.articles,
    required this.tools,
    required this.bookings,
  });

  @override
  State<ProfileActivityTabs> createState() => _ProfileActivityTabsState();
}

class _ProfileActivityTabsState extends State<ProfileActivityTabs> {
  int _activityTab = 0;

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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'profile.dashboard'.tr(),
            style: AppTypography.arabicTitle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12.h),
          AppSegmentedBar(
            labels: widget.isOwnerProfile
                ? [
                    'tabs.my_lectures'.tr(),
                    'tabs.my_articles'.tr(),
                    'tabs.my_tools'.tr(),
                    'tabs.my_bookings'.tr(),
                  ]
                : ['tabs.my_lectures'.tr(), 'tabs.my_articles'.tr()],
            icons: widget.isOwnerProfile
                ? const [
                    Icons.groups_3,
                    Icons.article_outlined,
                    Icons.inventory_2_outlined,
                    Icons.event_available,
                  ]
                : const [Icons.groups_3, Icons.article_outlined],
            selectedIndex: _activityTab,
            onTabChanged: (index) {
              setState(() {
                _activityTab = index;
              });
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 340.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildTabContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    if (!widget.isOwnerProfile) {
      return _activityTab == 1
          ? _buildPublicArticlesTab(context)
          : _buildPublicLecturesTab(context);
    }
    switch (_activityTab) {
      case 0:
        return _buildLecturesTab(context);
      case 1:
        return _buildArticlesTab(context);
      case 2:
        return _buildToolsTab(context);
      case 3:
        return _buildBookingsTab(context);
      default:
        return _buildLecturesTab(context);
    }
  }

  Widget _buildLecturesTab(BuildContext context) {
    if (widget.isLoadingLectures) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.lectures.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups_3, color: cs.onSurfaceVariant, size: 56.w),
              SizedBox(height: 12.h),
              Text(
                'profile.my_lectures_empty'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onSurface,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < widget.lectures.length; i++) ...[
          _buildPublisherSessionCard(context, widget.lectures[i]),
          if (i < widget.lectures.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildPublisherSessionCard(
    BuildContext context,
    SessionEntity session,
  ) {
    final startTime = DateTime.tryParse(session.startsAt)?.toLocal();
    final bookedCount = session.bookedCount;
    final maxSeats = session.maxSeats > 0 ? session.maxSeats : 1;
    final factor = (bookedCount / maxSeats).clamp(0.0, 1.0).toDouble();
    final percent = (bookedCount / maxSeats * 100).round();
    final lecturer = session.lecturerName;
    final location = [
      session.placeName,
      session.city,
    ].where((part) => part.isNotEmpty).join(' — ');

    String dateLabel = 'session.unspecified'.tr();
    String timeLabel = 'session.unspecified'.tr();
    if (startTime != null) {
      dateLabel =
          '${_weekdays[startTime.weekday % 7]} ${startTime.day} ${_months[startTime.month - 1]}';
      final hour = startTime.hour;
      final minute = startTime.minute;
      timeLabel =
          '${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr()}';
    }

    return AppSessionCard(
      sessionId: session.id,
      title: session.title,
      lecturerName: lecturer.isNotEmpty ? lecturer : 'session.unspecified'.tr(),
      lecturerInitial: lecturer.isNotEmpty ? lecturer[0] : ' — ',
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      locationLabel: location.isNotEmpty
          ? location
          : 'session.unspecified'.tr(),
      mapPillLabel: location.isNotEmpty ? location : 'session.unspecified'.tr(),
      capacityFactor: factor,
      percentLabel: '$percent%',
      seatsLabel: '$bookedCount/$maxSeats',
      lat: session.lat,
      lng: session.lng,
      ctaLabel: 'session.details'.tr(),
      noteLabel: 'session.cancel_48h_note'.tr(),
      onTap: () =>
          context.push('/session-details/${session.id}?isPublisher=true'),
    );
  }

  Widget _buildArticlesTab(BuildContext context) {
    return BlocBuilder<ArticleCubit, ArticleState>(
      buildWhen: (_, c) => c is ArticleLoaded || c is ArticleLoading,
      builder: (context, state) {
        final authorId = widget.isOwnerProfile
            ? Supabase.instance.client.auth.currentUser?.id
            : (widget.articles.isNotEmpty
                ? widget.articles.first.authorId
                : null);

        final liveArticles = (state is ArticleLoaded && authorId != null)
            ? state.articles.where((a) => a.authorId == authorId).toList()
            : widget.articles;

        if (widget.isLoadingArticles && state is! ArticleLoaded) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (liveArticles.isEmpty) {
          final cs = Theme.of(context).colorScheme;
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: cs.onSurfaceVariant,
                    size: 56.w,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'profile.my_articles_empty'.tr(),
                    style: AppTypography.arabicTitle(
                      color: cs.onSurface,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < liveArticles.length; i++) ...[
              ArticleEntityCard(
                key: ValueKey(liveArticles[i].id),
                article: liveArticles[i],
              ),
              if (i < liveArticles.length - 1) SizedBox(height: 12.h),
            ],
          ],
        );
      },
    );
  }

  Widget _buildToolsTab(BuildContext context) {
    return BlocBuilder<StudyToolCubit, StudyToolState>(
      buildWhen: (_, c) => c is StudyToolLoaded || c is StudyToolLoading,
      builder: (context, state) {
        final ownerId =
            widget.tools.isNotEmpty ? widget.tools.first.ownerId : null;
        final liveTools = (state is StudyToolLoaded && ownerId != null)
            ? state.tools.where((t) => t.ownerId == ownerId).toList()
            : widget.tools;

        if (widget.isLoadingTools && state is! StudyToolLoaded) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (liveTools.isEmpty) {
          final cs = Theme.of(context).colorScheme;
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: cs.onSurfaceVariant,
                    size: 56.w,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'profile.my_tools_empty'.tr(),
                    style: AppTypography.arabicTitle(
                      color: cs.onSurface,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < liveTools.length; i++) ...[
              StudyToolEntityCard(
                key: ValueKey(liveTools[i].id),
                tool: liveTools[i],
                index: i,
              ),
              if (i < liveTools.length - 1) SizedBox(height: 12.h),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBookingsTab(BuildContext context) {
    if (widget.isLoadingBookings) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.bookings.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                color: cs.onSurfaceVariant,
                size: 56.w,
              ),
              SizedBox(height: 12.h),
              Text(
                'profile.my_bookings_empty'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onSurface,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < widget.bookings.length; i++) ...[
          _buildBookingCard(context, widget.bookings[i]),
          if (i < widget.bookings.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingEntity booking) {
    final session = booking.session;
    final startTime = DateTime.tryParse(session.startsAt)?.toLocal();
    final bookedCount = session.bookedCount;
    final maxSeats = session.maxSeats > 0 ? session.maxSeats : 1;
    final factor = (bookedCount / maxSeats).clamp(0.0, 1.0).toDouble();
    final percent = (bookedCount / maxSeats * 100).round();
    final lecturer = session.lecturerName;
    final location = [
      session.placeName,
      session.city,
    ].where((part) => part.isNotEmpty).join(' — ');

    String dateLabel = 'session.unspecified'.tr();
    String timeLabel = 'session.unspecified'.tr();
    if (startTime != null) {
      dateLabel =
          '${_weekdays[startTime.weekday % 7]} ${startTime.day} ${_months[startTime.month - 1]}';
      final hour = startTime.hour;
      final minute = startTime.minute;
      timeLabel =
          '${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr()}';
    }

    return AppSessionCard(
      sessionId: session.id,
      title: session.title,
      lecturerName: lecturer,
      lecturerInitial: lecturer.isNotEmpty ? lecturer[0] : ' — ',
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      locationLabel: location,
      mapPillLabel: location,
      capacityFactor: factor,
      percentLabel: '$percent%',
      seatsLabel: '$bookedCount/$maxSeats',
      ctaLabel: 'booking.booked'.tr(),
      lat: session.lat,
      lng: session.lng,
    );
  }

  Widget _buildPublicLecturesTab(BuildContext context) {
    if (widget.isLoadingLectures) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.lectures.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups_3, color: cs.onSurfaceVariant, size: 56.w),
              SizedBox(height: 12.h),
              Text(
                'profile.no_upcoming_lectures'.tr(),
                style: AppTypography.arabicTitle(
                  color: cs.onSurface,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < widget.lectures.length; i++) ...[
          _buildSessionCard(context, widget.lectures[i]),
          if (i < widget.lectures.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionEntity session) {
    final startTime = DateTime.tryParse(session.startsAt)?.toLocal();
    final bookedCount = session.bookedCount;
    final maxSeats = session.maxSeats > 0 ? session.maxSeats : 1;
    final factor = (bookedCount / maxSeats).clamp(0.0, 1.0).toDouble();
    final percent = (bookedCount / maxSeats * 100).round();
    final lecturer = session.lecturerName;
    final location = [
      session.placeName,
      session.city,
    ].where((part) => part.isNotEmpty).join(' — ');

    String dateLabel = 'session.unspecified'.tr();
    String timeLabel = 'session.unspecified'.tr();
    if (startTime != null) {
      dateLabel =
          '${_weekdays[startTime.weekday % 7]} ${startTime.day} ${_months[startTime.month - 1]}';
      final hour = startTime.hour;
      final minute = startTime.minute;
      timeLabel =
          '${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr()}';
    }

    return AppSessionCard(
      sessionId: session.id,
      title: session.title,
      lecturerName: lecturer.isNotEmpty ? lecturer : 'session.unspecified'.tr(),
      lecturerInitial: lecturer.isNotEmpty ? lecturer[0] : ' — ',
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      locationLabel: location.isNotEmpty
          ? location
          : 'session.unspecified'.tr(),
      mapPillLabel: location.isNotEmpty ? location : 'session.unspecified'.tr(),
      capacityFactor: factor,
      percentLabel: '$percent%',
      seatsLabel: '$bookedCount/$maxSeats',
      lat: session.lat,
      lng: session.lng,
    );
  }

  Widget _buildPublicArticlesTab(BuildContext context) {
    return BlocBuilder<ArticleCubit, ArticleState>(
      buildWhen: (_, c) => c is ArticleLoaded || c is ArticleLoading,
      builder: (context, state) {
        final authorId =
            widget.articles.isNotEmpty ? widget.articles.first.authorId : null;

        final liveArticles = (state is ArticleLoaded && authorId != null)
            ? state.articles.where((a) => a.authorId == authorId).toList()
            : widget.articles;

        if (widget.isLoadingArticles && state is! ArticleLoaded) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (liveArticles.isEmpty) {
          final cs = Theme.of(context).colorScheme;
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: cs.onSurfaceVariant,
                    size: 56.w,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'profile.no_articles_yet'.tr(),
                    style: AppTypography.arabicTitle(
                      color: cs.onSurface,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < liveArticles.length; i++) ...[
              ArticleEntityCard(
                key: ValueKey(liveArticles[i].id),
                article: liveArticles[i],
              ),
              if (i < liveArticles.length - 1) SizedBox(height: 12.h),
            ],
          ],
        );
      },
    );
  }
}
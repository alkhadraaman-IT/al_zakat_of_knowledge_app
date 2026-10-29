import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/domain/entities/favorite_item_entity.dart';
import '../../features/favorites/presentation/widgets/favorite_builder.dart';
import '../../features/favorites/presentation/widgets/favorite_mappers.dart';
import '../../features/sessions/domain/entities/session_entity.dart';
import 'app_session_card.dart';

class SessionEntityCard extends StatelessWidget {
  final SessionEntity session;
  const SessionEntityCard({super.key, required this.session});

  static const _weekdayKeys = [
    'session.day_sunday',
    'session.day_monday',
    'session.day_tuesday',
    'session.day_wednesday',
    'session.day_thursday',
    'session.day_friday',
    'session.day_saturday',
  ];

  static const _monthKeys = [
    'session.month_january',
    'session.month_february',
    'session.month_march',
    'session.month_april',
    'session.month_may',
    'session.month_june',
    'session.month_july',
    'session.month_august',
    'session.month_september',
    'session.month_october',
    'session.month_november',
    'session.month_december',
  ];

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.tryParse(session.startsAt)?.toLocal();
    final booked = session.bookedCount;
    final maxSeats = session.maxSeats > 0 ? session.maxSeats : 1;
    final ratio = booked / maxSeats;
    final lecturer = session.lecturerName;
    final location = [session.placeName, session.city]
        .where((part) => part.isNotEmpty)
        .join(' — ');

    var dateLabel = 'session.unspecified'.tr();
    var timeLabel = 'session.unspecified'.tr();
    if (startTime != null) {
      final weekday = _weekdayKeys[startTime.weekday % 7].tr();
      final month = _monthKeys[startTime.month - 1].tr();
      dateLabel = '$weekday ${startTime.day} $month';

      final hour12 = startTime.hour % 12 == 0 ? 12 : startTime.hour % 12;
      final minute = startTime.minute.toString().padLeft(2, '0');
      final period =
          startTime.hour >= 12 ? 'session.pm'.tr() : 'session.am'.tr();
      timeLabel = '$hour12:$minute $period';
    }

    return FavoriteBuilder(
      type: FavoriteType.lecture,
      id: session.id,
      toFavorite: session.toFavorite,
      builder: (context, isFavorite, onToggle) => AppSessionCard(
        sessionId: session.id,
        title: session.title,
        lecturerName: lecturer,
        lecturerInitial: lecturer.isNotEmpty ? lecturer[0] : ' — ',
        dateLabel: dateLabel,
        timeLabel: timeLabel,
        locationLabel: location,
        mapPillLabel: location,
        capacityFactor: ratio.clamp(0.0, 1.0).toDouble(),
        percentLabel: '${(ratio * 100).round()}%',
        seatsLabel: '$booked/$maxSeats',
        isFavorite: isFavorite,
        onFavoriteToggle: onToggle,
        ctaLabel: 'session.details'.tr(),                      
        onTap: () => context.push('/session-details/${session.id}'),  
        lat: session.lat,
        lng: session.lng,
      ),
    );
  }
}
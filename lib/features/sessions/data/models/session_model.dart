import '../../domain/entities/session_entity.dart';

/// Session model for Supabase `sessions` mapping
/// and Hive JSON serialization.
class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.publisherId,
    required super.title,
    required super.description,
    required super.categoryId,
    required super.city,
    required super.placeName,
    required super.startsAt,
    required super.durationMinutes,
    required super.maxSeats,
    required super.bookedCount,
    required super.status,
    required super.lecturerName,
  });

  /// Creates a [SessionModel] from a Supabase `sessions`
  /// row (with optional embedded `profiles` row).
  factory SessionModel.fromEntity(SessionEntity e) => SessionModel(
      id: e.id,
      publisherId: e.publisherId,
      title: e.title,
      description: e.description,
      categoryId: e.categoryId,
      city: e.city,
      placeName: e.placeName,
      startsAt: e.startsAt,
      durationMinutes: e.durationMinutes,
      maxSeats: e.maxSeats,
      bookedCount: e.bookedCount,
      status: e.status,
      lecturerName: e.lecturerName,
    );

  /// Creates a [SessionModel] from a Hive JSON map.
  factory SessionModel.fromMap(Map<dynamic, dynamic> json) {
    print('<<<<<<<<<<<[SessionModel.fromHive]>>>>>>>>>>>>>');
    return SessionModel(
      id: json['id']?.toString() ?? '',
      publisherId: json['publisherId']?.toString() ??
          json['publisher_id']?.toString() ??
          '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: (json['categoryId'] as num?)?.toInt() ??
          (json['category_id'] as num?)?.toInt() ??
          0,
      city: json['city'] as String? ?? '',
      placeName: json['placeName'] as String? ??
          json['place_name'] as String? ??
          '',
      startsAt: json['startsAt'] as String? ??
          json['starts_at'] as String? ??
          '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ??
          (json['duration_minutes'] as num?)?.toInt() ??
          0,
      maxSeats: (json['maxSeats'] as num?)?.toInt() ??
          (json['max_seats'] as num?)?.toInt() ??
          0,
      bookedCount: (json['bookedCount'] as num?)?.toInt() ??
          (json['booked_count'] as num?)?.toInt() ??
          0,
      status: json['status'] as String? ?? '',
      lecturerName: json['lecturerName'] as String? ??
          json['lecturer_name'] as String? ??
          '',
    );
  }

  /// Converts the model to a JSON map for Hive storage.
  Map<String, dynamic> toMap() {
    print('<<<<<<<<<<<[SessionModel.toHive]>>>>>>>>>>>>>');
    return {
      'id': id,
      'publisherId': publisherId,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'city': city,
      'placeName': placeName,
      'startsAt': startsAt,
      'durationMinutes': durationMinutes,
      'maxSeats': maxSeats,
      'bookedCount': bookedCount,
      'status': status,
      'lecturerName': lecturerName,
    };
  }
}
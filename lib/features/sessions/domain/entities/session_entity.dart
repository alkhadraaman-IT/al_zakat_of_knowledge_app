class SessionEntity {
  final String id;
  final String publisherId;
  final String title;
  final String description;
  final int categoryId;
  final String city;
  final String placeName;
  final String startsAt;
  final int durationMinutes;
  final int maxSeats;
  final int bookedCount;
  final String status;
  final String lecturerName;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;  // 👈 جديد

  const SessionEntity({
    required this.id,
    required this.publisherId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.city,
    required this.placeName,
    required this.startsAt,
    required this.durationMinutes,
    required this.maxSeats,
    required this.bookedCount,
    required this.status,
    required this.lecturerName,
    this.lat,
    this.lng,
    this.createdAt,  // 👈 جديد
  });

  // 👈 جديد: نسخة معدلة
  SessionEntity copyWith({
    String? id,
    String? publisherId,
    String? title,
    String? description,
    int? categoryId,
    String? city,
    String? placeName,
    String? startsAt,
    int? durationMinutes,
    int? maxSeats,
    int? bookedCount,
    String? status,
    String? lecturerName,
    double? lat,
    double? lng,
    DateTime? createdAt,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      publisherId: publisherId ?? this.publisherId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      city: city ?? this.city,
      placeName: placeName ?? this.placeName,
      startsAt: startsAt ?? this.startsAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      maxSeats: maxSeats ?? this.maxSeats,
      bookedCount: bookedCount ?? this.bookedCount,
      status: status ?? this.status,
      lecturerName: lecturerName ?? this.lecturerName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 👈 جديد: للتمرير إلى شيت التعديل
  Map<String, dynamic> toEditMap() {
    return {
      'title': title,
      'description': description,
      'max_seats': maxSeats,
      'booked_count': bookedCount,
      'city': city,
      'place_name': placeName,
      'duration_minutes': durationMinutes,
      'category_id': categoryId,
      'starts_at': startsAt,
      'lat': lat,
      'lng': lng,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'publisher_id': publisherId,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'city': city,
      'place_name': placeName,
      'starts_at': startsAt,
      'duration_minutes': durationMinutes,
      'max_seats': maxSeats,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  factory SessionEntity.fromSupabase(Map<String, dynamic> map) {
    final publisherMap = map['profiles'];
    String lecturerName = '';
    if (publisherMap is Map<String, dynamic>) {
      lecturerName = publisherMap['name']?.toString() ?? '';
    } else if (publisherMap is List && publisherMap.isNotEmpty) {
      lecturerName = publisherMap.first['name']?.toString() ?? '';
    }
    return SessionEntity(
      id: map['id']?.toString() ?? '',
      publisherId: map['publisher_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      categoryId: map['category_id'] as int? ?? 0,
      city: map['city']?.toString() ?? '',
      placeName: map['place_name']?.toString() ?? '',
      startsAt: map['starts_at']?.toString() ?? '',
      durationMinutes: map['duration_minutes'] as int? ?? 0,
      maxSeats: map['max_seats'] as int? ?? 0,
      bookedCount: map['booked_count'] as int? ?? 0,
      status: map['status']?.toString() ?? '',
      lecturerName: lecturerName,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }
}
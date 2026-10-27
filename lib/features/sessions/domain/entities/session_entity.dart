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
  });

  /// تحويل البيانات إلى خريطة مطابقة لأعمدة جدول sessions في Supabase
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
    );
  }
}
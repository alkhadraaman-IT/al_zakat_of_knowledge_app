import '../../domain/entities/study_tool_entity.dart';

/// Study material model for Supabase
/// `materials` mapping.
class StudyToolModel extends StudyToolEntity {
  const StudyToolModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.subject,
    required super.studyYear,
    required super.university,
    required super.city,
    required super.pickupPlace,
    required super.pickupNotes,
    required super.categoryId,
    required super.isTaken,
    required super.status,
    super.statusChangedAt,
    required super.kind,
    required super.createdAt,
  });

  /// Creates a [StudyToolModel] from a
  /// Supabase `materials` row.
  factory StudyToolModel.fromEntity(StudyToolEntity e) => StudyToolModel(
      id: e.id,
      ownerId: e.ownerId,
      title: e.title,
      subject: e.subject,
      studyYear: e.studyYear,
      university: e.university,
      city: e.city,
      pickupPlace: e.pickupPlace,
      pickupNotes: e.pickupNotes,
      categoryId: e.categoryId,
      isTaken: e.isTaken,
      status: e.status,
      statusChangedAt: e.statusChangedAt,
      kind: e.kind,
      createdAt: e.createdAt,
    );

  /// Insert payload — permitted fields only.
  ///
  /// `id` and `created_at` are server-managed,
  /// `is_taken` is a locked column toggled via
  /// the RPC function only, and `status` with
  /// `status_changed_at` is server-managed —
  /// none of them is ever sent (the backend
  /// rejects locked columns).
  Map<String, dynamic> toInsertJson() {
    return {
      'owner_id': ownerId,
      'title': title,
      'subject': subject,
      'study_year': studyYear,
      'university': university,
      'city': city,
      'pickup_place': pickupPlace,
      'pickup_notes': pickupNotes,
      'category_id': categoryId,
      'kind': kind,
    };
  }

  /// Creates a [StudyToolModel] from a Hive JSON map.
  factory StudyToolModel.fromMap(Map<dynamic, dynamic> json) {
    print('<<<<<<<<<<<[StudyToolModel.fromHive]>>>>>>>>>>>>>');
    return StudyToolModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? json['owner_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      studyYear: json['studyYear'] as String? ??
          json['study_year'] as String? ??
          '',
      university: json['university'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pickupPlace: json['pickupPlace'] as String? ??
          json['pickup_place'] as String? ??
          '',
      pickupNotes: json['pickupNotes'] as String? ??
          json['pickup_notes'] as String? ??
          '',
      categoryId: (json['categoryId'] as num?)?.toInt() ??
          (json['category_id'] as num?)?.toInt() ??
          0,
      isTaken: json['isTaken'] as bool? ?? json['is_taken'] as bool? ?? false,
      status: json['status'] as String? ?? 'available',
      statusChangedAt: json['statusChangedAt'] != null
          ? DateTime.tryParse(json['statusChangedAt'] as String)?.toLocal()
          : json['status_changed_at'] != null
              ? DateTime.tryParse(json['status_changed_at'] as String)?.toLocal()
              : null,
      kind: json['kind'] as String? ?? 'book',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)?.toLocal() ??
              DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)?.toLocal() ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  /// Converts the model to a JSON map for Hive storage.
  Map<String, dynamic> toMap() {
    print('<<<<<<<<<<<[StudyToolModel.toHive]>>>>>>>>>>>>>');
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'subject': subject,
      'studyYear': studyYear,
      'university': university,
      'city': city,
      'pickupPlace': pickupPlace,
      'pickupNotes': pickupNotes,
      'categoryId': categoryId,
      'isTaken': isTaken,
      'status': status,
      'statusChangedAt': statusChangedAt?.toIso8601String(),
      'kind': kind,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

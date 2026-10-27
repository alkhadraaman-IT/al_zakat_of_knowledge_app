import 'package:equatable/equatable.dart';

/// Study material entity — an offered
/// academic material (book, stationery,
/// ...) in the `materials` table.
class StudyToolEntity extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String subject;
  final String studyYear;
  final String university;
  final String city;
  final String pickupPlace;
  final String pickupNotes;

  /// Category id — an `int` foreign key
  /// into the `categories` table.
  final int categoryId;

  /// Mirrors the `is_taken` column — toggled
  /// exclusively through the RPC function
  /// (never sent in insert payloads).
  final bool isTaken;

  /// Server-managed lifecycle status
  /// (`available`, `taken`, ...).
  final String status;

  /// Mirrors the server-managed
  /// `status_changed_at` column — the
  /// timestamp of the last status change,
  /// `null` until the status first changes.
  final DateTime? statusChangedAt;

  /// The material kind (`book`, `stationery`,
  /// `notes`, `other`).
  final String kind;
  final DateTime createdAt;

  const StudyToolEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.subject,
    required this.studyYear,
    required this.university,
    required this.city,
    required this.pickupPlace,
    required this.pickupNotes,
    required this.categoryId,
    required this.isTaken,
    required this.status,
    this.statusChangedAt,
    required this.kind,
    required this.createdAt,
  });

  StudyToolEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? subject,
    String? studyYear,
    String? university,
    String? city,
    String? pickupPlace,
    String? pickupNotes,
    int? categoryId,
    bool? isTaken,
    String? status,
    DateTime? statusChangedAt,
    String? kind,
    DateTime? createdAt,
  }) {
    return StudyToolEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      studyYear: studyYear ?? this.studyYear,
      university: university ?? this.university,
      city: city ?? this.city,
      pickupPlace: pickupPlace ?? this.pickupPlace,
      pickupNotes: pickupNotes ?? this.pickupNotes,
      categoryId: categoryId ?? this.categoryId,
      isTaken: isTaken ?? this.isTaken,
      status: status ?? this.status,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        subject,
        studyYear,
        university,
        city,
        pickupPlace,
        pickupNotes,
        categoryId,
        isTaken,
        status,
        statusChangedAt,
        kind,
        createdAt,
      ];
}

import 'package:equatable/equatable.dart';

/// Report entity — a user-submitted report
/// about a piece of content (session, study tool, article).
class ReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String targetType; // 'session' | 'study_tool' | 'article'
  final String targetId;
  final String reason; // one of the report.reason_* keys
  final String? details; // optional free-text when reason == 'other'
  final String status; // 'pending' | 'reviewed' | 'rejected'
  final DateTime createdAt;

  const ReportEntity({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        reporterId,
        targetType,
        targetId,
        reason,
        details,
        status,
        createdAt,
      ];

  /// Creates a [ReportEntity] from a Supabase row map.
  factory ReportEntity.fromSupabase(Map<String, dynamic> map) {
    return ReportEntity(
      id: map['id']?.toString() ?? '',
      reporterId: map['reporter_id']?.toString() ?? '',
      targetType: map['target_type']?.toString() ?? '',
      targetId: map['target_id']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
      details: map['details']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the entity to a JSON map
  /// suitable for inserting into the `reports` table.
  Map<String, dynamic> toInsertJson() {
    return {
      'reporter_id': reporterId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'details': details,
    };
  }

  /// Creates a [ReportEntity] from a Map (standardized naming convention).
  factory ReportEntity.fromMap(Map<String, dynamic> map) {
    return ReportEntity(
      id: map['id']?.toString() ?? '',
      reporterId: map['reporter_id']?.toString() ?? '',
      targetType: map['target_type']?.toString() ?? '',
      targetId: map['target_id']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
      details: map['details']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this entity to a Map (standardized naming convention).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'details': details,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
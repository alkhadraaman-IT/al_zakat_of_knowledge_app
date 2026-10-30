import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String targetType;
  final String targetId;
  final String reason;
  final String? details;
  final String status;
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

  /// يقرأ من صف Supabase (snake_case) أو من Map محلي (snake_case).
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
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'reporter_id': reporterId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'details': details,
    };
  }

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
}
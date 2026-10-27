// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BookingModel {
  final String id;
  final String sessionId;
  final String userId;
  final String status;
  BookingModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.status,
  });

  BookingModel copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? status,
  }) {
    return BookingModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'status': status,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      userId: map['userId'] as String,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingModel.fromJson(String source) => BookingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookingModel(id: $id, sessionId: $sessionId, userId: $userId, status: $status)';
  }

  @override
  bool operator ==(covariant BookingModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.sessionId == sessionId &&
      other.userId == userId &&
      other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      sessionId.hashCode ^
      userId.hashCode ^
      status.hashCode;
  }
}

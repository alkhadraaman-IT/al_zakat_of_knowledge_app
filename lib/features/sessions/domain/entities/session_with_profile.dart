import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/profile_entity.dart';
import 'session_entity.dart';

/// بيانات الجلسة مع معلومات المحاضر والتصنيف.
/// تُجمع في استعلام واحد لتقليل طلبات الشبكة.
class SessionWithProfile extends Equatable {
  final SessionEntity session;
  final ProfileEntity? publisher;
  final String? categoryNameAr;
  final String? categoryNameEn;
  final bool isBooked;
  final bool isPublisher;

  const SessionWithProfile({
    required this.session,
    this.publisher,
    this.categoryNameAr,
    this.categoryNameEn,
    required this.isBooked,
    required this.isPublisher,
  });

  String? categoryNameFor(String languageCode) =>
      languageCode == 'ar' ? categoryNameAr : categoryNameEn;

  SessionWithProfile copyWith({
    SessionEntity? session,
    ProfileEntity? publisher,
    String? categoryNameAr,
    String? categoryNameEn,
    bool? isBooked,
    bool? isPublisher,
  }) {
    return SessionWithProfile(
      session: session ?? this.session,
      publisher: publisher ?? this.publisher,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      isBooked: isBooked ?? this.isBooked,
      isPublisher: isPublisher ?? this.isPublisher,
    );
  }

  @override
  List<Object?> get props => [
        session,
        publisher,
        categoryNameAr,
        categoryNameEn,
        isBooked,
        isPublisher,
      ];
}
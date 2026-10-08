import 'package:equatable/equatable.dart';

/// Core user entity representing an authenticated academic user.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? university;
  final String? avatarUrl;
  final DateTime? emailConfirmedAt;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.university,
    this.avatarUrl,
    this.emailConfirmedAt,
    required this.createdAt,
    this.lastSignInAt,
    this.isEmailVerified = false,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? university,
    String? avatarUrl,
    DateTime? emailConfirmedAt,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isEmailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      university: university ?? this.university,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailConfirmedAt: emailConfirmedAt ?? this.emailConfirmedAt,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        university,
        avatarUrl,
        emailConfirmedAt,
        createdAt,
        lastSignInAt,
        isEmailVerified,
      ];
}

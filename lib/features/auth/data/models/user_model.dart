import '../../domain/entities/user_entity.dart';

/// User model for Hive serialization and Supabase mapping.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.university,
    super.avatarUrl,
    super.emailConfirmedAt,
    required super.createdAt,
    super.lastSignInAt,
    super.isEmailVerified,
  });

  /// Creates a [UserModel] from a Supabase user JSON map.
  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    final userMetadata = json['user_metadata'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: userMetadata['full_name'] as String? ??
          userMetadata['name'] as String? ??
          '',
      university: userMetadata['university'] as String?,
      avatarUrl: userMetadata['avatar_url'] as String? ??
          json['avatar_url'] as String?,
      emailConfirmedAt: json['email_confirmed_at'] != null
          ? DateTime.tryParse(json['email_confirmed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.tryParse(json['last_sign_in_at'] as String)
          : null,
      isEmailVerified: json['email_confirmed_at'] != null,
    );
  }

  /// Creates a [UserModel] from a Hive JSON map.
  factory UserModel.fromHive(Map<dynamic, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      university: json['university'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      emailConfirmedAt: json['emailConfirmedAt'] != null
          ? DateTime.tryParse(json['emailConfirmedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.tryParse(json['lastSignInAt'] as String)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  /// Converts the model to a JSON map for Hive storage.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'university': university,
      'avatarUrl': avatarUrl,
      'emailConfirmedAt': emailConfirmedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'university': university,
      'avatar_url': avatarUrl,
      'email_confirmed_at': emailConfirmedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'is_email_verified': isEmailVerified,
    };
  }

  /// إنشاء UserModel من مستخدم Firebase
  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      isEmailVerified: user.emailVerified,
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

import '../../domain/entities/profile_entity.dart';

/// Profile model for Supabase `profiles` mapping and Hive serialization.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    super.photoUrl,
    super.linkedinUrl,
    super.githubUrl,
    super.cvPdfUrl,
    super.university,
    super.city,
    super.isAdmin,
    super.isBanned,
    required super.createdAt,
  });

  /// Creates a [ProfileModel] from a Supabase `profiles` row.
  factory ProfileModel.fromSupabase(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      cvPdfUrl: json['cv_pdf_url'] as String?,
      university: json['university'] as String?,
      city: json['city'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      isBanned: json['is_banned'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Creates a [ProfileModel] from a Hive JSON map.
  factory ProfileModel.fromHive(Map<dynamic, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      cvPdfUrl: json['cvPdfUrl'] as String?,
      university: json['university'] as String?,
      city: json['city'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isBanned: json['isBanned'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Creates a [ProfileModel] from any [ProfileEntity]
  /// (e.g. one rebuilt in the presentation layer).
  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      photoUrl: entity.photoUrl,
      linkedinUrl: entity.linkedinUrl,
      githubUrl: entity.githubUrl,
      cvPdfUrl: entity.cvPdfUrl,
      university: entity.university,
      city: entity.city,
      isAdmin: entity.isAdmin,
      isBanned: entity.isBanned,
      createdAt: entity.createdAt,
    );
  }

  /// Converts the model to a JSON map for Hive storage.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'cvPdfUrl': cvPdfUrl,
      'university': university,
      'city': city,
      'isAdmin': isAdmin,
      'isBanned': isBanned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON payload for updating the profile row — client-writable
  /// fields ONLY. `id`, `created_at`, `is_admin` and `is_banned`
  /// are server-managed and are never sent.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'photo_url': photoUrl,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'cv_pdf_url': cvPdfUrl,
      'university': university,
      'city': city,
    };
  }
}

import 'package:equatable/equatable.dart';

/// Profile entity — the authenticated user's row in the `profiles` table
/// (1:1 with the Supabase auth user id).
///
/// Strictly mirrors the backend specification:
/// `id`, `name`, `photo_url`, `linkedin_url`, `github_url`, `cv_pdf_url`,
/// `university`, `city`, `is_admin`, `is_banned`, `created_at`.
class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? cvPdfUrl;
  final String? university;
  final String? city;
  final bool isAdmin;
  final bool isBanned;
  final DateTime createdAt;

  const ProfileEntity({
    required this.id,
    required this.name,
    this.photoUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.cvPdfUrl,
    this.university,
    this.city,
    this.isAdmin = false,
    this.isBanned = false,
    required this.createdAt,
  });

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? linkedinUrl,
    String? githubUrl,
    String? cvPdfUrl,
    String? university,
    String? city,
    bool? isAdmin,
    bool? isBanned,
    DateTime? createdAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      cvPdfUrl: cvPdfUrl ?? this.cvPdfUrl,
      university: university ?? this.university,
      city: city ?? this.city,
      isAdmin: isAdmin ?? this.isAdmin,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        photoUrl,
        linkedinUrl,
        githubUrl,
        cvPdfUrl,
        university,
        city,
        isAdmin,
        isBanned,
        createdAt,
      ];
}

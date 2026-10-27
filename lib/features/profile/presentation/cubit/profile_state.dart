import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/profile_entity.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/domain/entities/booking_entity.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity? profile;
  final List<Map<String, dynamic>> categories;
  final Set<String> selectedCategoryIds;
  final List<ArticleEntity> articles;
  final List<SessionEntity> lectures;
  final List<BookingEntity> bookings;
  final List<StudyToolEntity> tools;
  final bool publicNotFound;

  const ProfileLoaded({
    this.profile,
    this.categories = const [],
    this.selectedCategoryIds = const {},
    this.articles = const [],
    this.lectures = const [],
    this.bookings = const [],
    this.tools = const [],
    this.publicNotFound = false,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    List<Map<String, dynamic>>? categories,
    Set<String>? selectedCategoryIds,
    List<ArticleEntity>? articles,
    List<SessionEntity>? lectures,
    List<BookingEntity>? bookings,
    List<StudyToolEntity>? tools,
    bool? publicNotFound,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      categories: categories ?? this.categories,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      articles: articles ?? this.articles,
      lectures: lectures ?? this.lectures,
      bookings: bookings ?? this.bookings,
      tools: tools ?? this.tools,
      publicNotFound: publicNotFound ?? this.publicNotFound,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        categories,
        selectedCategoryIds,
        articles,
        lectures,
        bookings,
        tools,
        publicNotFound,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
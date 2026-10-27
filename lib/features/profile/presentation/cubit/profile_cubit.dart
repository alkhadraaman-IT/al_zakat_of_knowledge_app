import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../articles/domain/usecases/get_my_articles_usecase.dart';
import '../../../auth/domain/entities/profile_entity.dart';
import '../../../auth/domain/usecases/get_current_profile_usecase.dart';
import '../../../sessions/domain/usecases/get_sessions_by_publisher_usecase.dart';
import '../../../sessions/domain/usecases/get_user_bookings_usecase.dart';
import '../../../study_tools/domain/usecases/get_study_tools_by_owner_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final String? userId;
  bool get _isOwnerProfile => userId == null;

  ProfileCubit({this.userId}) : super(ProfileInitial());

  Future<void> loadProfileData(String? currentAuthUserId) async {
    emit(ProfileLoading());

    if (_isOwnerProfile) {
      await Future.wait([
        loadOwnerProfile(),
        loadCategories(),
        if (currentAuthUserId != null) loadUserInterests(currentAuthUserId),
        loadMyArticles(currentAuthUserId),
        loadMyBookings(currentAuthUserId),
        loadMyTools(currentAuthUserId),
        loadMyLectures(currentAuthUserId),
      ]);
    } else {
      await Future.wait([
        loadPublicProfile(),
        loadPublicLectures(),
        loadPublicArticles(),
      ]);
    }
  }

  Future<void> loadOwnerProfile() async {
    final result = await sl<GetCurrentProfileUseCase>()();
    if (state is ProfileLoaded) {
      result.fold(
        (_) {},
        (profile) => emit((state as ProfileLoaded).copyWith(profile: profile)),
      );
    } else {
      result.fold(
        (_) => emit(const ProfileLoaded()),
        (profile) => emit(ProfileLoaded(profile: profile)),
      );
    }
  }

  Future<void> loadPublicProfile() async {
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('id, name, city, university, photo_url, cv_pdf_url, github_url, linkedin_url, created_at')
          .eq('id', userId!)
          .maybeSingle();

      if (row == null) {
        emit(const ProfileLoaded(publicNotFound: true));
        return;
      }

      final profile = ProfileEntity(
        id: row['id']?.toString() ?? '',
        name: row['name']?.toString() ?? '',
        city: row['city']?.toString(),
        university: row['university']?.toString(),
        photoUrl: row['photo_url']?.toString(),
        cvPdfUrl: row['cv_pdf_url']?.toString(),
        githubUrl: row['github_url']?.toString(),
        linkedinUrl: row['linkedin_url']?.toString(),
        createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
      );

      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(const ProfileLoaded(publicNotFound: true));
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select()
          .order('sort_order', ascending: true);

      if (!isClosed && state is ProfileLoaded) {
        final current = state as ProfileLoaded;
        emit(current.copyWith(
          categories: List<Map<String, dynamic>>.from(response),
        ));
      }
    } catch (_) {}
  }

  Future<void> loadUserInterests(String authUserId) async {
    try {
      final response = await Supabase.instance.client
          .from('category_follows')
          .select('category_id')
          .eq('user_id', authUserId);

      if (!isClosed && state is ProfileLoaded) {
        final current = state as ProfileLoaded;
        final Set<String> ids = {};
        for (final row in response) {
          if (row['category_id'] != null) {
            ids.add(row['category_id'].toString());
          }
        }
        emit(current.copyWith(selectedCategoryIds: ids));
      }
    } catch (_) {}
  }

  Future<void> toggleCategoryInterest(String catId, String authUserId) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    final isSelected = current.selectedCategoryIds.contains(catId);
    
    final updatedIds = Set<String>.from(current.selectedCategoryIds);
    if (isSelected) {
      updatedIds.remove(catId);
    } else {
      updatedIds.add(catId);
    }
    emit(current.copyWith(selectedCategoryIds: updatedIds));

    try {
      if (isSelected) {
        await Supabase.instance.client
            .from('category_follows')
            .delete()
            .eq('user_id', authUserId)
            .eq('category_id', catId);
      } else {
        await Supabase.instance.client
            .from('category_follows')
            .insert({'user_id': authUserId, 'category_id': catId});
      }
    } catch (_) {
      emit(current);
    }
  }

  Future<void> loadMyArticles(String? authorId) async {
    if (authorId == null) return;
    final result = await sl<GetMyArticlesUseCase>()(authorId: authorId);
    if (!isClosed && state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      result.fold(
        (_) {},
        (articles) => emit(current.copyWith(articles: articles)),
      );
    }
  }

  Future<void> loadPublicArticles() async {
    if (userId == null) return;
    final result = await sl<GetMyArticlesUseCase>()(authorId: userId!);
    if (!isClosed && state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      result.fold(
        (_) {},
        (articles) => emit(current.copyWith(articles: articles)),
      );
    }
  }

  Future<void> loadMyBookings(String? userId) async {
    if (userId == null) return;
    final result = await sl<GetUserBookingsUseCase>()(userId: userId);
    if (!isClosed && state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      result.fold(
        (_) {},
        (bookings) => emit(current.copyWith(bookings: bookings)),
      );
    }
  }

  Future<void> loadMyTools(String? ownerId) async {
    if (ownerId == null) return;
    final result = await sl<GetStudyToolsByOwnerUseCase>()(ownerId: ownerId);
    if (!isClosed && state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      result.fold(
        (_) {},
        (tools) => emit(current.copyWith(tools: tools)),
      );
    }
  }

  Future<void> loadMyLectures(String? publisherId) async {
    if (publisherId == null) return;
    final result = await sl<GetSessionsByPublisherUseCase>()(publisherId: publisherId);
    if (!isClosed && state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      result.fold(
        (_) {},
        (lectures) => emit(current.copyWith(lectures: lectures)),
      );
    }
  }

  Future<void> loadPublicLectures() async {
    if (userId == null) return;
    final result = await sl<GetSessionsByPublisherUseCase>()(publisherId: userId!);
    if (!isClosed && state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      final now = DateTime.now();
      result.fold(
        (_) {},
        (list) {
          final activeLectures = list.where((s) {
            final start = DateTime.tryParse(s.startsAt);
            return s.status == 'active' && start != null && start.isAfter(now);
          }).toList();
          emit(current.copyWith(lectures: activeLectures));
        },
      );
    }
  }
}
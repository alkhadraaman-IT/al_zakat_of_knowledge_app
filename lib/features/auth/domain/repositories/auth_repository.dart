import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../entities/user_entity.dart';

/// Abstract authentication repository interface.
abstract class AuthRepository {
  /// Signs in with email and password.
  /// Returns [UserEntity] on success, [Failure] on error.
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs up with email, password, and academic info.
  /// Returns [UserEntity] on success, [Failure] on error.
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String university,
  });

  /// Signs in with Google SSO.
  // Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Signs out the current user.
  Future<Either<Failure, void>> signOut();

  /// Updates the logged-in user's `profiles` row.
  /// Returns the updated [ProfileEntity] on success.
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity profile,
  );

  /// Gets the logged-in user's profile row —
  /// fetched fresh from `profiles`, falling back
  /// to the local cache when offline.
  Future<Either<Failure, ProfileEntity?>> getCurrentProfile();

  /// Gets the currently authenticated user.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Checks if the user is authenticated.
  Future<Either<Failure, bool>> isAuthenticated();

  /// Sends password reset email.
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Stream of authentication state changes.
  Stream<UserEntity?> get authStateChanges;
}

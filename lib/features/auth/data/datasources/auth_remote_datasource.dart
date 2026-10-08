import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

/// Abstract remote data source for authentication.
abstract class AuthRemoteDataSource {
  /// Signs in with email and password.
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs up with email, password, and academic info.
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String university,
  });

  /// Signs in with Google SSO.
  Future<UserModel> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();

  /// Fetches the logged-in user's profile row from the `profiles` table.
  Future<ProfileModel> fetchProfile(String userId);

  /// Updates the user's `profiles` row with the
  /// client-writable fields from `toUpdateJson()`.
  Future<ProfileModel> updateProfile(ProfileModel profile);

  /// Deletes the device row from `user_devices` before sign-out.
  Future<void> deleteDeviceRow();

  /// Gets the current Supabase user.
  UserModel? getCurrentSupabaseUser();

  /// Sends password reset email.
  Future<void> resetPassword({required String email});

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges;
}

/// Supabase implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print('<<<<<<<<<<<[signInWithEmailAndPassword]>>>>>>>>>>>>>');
    final response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed: No user returned');
    }

    return UserModel.fromSupabase(response.user!.toJson());
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String university,
  }) async {
    print('<<<<<<<<<<<[signUpWithEmailAndPassword]>>>>>>>>>>>>>');
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'university': university,
      },
    );

    if (response.user == null) {
      throw Exception('Sign up failed: No user returned');
    }

    return UserModel.fromSupabase(response.user!.toJson());
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    print('<<<<<<<<<<<[signInWithGoogle]>>>>>>>>>>>>>');
    final response = await supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConstants.supabaseRedirectUrl,
    );

    if (!response) {
      throw Exception('Google sign in failed');
    }

    // Wait for the session to be established via auth state changes
    await for (final state in supabaseClient.auth.onAuthStateChange) {
      if (state.session?.user != null) {
        return UserModel.fromSupabase(state.session!.user.toJson());
      }
    }

    throw Exception('Google sign in failed: No session established');
  }

  @override
  Future<void> signOut() async {
    print('<<<<<<<<<<<[signOut]>>>>>>>>>>>>>');
    await supabaseClient.auth.signOut();
  }

  @override
  Future<ProfileModel> fetchProfile(String userId) async {
    print('<<<<<<<<<<<[fetchProfile]>>>>>>>>>>>>>');
    final response = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) {
      throw Exception('Profile not found for user: $userId');
    }
    return ProfileModel.fromSupabase(response);
  }

  @override
  Future<void> deleteDeviceRow() async {
    print('<<<<<<<<<<<[deleteDeviceRow]>>>>>>>>>>>>>');
    final user = supabaseClient.auth.currentUser;
    if (user == null) return;
    await supabaseClient.from('user_devices').delete().eq('user_id', user.id);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    print('<<<<<<<<<<<[updateProfile]>>>>>>>>>>>>>');
    final response = await supabaseClient
        .from('profiles')
        .update(profile.toUpdateJson())
        .eq('id', profile.id)
        .maybeSingle();
    if (response == null) {
      throw Exception('Profile not found for user: ${profile.id}');
    }
    return ProfileModel.fromSupabase(response);
  }

  @override
  UserModel? getCurrentSupabaseUser() {
    print('<<<<<<<<<<<[getCurrentSupabaseUser]>>>>>>>>>>>>>');
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabase(user.toJson());
  }

  @override
  Future<void> resetPassword({required String email}) async {
    print('<<<<<<<<<<<[resetPassword]>>>>>>>>>>>>>');
    await supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConstants.supabaseRedirectUrl,
    );
  }

  @override
  Stream<AuthState> get authStateChanges => supabaseClient.auth.onAuthStateChange;
}

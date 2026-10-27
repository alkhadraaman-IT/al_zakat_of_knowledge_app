import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '/core/utils/supabase_timeout.dart';
import '/core/constants/app_constants.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

/// Abstract remote data source for authentication.
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String university,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<ProfileModel> fetchProfile(String userId);

  Future<ProfileModel> updateProfile(ProfileModel profile);

  Future<void> deleteDeviceRow();

  UserModel? getCurrentSupabaseUser();

  Future<void> resetPassword({required String email});

  Stream<AuthState> get authStateChanges;
}

/// Supabase & Firebase implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;
       
  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print('<<<<<<<<<<<[signInWithEmailAndPassword]>>>>>>>>>>>>>');
    final response = await supabaseClient.auth
        .signInWithPassword(email: email, password: password)
        .withAuthTimeout(operationName: 'signInWithEmailAndPassword');

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
    final response = await supabaseClient.auth
        .signUp(
          email: email,
          password: password,
          data: {'full_name': fullName, 'university': university},
        )
        .withAuthTimeout(operationName: 'signUpWithEmailAndPassword');

    if (response.user == null) {
      throw Exception('Sign up failed: No user returned');
    }

    return UserModel.fromSupabase(response.user!.toJson());
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    print('<<<<<<<<<<<[signInWithGoogle]>>>>>>>>>>>>>');
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول عبر Google');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user == null) {
        throw Exception('فشل تسجيل الدخول عبر Google');
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e, stackTrace) {
      print('<<<<<<<<<<<[Google Sign-In Error Details]>>>>>>>>>>>>>');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    print('<<<<<<<<<<<[signOut]>>>>>>>>>>>>>');
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await supabaseClient.auth.signOut().withAuthTimeout(
      operationName: 'signOut',
    );
  }

  @override
  Future<ProfileModel> fetchProfile(String userId) async {
    print('<<<<<<<<<<<[fetchProfile]>>>>>>>>>>>>>');
    final response =
        await (supabaseClient
                .from('profiles')
                .select()
                .eq('id', userId)
                .maybeSingle())
            .withTimeout(operationName: 'fetchProfile');
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
    await supabaseClient
        .from('user_devices')
        .delete()
        .eq('user_id', user.id)
        .withTimeout(operationName: 'deleteDeviceRow');
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    print('<<<<<<<<<<<[updateProfile]>>>>>>>>>>>>>');
    final response =
        await (supabaseClient
                .from('profiles')
                .update(profile.toUpdateJson())
                .eq('id', profile.id)
                .select()
                .maybeSingle())
            .withTimeout(operationName: 'updateProfile');
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
    await supabaseClient.auth
        .resetPasswordForEmail(
          email,
          redirectTo: AppConstants.supabaseRedirectUrl,
        )
        .withAuthTimeout(operationName: 'resetPassword');
  }

  @override
  Stream<AuthState> get authStateChanges =>
      supabaseClient.auth.onAuthStateChange;
}

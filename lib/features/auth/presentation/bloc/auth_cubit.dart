import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../data/models/user_model.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_state.dart';

/// Authentication Cubit managing all auth-related state transitions.
///
/// Exposes clean direct async methods (no events).
/// Subscribes directly to Supabase's auth state stream
/// so a session delivered via the OAuth deep-link callback
/// immediately emits [AuthAuthenticated].
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  // final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SupabaseClient supabaseClient;

  StreamSubscription<dynamic>? _authStreamSubscription;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    // required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.supabaseClient,
  }) : super(const AuthInitial()) {
    _listenToAuthStateChanges();
  }
  bool _isSigningOut = false;

  /// Checks the persisted auth status on app start.
  Future<void> checkAuthStatus() async {
    print('<<<<<<<<<<<[AuthCubit.checkAuthStatus]>>>>>>>>>>>>>');
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  /// Signs in with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print('<<<<<<<<<<<[AuthCubit.signInWithEmail]>>>>>>>>>>>>>');
    emit(const AuthLoading());
    final result = await signInUseCase(email: email, password: password);
    result.fold(
      (failure) =>
          emit(AuthError(message: failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Signs up with email, password, and academic info.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String university,
  }) async {
    print('<<<<<<<<<<<[AuthCubit.signUp]>>>>>>>>>>>>>');
    emit(const AuthLoading());
    final result = await signUpUseCase(
      email: email,
      password: password,
      fullName: fullName,
      university: university,
    );
    result.fold(
      (failure) =>
          emit(AuthError(message: failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Signs in with Google SSO via the OAuth deep-link flow.
  // Future<void> signInWithGoogle() async {
  //   print('<<<<<<<<<<<[AuthCubit.signInWithGoogle]>>>>>>>>>>>>>');
  //   emit(const AuthLoading());
  //   final result = await signInWithGoogleUseCase();
  //   result.fold(
  //     (failure) =>
  //         emit(AuthError(message: failure.message, code: failure.code)),
  //     (user) => emit(AuthAuthenticated(user: user)),
  //   );
  // }

  /// Signs out the current user.
  Future<void> signOut() async {
    print('<<<<<<<<<<<[AuthCubit.signOut]>>>>>>>>>>>>>');
    _isSigningOut = true; // 👈
    emit(const AuthLoading());
    final result = await signOutUseCase();
    result.fold(
      (failure) {
        _isSigningOut = false; // 👈
        emit(AuthError(message: failure.message, code: failure.code));
      },
      (_) {
        _isSigningOut = false; // 👈
        emit(const AuthUnauthenticated());
      },
    );
  }

  /// Listens to Supabase's auth state stream so that a session
  /// delivered via the OAuth deep-link callback immediately
  /// emits [AuthAuthenticated].
  ///
  /// The bridge fires on [AuthChangeEvent.signedIn] — or on any
  /// event carrying a valid session user while the cubit is not
  /// authenticated yet. That covers both the mid-sign-in deep
  /// link (the [AuthLoading] state) and a cold-start deep link
  /// that races ahead of [checkAuthStatus] (the app was killed
  /// while the external browser was open).
  ///
  /// supabase_flutter's built-in app_links observer intercepts
  /// the custom-scheme callback and extracts the session via
  /// `getSessionFromUrl`; the in-flight sign-in use case then
  /// updates the Hive cache through the repository (user row +
  /// best-effort profile sync), so the UI unblocks the moment
  /// the session lands.
  void _listenToAuthStateChanges() {
    _authStreamSubscription = supabaseClient.auth.onAuthStateChange.listen(
      (authState) {
        if (isClosed) return;

        // 👈 لا تطلق AuthAuthenticated إذا كنا بصدد تسجيل الخروج
        if (_isSigningOut) return;

        final user = authState.session?.user;
        if (user == null) return;

        final isSignInCallback =
            authState.event == AuthChangeEvent.signedIn ||
            state is! AuthAuthenticated;
        if (!isSignInCallback) return;

        emit(AuthAuthenticated(user: UserModel.fromSupabase(user.toJson())));
      },
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  @override
  Future<void> close() {
    _authStreamSubscription?.cancel();
    return super.close();
  }
}

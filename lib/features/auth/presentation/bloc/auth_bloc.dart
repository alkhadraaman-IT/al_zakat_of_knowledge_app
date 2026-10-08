import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC managing all auth-related state transitions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInWithGoogleRequested>(_onAuthSignInWithGoogleRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('<<<<<<<<<<<[AuthBloc._onAuthCheckRequested]>>>>>>>>>>>>>');
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

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('<<<<<<<<<<<[AuthBloc._onAuthSignInRequested]>>>>>>>>>>>>>');
    emit(const AuthLoading());
    final result = await signInUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('<<<<<<<<<<<[AuthBloc._onAuthSignUpRequested]>>>>>>>>>>>>>');
    emit(const AuthLoading());
    final result = await signUpUseCase(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      university: event.university,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('<<<<<<<<<<<[AuthBloc._onAuthSignInWithGoogleRequested]>>>>>>>>>>>>>');
    emit(const AuthLoading());
    final result = await signInWithGoogleUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('<<<<<<<<<<<[AuthBloc._onAuthSignOutRequested]>>>>>>>>>>>>>');
    emit(const AuthLoading());
    final result = await signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message, code: failure.code)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}

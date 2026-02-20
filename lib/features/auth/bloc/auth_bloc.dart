import 'package:circlo_app/core/storage/secure_storage.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/auth/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  final SecureStorageService _storage;

  AuthBloc(this._authRepository, this._storage) : super(AuthStateInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSignupRequested>(_onSignup);
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _storage.getToken();

    if (token == null) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final user = await _authRepository.getMe();
      emit(AuthAuthenticated(user));
    } catch (_) {
      await _storage.deleteToken();
      emit(AuthFailure("Session expired, please login again"));
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await _authRepository.login(event.email, event.password);

      await _storage.saveToken(response.token);

      emit(AuthAuthenticated(response.user));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? "Login failed";
      emit(AuthFailure(message));
    } catch (e) {
      emit(AuthFailure("An unexpected error occurred"));
    }
  }

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await _authRepository.signup(
        name: event.name,
        email: event.email,
        password: event.password,
        image: event.image,
      );

      await _storage.saveToken(response.token);

      emit(AuthAuthenticated(response.user));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? "Signup failed";
      emit(AuthFailure(message));
    } catch (e) {
      emit(AuthFailure("An unexpected error occurred"));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.deleteToken();
    emit(AuthUnauthenticated());
  }
}

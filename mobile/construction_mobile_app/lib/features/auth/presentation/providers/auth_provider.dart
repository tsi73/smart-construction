import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../../core/storage/app_local_storage.dart';
import 'package:flutter/foundation.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureTokenStorageProvider),
  );
});

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? user;

  AuthState({required this.status, this.errorMessage, this.user});

  AuthState copyWith(
      {AuthStatus? status, String? errorMessage, Map<String, dynamic>? user}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final AppLocalStorage _localStorage;
  final TokenStorage _tokenStorage;

  AuthNotifier(this._repository, this._localStorage, this._tokenStorage)
      : super(AuthState(status: AuthStatus.initial));

  Future<void> checkStatus() async {
    final result = await _repository.checkAuthStatus();
    await result.fold(
      (failure) async {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          await getUserMe();
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  Future<void> getUserMe() async {
    if (kDebugMode) {
      debugPrint('AuthProvider: Fetching user info');
    }
    final result = await _repository.getUserMe();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('AuthProvider: getUserMe failed: ${failure.message}');
        }
        state = state.copyWith(status: AuthStatus.unauthenticated);
      },
      (user) async {
        // Save user ID for cache scoping
        if (user['id'] != null) {
          await _tokenStorage.saveUserId(user['id'].toString());
        }
        if (kDebugMode) {
          debugPrint(
              'AuthProvider: User fetched successfully: ${user['email']}');
          debugPrint('AuthProvider: Setting auth state to authenticated');
        }
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        if (kDebugMode) {
          debugPrint('AuthProvider: Auth state is now: ${state.status}');
        }
      },
    );
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    final result = await _repository.updateProfile(userData);
    return await result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) async {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    if (kDebugMode) {
      debugPrint('AuthProvider: Login started for $email');
      debugPrint('AuthProvider: Auth state set to loading');
    }
    final result = await _repository.login(email: email, password: password);
    await result.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint('AuthProvider: Login failed: ${failure.message}');
          debugPrint('AuthProvider: Auth state set to error');
        }
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
      },
      (_) async {
        if (kDebugMode) {
          debugPrint(
              'AuthProvider: Login successful, clearing cache and fetching user');
        }
        // Clear any cached data from previous user
        await _localStorage.clearAllUserData();
        await getUserMe();
      },
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.register(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
    result.fold(
      (failure) => state = state.copyWith(
          status: AuthStatus.error, errorMessage: failure.message),
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    // Clear all user-specific cached data
    await _localStorage.clearAllUserData();
    // Clear user ID
    await _tokenStorage.clearUserId();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  void handleSessionExpired() {
    // Clear all user-specific cached data
    _localStorage.clearAllUserData();
    // Clear user ID
    _tokenStorage.clearUserId();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    if (kDebugMode) {
      debugPrint('AuthProvider: Forgot password request for $email');
    }
    final result = await _repository.forgotPassword(email);
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
              'AuthProvider: Forgot password failed: ${failure.message}');
        }
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
      },
      (_) {
        if (kDebugMode) {
          debugPrint('AuthProvider: Forgot password successful');
        }
        state = state.copyWith(status: AuthStatus.unauthenticated);
      },
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      },
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(appLocalStorageProvider),
    ref.watch(secureTokenStorageProvider),
  );
});

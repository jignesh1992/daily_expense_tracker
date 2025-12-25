import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocketa_expense_tracker/services/firebase_service.dart';
import 'package:pocketa_expense_tracker/services/storage_service.dart';
import 'package:pocketa_expense_tracker/services/api_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true)) {
    _init();
  }

  final _storageService = StorageService();
  final _apiService = ApiService();

  Future<void> _init() async {
    FirebaseService.authStateChanges.listen((user) {
      state = state.copyWith(user: user, error: null);
      if (user != null) {
        _verifyToken();
      }
    });

    final currentUser = FirebaseService.currentUser;
    state = state.copyWith(user: currentUser, isLoading: false);
    if (currentUser != null) {
      await _verifyToken();
    }
  }

  Future<void> _verifyToken() async {
    try {
      final token = await FirebaseService.getIdToken();
      if (token != null) {
        await _storageService.saveAuthToken(token);
        final userInfo = await _apiService.verifyToken();
        await _storageService.saveUserId(userInfo['user']['userId'] as String);
      }
    } catch (e) {
      print('Token verification error: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await FirebaseService.signInWithEmailAndPassword(email, password);
      await _verifyToken();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await FirebaseService.signUpWithEmailAndPassword(email, password);
      await _verifyToken();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseService.signOut();
      await _storageService.clearAll();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

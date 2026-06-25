import 'package:flutter/material.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/core/storage/secure_storage.dart';
import 'package:nawasena/features/auth/models/user_model.dart';
import 'package:nawasena/features/auth/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// State management untuk autentikasi.
/// Dipegang oleh ChangeNotifierProvider di root app (nawasena_app.dart).
class AuthProvider extends ChangeNotifier {
  final _repo    = AuthRepository.instance;
  final _storage = SecureStorage.instance;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String?   _errorMessage;

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool       get isLoading    => _status == AuthStatus.loading;
  bool       get isAuth       => _status == AuthStatus.authenticated && _user != null;

  // ── Cek sesi tersimpan saat app dibuka (untuk SplashScreen) ───────────────
  Future<void> checkStoredSession() async {
    _setStatus(AuthStatus.loading);

    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    // Coba restore user dari storage lokal dulu (cepat, tanpa network)
    final userJson = await _storage.getUserJson();
    if (userJson != null) {
      _user = UserModel.fromJsonString(userJson);
    }

    // Verifikasi token ke server di background
    try {
      _user = await _repo.fetchMe();
      await _storage.saveUserJson(_user!.toJsonString());
      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      // Token tidak valid — paksa logout
      await _storage.clearAll();
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // ── Login Email/Password ───────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final response = await _repo.login(email: email, password: password);
      _user = await _repo.saveAuthResponse(response);
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.firstError ?? e.message);
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan. Coba lagi.');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? classCode,
  }) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final response = await _repo.register(
        name: name, email: email, password: password,
        passwordConfirmation: passwordConfirmation, classCode: classCode,
      );
      _user = await _repo.saveAuthResponse(response);
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.firstError ?? e.message);
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan. Coba lagi.');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // ── Google SSO ─────────────────────────────────────────────────────────────
  Future<bool> signInWithGoogle({String? classCode}) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final response = await _repo.signInWithGoogle(classCode: classCode);
      _user = await _repo.saveAuthResponse(response);
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 0 && e.message == 'Login dibatalkan.') {
        // User tap tombol "Batal" di dialog Google — bukan error sebenarnya
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
      _setError(e.message);
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _setError('Login Google gagal. Coba lagi.');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  // ── Update user lokal (setelah update profil) ─────────────────────────────
  void updateUser(UserModel user) {
    _user = user;
    _storage.saveUserJson(user.toJsonString());
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}

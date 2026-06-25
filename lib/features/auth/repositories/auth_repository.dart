import 'package:google_sign_in/google_sign_in.dart';
import 'package:nawasena/core/constants/app_constants.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/core/network/api_client.dart';
import 'package:nawasena/core/storage/secure_storage.dart';
import 'package:nawasena/features/auth/models/user_model.dart';

/// Mengelola semua request HTTP yang berkaitan dengan autentikasi.
/// Dipanggil oleh AuthProvider — tidak ada logika UI di sini.
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final _api     = ApiClient.instance;
  final _storage = SecureStorage.instance;

  // ── Login Email/Password ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? classCode,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (classCode != null && classCode.isNotEmpty) 'class_code': classCode,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ── Google SSO ─────────────────────────────────────────────────────────────
  /// Panggil Google Sign-In SDK, ambil idToken, kirim ke Laravel.
  Future<Map<String, dynamic>> signInWithGoogle({String? classCode}) async {
    // 1. Inisialisasi Google Sign-In (idempotent jika sudah diinit)
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConstants.googleWebClientId,
    );

    // 2. Minta user memilih akun Google
    final googleUser = await GoogleSignIn.instance.authenticate(
      scopeHint: ['email', 'profile'],
    );

    if (googleUser == null) {
      throw const ApiException(message: 'Login dibatalkan.', statusCode: 0);
    }

    // 3. Ambil idToken
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw const ApiException(
        message: 'Gagal mendapatkan token dari Google. Coba lagi.',
        statusCode: 0,
      );
    }

    // 4. Kirim idToken ke Backend Laravel
    return await _api.post<Map<String, dynamic>>(
      '/auth/google/callback',
      data: {
        'id_token': idToken,
        if (classCode != null && classCode.isNotEmpty) 'class_code': classCode,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ── Fetch Profile ──────────────────────────────────────────────────────────
  Future<UserModel> fetchMe() async {
    return await _api.get<UserModel>(
      '/auth/me',
      parser: (data) {
        final map = (data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        return UserModel.fromJson(map);
      },
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Tidak masalah jika server error — tetap hapus token lokal
    }
    await _storage.clearAll();

    // Sign out dari Google (versi 7+ tidak perlu cek isSignedIn lagi)
    try {
      await GoogleSignIn.instance.signOut();
      // Opsional: disconnect() digunakan agar saat user login Google lagi, 
      // mereka diminta memilih akun ulang (tidak auto-login dengan akun sebelumnya).
      await GoogleSignIn.instance.disconnect(); 
    } catch (_) {
      // Abaikan jika terjadi error (misalnya karena memang tidak login via Google)
    }
  }

  // ── Simpan token & user ke storage ────────────────────────────────────────
  Future<UserModel> saveAuthResponse(Map<String, dynamic> responseBody) async {
    final dataMap = responseBody['data'] as Map<String, dynamic>;
    final token   = dataMap['access_token'] as String;
    final userMap = dataMap['user']         as Map<String, dynamic>;
    final user    = UserModel.fromJson(userMap);

    await _storage.saveToken(token);
    await _storage.saveUserJson(user.toJsonString());

    return user;
  }
}

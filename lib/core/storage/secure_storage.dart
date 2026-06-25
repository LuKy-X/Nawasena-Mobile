import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nawasena/core/constants/app_constants.dart';

/// Wrapper singleton untuk flutter_secure_storage.
/// Semua interaksi dengan token & data persisten harus melalui class ini.
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Token ──────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<String?> getToken() =>
      _storage.read(key: AppConstants.tokenKey);

  Future<void> deleteToken() =>
      _storage.delete(key: AppConstants.tokenKey);

  // ── Raw user JSON (untuk restore session tanpa hit API) ────────────────────
  Future<void> saveUserJson(String json) =>
      _storage.write(key: AppConstants.userKey, value: json);

  Future<String?> getUserJson() =>
      _storage.read(key: AppConstants.userKey);

  Future<void> deleteUserJson() =>
      _storage.delete(key: AppConstants.userKey);

  // ── Clear semua data (logout) ──────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

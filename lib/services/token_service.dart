import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// TokenService — Mengelola penyimpanan token JWT secara aman.
/// Menggunakan FlutterSecureStorage (Keychain iOS, EncryptedSharedPrefs Android).
class TokenService {
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final _storage = const FlutterSecureStorage(aOptions: _androidOptions);

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ─── Token Methods ──────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<void> deleteToken() async => _storage.delete(key: _tokenKey);

  Future<void> saveRefreshToken(String token) async =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() async =>
      _storage.read(key: _refreshTokenKey);

  // ─── Generic Raw Storage (untuk cache user data, dll) ──────────────────────

  Future<void> writeRaw(String key, String value) async =>
      _storage.write(key: key, value: value);

  Future<String?> readRaw(String key) async => _storage.read(key: key);

  Future<void> deleteRaw(String key) async => _storage.delete(key: key);

  // ─── Full Logout ────────────────────────────────────────────────────────────

  Future<void> deleteAllTokens() async => _storage.deleteAll();
}
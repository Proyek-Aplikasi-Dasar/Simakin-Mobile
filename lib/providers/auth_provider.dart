import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';

/// AuthProvider — State management autentikasi.
///
/// Responsibilities:
/// - Menyimpan status login (authenticated / not)
/// - Menyimpan data user yang sedang login
/// - Memanggil AuthService untuk login/logout ke API
/// - Notifikasi GoRouter untuk redirect otomatis
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TokenService _tokenService = TokenService();

  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  UserModel? _currentUser;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkLoginStatus();
  }

  /// Cek token tersimpan saat app pertama dibuka (dari secure storage)
  Future<void> _checkLoginStatus() async {
    final token = await _tokenService.getToken();
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      // Muat data user dari cache lokal
      _currentUser = await _loadCachedUser();
      // (Opsional) validasi token ke server di background — tidak blocking
      _validateTokenInBackground();
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Validasi token di background (tidak blocking startup).
  /// Jika token expired, logout otomatis.
  Future<void> _validateTokenInBackground() async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      // Token tidak valid / expired — logout lokal
      await _clearSession();
    } else {
      // Update cache dengan data user terbaru
      _currentUser = user;
      await _cacheUser(user);
      notifyListeners();
    }
  }

  // ─── Login ──────────────────────────────────────────────────────────────────

  /// Login ke API menggunakan email & password.
  /// Return true jika berhasil, false jika gagal.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    if (result.success) {
      // Simpan token ke secure storage
      await _tokenService.saveToken(result.token!);
      // Cache data user
      _currentUser = result.user;
      await _cacheUser(result.user!);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────

  /// Logout — hapus token lokal dan invalidate di server.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // Kirim logout request ke server (best effort — tidak blocking)
    await _authService.logout();

    // Hapus semua data lokal
    await _clearSession();
  }

  /// Hapus semua data sesi lokal (token + cache user).
  Future<void> _clearSession() async {
    await _tokenService.deleteAllTokens();
    await _clearCachedUser();
    _isAuthenticated = false;
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  // ─── Error Handling ─────────────────────────────────────────────────────────

  /// Clear error message (dipanggil saat user mulai mengetik ulang)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Cache User ───────────────────────────────────────────────────────────
  // Menyimpan data user ke secure storage agar tidak perlu re-fetch setiap buka app

  static const String _userCacheKey = 'cached_user';

  Future<void> _cacheUser(UserModel user) async {
    await _tokenService.writeRaw(_userCacheKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> _loadCachedUser() async {
    final raw = await _tokenService.readRaw(_userCacheKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearCachedUser() async {
    await _tokenService.deleteRaw(_userCacheKey);
  }
}
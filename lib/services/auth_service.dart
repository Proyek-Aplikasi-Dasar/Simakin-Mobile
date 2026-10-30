import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_client.dart';

/// Hasil login — bisa sukses (dengan data) atau gagal (dengan pesan error)
class AuthResult {
  final bool success;
  final String? token;
  final UserModel? user;
  final String? errorMessage;

  const AuthResult._({
    required this.success,
    this.token,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success({required String token, required UserModel user}) {
    return AuthResult._(success: true, token: token, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(success: false, errorMessage: message);
  }
}

/// AuthService — Mengelola komunikasi dengan endpoint autentikasi Laravel.
///
/// Endpoint yang didukung (standar Laravel Sanctum):
/// POST /api/login   → { data: { user: {...}, token: '...' } }
///                  → { user: {...}, token: '...' }
///                  → { access_token: '...', user: {...} }
/// POST /api/logout  → 200 OK (invalidate token di server)
/// GET  /api/user    → data user yang sedang login
///
/// Untuk mengubah pola response, sesuaikan blok _parseLoginResponse.
class AuthService {
  final Dio _dio = ApiClient().dio;

  /// Login dengan identifier (email atau NIS) dan password.
  /// Mendukung dua tipe field: `email` (default) atau `identifier` (NIS/username).
  /// Return [AuthResult.success] jika berhasil, [AuthResult.failure] jika gagal.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return _parseLoginResponse(response.data);
    } on DioException catch (e) {
      return AuthResult.failure(_parseDioError(e));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Login dengan identifier fleksibel (bisa email, NIS, atau username).
  /// Digunakan jika BE menggunakan field `identifier` yang bisa berupa email/NIS.
  Future<AuthResult> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      return _parseLoginResponse(response.data);
    } on DioException catch (e) {
      return AuthResult.failure(_parseDioError(e));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // ─── Parser Response ──────────────────────────────────────────────────────
  // Mendukung berbagai pola response JSON dari Laravel:
  // Pola A: { status: 'success', data: { user: {...}, token: '...' } }       ← SimakIn default
  // Pola B: { user: {...}, token: '...' }                                    ← Simple API
  // Pola C: { access_token: '...', token_type: 'Bearer', user: {...} }       ← Sanctum/Passport
  // Pola D: { data: { token: '...', siswa: {...} } }                         ← nested siswa key
  AuthResult _parseLoginResponse(dynamic responseData) {
    if (responseData == null) {
      return AuthResult.failure('Response kosong dari server.');
    }

    try {
      Map<String, dynamic>? userData;
      String? token;

      if (responseData['data'] is Map) {
        // Pola A & D — ada wrapper "data"
        final data = responseData['data'] as Map<String, dynamic>;

        // Coba ambil token dari berbagai key
        token = data['token'] as String? ??
            data['access_token'] as String?;

        // Coba ambil user dari berbagai key
        userData = data['user'] as Map<String, dynamic>? ??
            data['siswa'] as Map<String, dynamic>? ??
            data['profile'] as Map<String, dynamic>?;

        // Jika user tidak ada di dalam "data", coba di root
        userData ??= responseData['user'] as Map<String, dynamic>?;
      } else {
        // Pola B & C — flat response
        userData = responseData['user'] as Map<String, dynamic>? ??
            responseData['siswa'] as Map<String, dynamic>?;
        token = responseData['token'] as String? ??
            responseData['access_token'] as String?;
      }

      if (token == null || token.isEmpty) {
        return AuthResult.failure(
            'Token tidak ditemukan dalam response. Hubungi tim Backend.');
      }
      if (userData == null) {
        return AuthResult.failure(
            'Data user tidak ditemukan dalam response. Hubungi tim Backend.');
      }

      return AuthResult.success(
        token: token,
        user: UserModel.fromJson(userData),
      );
    } catch (e) {
      return AuthResult.failure(
          'Gagal memproses response dari server: $e');
    }
  }

  // ─── Error Parser ─────────────────────────────────────────────────────────
  String _parseDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Coba ambil pesan error dari body response Laravel
    if (data is Map) {
      // Laravel validation error: { errors: { field: ['msg'] } }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final msgs = errors[firstKey];
          if (msgs is List && msgs.isNotEmpty) {
            return msgs.first.toString();
          }
        }
      }
      // Laravel standard message: { message: '...' }
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
    }

    // Fallback berdasarkan HTTP status code
    switch (statusCode) {
      case 401:
        return 'Email/NIS atau password salah. Periksa kembali.';
      case 403:
        return 'Akun ini tidak memiliki akses aplikasi siswa.';
      case 422:
        return 'Data yang dimasukkan tidak valid.';
      case 429:
        return 'Terlalu banyak percobaan login. Tunggu beberapa menit.';
      case 500:
        return 'Terjadi kesalahan pada server. Coba lagi nanti.';
      default:
        return ApiClient.parseErrorMessage(e);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Logout — invalidate token di server (Laravel Sanctum).
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } on DioException {
      // Abaikan error logout — token sudah dihapus dari lokal
    }
  }

  // ─── Get Current User ─────────────────────────────────────────────────────

  /// Ambil data user yang sedang login (untuk refresh profile).
  /// Mendukung response { data: {...} } dan flat { ...user fields... }.
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dio.get('/user');
      final data = response.data;

      Map<String, dynamic> userData;
      if (data is Map && data['data'] is Map) {
        userData = data['data'] as Map<String, dynamic>;
      } else if (data is Map) {
        userData = data as Map<String, dynamic>;
      } else {
        return null;
      }

      return UserModel.fromJson(userData);
    } on DioException {
      return null;
    }
  }
}

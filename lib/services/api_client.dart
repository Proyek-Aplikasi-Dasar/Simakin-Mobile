import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'token_service.dart';

/// ApiClient — Dio HTTP client singleton dengan interceptor untuk:
/// 1. Menambahkan Bearer token (Laravel Sanctum) otomatis ke setiap request
/// 2. Header JSON standar
/// 3. Menangani error 401 (token expired/unauthorized)
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConfig.receiveTimeoutSeconds),
        sendTimeout: const Duration(seconds: AppConfig.sendTimeoutSeconds),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_buildAuthInterceptor());

    // Logging hanya saat debug
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),
      );
    }
  }

  Dio get dio => _dio;

  InterceptorsWrapper _buildAuthInterceptor() {
    final tokenService = TokenService();

    return InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        final token = await tokenService.getToken();
        if (token != null) {
          // Laravel Sanctum menggunakan format: Bearer {token}
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },

      onResponse: (Response response, ResponseInterceptorHandler handler) {
        return handler.next(response);
      },

      onError: (DioException error, ErrorInterceptorHandler handler) async {
        switch (error.response?.statusCode) {
          case 401:
            // Token tidak valid / expired — token akan dihapus oleh AuthProvider
            debugPrint('[ApiClient] 401 Unauthorized — sesi berakhir, silakan login ulang');
            break;
          case 403:
            debugPrint('[ApiClient] 403 Forbidden — tidak memiliki akses');
            break;
          case 404:
            debugPrint('[ApiClient] 404 Not Found — ${error.requestOptions.path}');
            break;
          case 422:
            debugPrint('[ApiClient] 422 Validation Error — ${error.response?.data}');
            break;
          case 500:
            debugPrint('[ApiClient] 500 Server Error');
            break;
          default:
            if (error.type == DioExceptionType.connectionTimeout) {
              debugPrint('[ApiClient] Connection Timeout');
            } else if (error.type == DioExceptionType.connectionError) {
              debugPrint('[ApiClient] Connection Error — periksa koneksi internet atau URL server');
            }
        }
        return handler.next(error);
      },
    );
  }

  /// Helper untuk parse pesan error dari response Laravel
  static String parseErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      // Laravel validation error: { errors: { field: ['msg'] } }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstKey = errors.keys.first;
        final msgs = errors[firstKey];
        if (msgs is List && msgs.isNotEmpty) return msgs.first.toString();
      }
      // Laravel standard error: { message: '...' }
      if (data['message'] != null) return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan server sudah berjalan.';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Koneksi timeout. Periksa koneksi internet Anda.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
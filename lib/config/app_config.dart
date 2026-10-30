import 'package:flutter/foundation.dart';

/// AppConfig — Konfigurasi global aplikasi SimakIn.
///
/// ─── CARA KONFIGURASI URL BACKEND ───────────────────────────────────────────
/// 1. Android Emulator (default): http://10.0.2.2:8000/api
/// 2. Web (Chrome/Edge):          http://127.0.0.1:8000/api
/// 3. HP Fisik (USB Debugging):   Ganti [_physicalDeviceIp] dengan IP komputer kamu
///    → Cari IP dengan: ipconfig (Windows) atau ifconfig (macOS/Linux)
///    → Contoh: '192.168.1.100' → baseUrl: 'http://192.168.1.100:8000/api'
/// 4. Untuk testing produksi:     Ganti dengan domain/IP server Laravel
///
/// CATATAN: Pastikan Laravel server aktif (php artisan serve --host=0.0.0.0)
///          agar bisa diakses dari HP fisik di jaringan yang sama.
class AppConfig {
  AppConfig._();

  // ─── PHYSICAL DEVICE IP (Ubah ini saat testing di HP fisik) ─────────────────
  /// IP komputer yang menjalankan Laravel BE.
  /// Contoh: '192.168.1.100' atau '10.0.1.5'
  static const String _physicalDeviceIp = '10.0.2.2'; // default emulator

  // ─── BASE URL ───────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    // Untuk HP fisik: ganti _physicalDeviceIp dengan IP komputer BE
    return 'http://$_physicalDeviceIp:8000/api';
  }

  // ─── TIMEOUTS ───────────────────────────────────────────────────────────────
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 20;
  static const int sendTimeoutSeconds = 15;

  // ─── STORAGE KEYS ───────────────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // ─── APP METADATA ───────────────────────────────────────────────────────────
  static const String appName = 'SimakIn';
  static const String appVersion = '1.0.0';
  static const String schoolName = 'SMKN 1 Magelang';
}

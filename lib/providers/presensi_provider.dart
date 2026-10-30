import 'package:flutter/material.dart';
import '../models/presensi_model.dart';

/// PresensiProvider — State management untuk fitur Presensi Harian.
///
/// Menggunakan data dummy yang di-hardcode. Saat API sudah siap,
/// cukup ganti bagian _loadDummyData() dengan pemanggilan service,
/// tanpa mengubah apapun di UI / screen.
class PresensiProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  // Data presensi hari ini (null = belum presensi hari ini)
  PresensiModel? _presensiHariIni;

  // Riwayat presensi (dummy list)
  List<PresensiModel> _riwayatPresensi = [];

  // ─── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  PresensiModel? get presensiHariIni => _presensiHariIni;
  List<PresensiModel> get riwayatPresensi => _riwayatPresensi;

  /// Apakah siswa sudah presensi hari ini
  bool get sudahPresensiHariIni => _presensiHariIni != null;

  PresensiProvider() {
    loadPresensi();
  }

  // ─── Load Data ──────────────────────────────────────────────────────────────

  /// Memuat data presensi. Saat API siap, ganti isi method ini
  /// dengan pemanggilan [PresensiService.fetchPresensi()].
  Future<void> loadPresensi() async {
    _isLoading = true;
    notifyListeners();

    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 600));

    _loadDummyData();

    _isLoading = false;
    notifyListeners();
  }

  /// Data dummy hardcode. Swap bagian ini dengan service call saat API ready.
  void _loadDummyData() {
    final today = _todayString();

    // Untuk simulasi: set null agar siswa bisa mengisi presensi hari ini.
    // Ubah ke PresensiModel(...) untuk simulasi state "sudah presensi".
    _presensiHariIni = null;

    _riwayatPresensi = [
      PresensiModel(
        id: 10,
        tanggal: _dateString(1),
        statusKehadiran: 'hadir',
        jamMasuk: '07:28',
        jamPulang: '16:05',
        shiftKerja: '07:30 - 16:00 WIB',
        latitude: -7.4778,
        longitude: 110.2177,
        alamatLokasi: 'Jl. Dr. Sutomo No.1, Magelang',
        dikirimPada: '16:20 WIB',
        status: 'disetujui',
      ),
      PresensiModel(
        id: 9,
        tanggal: _dateString(2),
        statusKehadiran: 'hadir',
        jamMasuk: '07:31',
        jamPulang: '16:00',
        shiftKerja: '07:30 - 16:00 WIB',
        latitude: -7.4778,
        longitude: 110.2177,
        alamatLokasi: 'Jl. Dr. Sutomo No.1, Magelang',
        dikirimPada: '16:20 WIB',
        status: 'disetujui',
      ),
      PresensiModel(
        id: 8,
        tanggal: _dateString(3),
        statusKehadiran: 'izin',
        keterangan: 'Keperluan keluarga mendesak',
        suratFile: 'surat_izin_081024.pdf',
        dikirimPada: '07:10 WIB',
        status: 'disetujui',
      ),
      PresensiModel(
        id: 7,
        tanggal: _dateString(4),
        statusKehadiran: 'hadir',
        jamMasuk: '07:25',
        jamPulang: '15:30',
        shiftKerja: '07:30 - 15:30 WIB',
        latitude: -7.4779,
        longitude: 110.2180,
        alamatLokasi: 'Jl. Dr. Sutomo No.1, Magelang',
        dikirimPada: '16:20 WIB',
        status: 'disetujui',
      ),
      PresensiModel(
        id: 6,
        tanggal: _dateString(5),
        statusKehadiran: 'sakit',
        keterangan: 'Demam dan batuk, sudah periksa ke dokter',
        suratFile: 'surat_sakit_061024.pdf',
        dikirimPada: '08:00 WIB',
        status: 'disetujui',
      ),
      PresensiModel(
        id: 5,
        tanggal: _dateString(6),
        statusKehadiran: 'libur',
        keterangan: 'Hari Minggu',
        dikirimPada: null,
        status: 'terkirim',
      ),
      PresensiModel(
        id: 4,
        tanggal: _dateString(7),
        statusKehadiran: 'hadir',
        jamMasuk: '07:29',
        jamPulang: '16:10',
        shiftKerja: '07:30 - 16:00 WIB',
        latitude: -7.4778,
        longitude: 110.2177,
        alamatLokasi: 'Jl. Dr. Sutomo No.1, Magelang',
        dikirimPada: '16:20 WIB',
        status: 'disetujui',
      ),
      PresensiModel(
        id: 3,
        tanggal: _dateString(8),
        statusKehadiran: 'hadir',
        jamMasuk: '07:33',
        jamPulang: '16:00',
        shiftKerja: '07:30 - 16:00 WIB',
        latitude: -7.4778,
        longitude: 110.2177,
        alamatLokasi: 'Jl. Dr. Sutomo No.1, Magelang',
        dikirimPada: '16:20 WIB',
        status: 'disetujui',
      ),
    ];
    // ignore hari ini dari riwayat jika sudah ada
    _riwayatPresensi.removeWhere((p) => p.tanggal == today);
  }

  // ─── Submit Presensi ────────────────────────────────────────────────────────

  /// Submit presensi hari ini.
  ///
  /// Parameter [fotoPath] & [suratPath] adalah path file lokal (dummy: null).
  /// Saat API siap, ganti method ini agar upload ke [PresensiService.submitPresensi()].
  Future<bool> submitPresensi({
    required String statusKehadiran,
    String? fotoPath,
    String? suratPath,
    String? keterangan,
    double? latitude,
    double? longitude,
    String? alamatLokasi,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final now = TimeOfDay.now();
    final jamNow =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Buat record presensi baru (dummy)
    final newPresensi = PresensiModel(
      id: DateTime.now().millisecondsSinceEpoch,
      tanggal: _todayString(),
      statusKehadiran: statusKehadiran,
      jamMasuk: statusKehadiran == 'hadir' ? jamNow : null,
      shiftKerja: statusKehadiran == 'hadir' ? '07:30 - 16:00 WIB' : null,
      fotoSelfie: fotoPath,
      suratFile: suratPath,
      keterangan: keterangan,
      latitude: latitude ?? -7.4778,
      longitude: longitude ?? 110.2177,
      alamatLokasi: alamatLokasi ?? 'Jl. Dr. Sutomo No.1, Magelang',
      dikirimPada: '$jamNow WIB',
      status: 'terkirim',
    );

    _presensiHariIni = newPresensi;
    _successMessage = 'Presensi berhasil dikirim!';
    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Format tanggal hari ini: 'yyyy-MM-dd'
  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Tanggal N hari yang lalu: 'yyyy-MM-dd'
  String _dateString(int daysAgo) {
    final d = DateTime.now().subtract(Duration(days: daysAgo));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Format tanggal untuk display: 'Kamis, 8 Okt 2026'
  static String formatTanggalDisplay(String yyyy_mm_dd) {
    try {
      final parts = yyyy_mm_dd.split('-');
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      const hariPanjang = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      const bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${hariPanjang[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return yyyy_mm_dd;
    }
  }

  /// Format tanggal pendek: 'Kamis, 8 Okt 2026'
  static String formatTanggalPendek(String yyyy_mm_dd) {
    try {
      final parts = yyyy_mm_dd.split('-');
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      const bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return yyyy_mm_dd;
    }
  }
}

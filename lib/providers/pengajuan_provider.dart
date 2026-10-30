import 'package:flutter/material.dart';
import '../models/pengajuan_model.dart';
import '../services/pengajuan_service.dart';

/// PengajuanProvider — State management untuk modul Pengajuan PKL.
///
/// Responsibilities:
/// - Menyimpan daftar pengajuan milik siswa yang sedang login
/// - Mengelola state loading & error
/// - Memanggil PengajuanService untuk CRUD ke API
/// - Notifikasi UI saat data berubah
class PengajuanProvider extends ChangeNotifier {
  final PengajuanService _service = PengajuanService();

  List<PengajuanModel> _pengajuanList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isCancelling = false;
  String? _errorMessage;
  String? _successMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<PengajuanModel> get pengajuanList => List.unmodifiable(_pengajuanList);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isCancelling => _isCancelling;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// True jika sudah ada pengajuan (apapun statusnya)
  bool get hasPengajuan => _pengajuanList.isNotEmpty;

  /// Pengajuan terbaru (untuk ditampilkan di halaman status)
  PengajuanModel? get latestPengajuan =>
      _pengajuanList.isNotEmpty ? _pengajuanList.first : null;

  /// Pengajuan yang masih pending (bisa dibatalkan)
  PengajuanModel? get pendingPengajuan {
    try {
      return _pengajuanList.firstWhere(
        (p) => p.status == 'pending' || p.status == 'menunggu',
      );
    } catch (_) {
      return null;
    }
  }

  /// True jika ada pengajuan yang sudah disetujui
  bool get hasApprovedPengajuan => _pengajuanList.any(
        (p) => p.status == 'disetujui' || p.status == 'approved',
      );

  // ─── Load Pengajuan ──────────────────────────────────────────────────────────

  /// Fetch daftar pengajuan milik siswa yang sedang login dari API.
  Future<void> loadPengajuan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pengajuanList = await _service.getMyPengajuan();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Submit Pengajuan Baru ──────────────────────────────────────────────────

  /// Kirim pengajuan PKL baru ke API.
  /// Return true jika berhasil.
  Future<bool> submitPengajuan(PengajuanModel pengajuan) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _service.createPengajuan(pengajuan);
      // Tambahkan ke list lokal agar UI langsung update
      _pengajuanList.insert(0, result);
      _successMessage = 'Pengajuan berhasil dikirim dan sedang diverifikasi.';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Cancel Pengajuan ────────────────────────────────────────────────────────

  /// Batalkan pengajuan yang masih pending.
  /// Return true jika berhasil.
  Future<bool> cancelPengajuan(int id) async {
    _isCancelling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.cancelPengajuan(id);
      // Hapus dari list lokal
      _pengajuanList.removeWhere((p) => p.id == id);
      _successMessage = 'Pengajuan berhasil dibatalkan.';
      _isCancelling = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isCancelling = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Refresh Single ──────────────────────────────────────────────────────────

  /// Refresh satu pengajuan berdasarkan ID (polling status).
  Future<void> refreshSingle(int id) async {
    try {
      final updated = await _service.getPengajuanById(id);
      final idx = _pengajuanList.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _pengajuanList[idx] = updated;
        notifyListeners();
      }
    } catch (_) {
      // Gagal refresh single — abaikan, tidak update UI
    }
  }

  // ─── Clear Messages ──────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Reset semua state (dipanggil saat user logout)
  void reset() {
    _pengajuanList = [];
    _isLoading = false;
    _isSubmitting = false;
    _isCancelling = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ─── Refresh ─────────────────────────────────────────────────────────────────

  /// Refresh data pengajuan (pull-to-refresh)
  Future<void> refresh() => loadPengajuan();
}

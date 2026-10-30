import 'package:dio/dio.dart';
import '../models/pengajuan_model.dart';
import 'api_client.dart';

/// PengajuanService — Mengelola komunikasi langsung dengan endpoint API Pengajuan PKL.
///
/// Endpoint Laravel yang didukung:
/// GET    /api/pengajuan          → daftar pengajuan milik siswa
/// POST   /api/pengajuan          → buat pengajuan baru
/// GET    /api/pengajuan/{id}     → detail pengajuan
/// DELETE /api/pengajuan/{id}     → batalkan pengajuan (jika masih pending)
class PengajuanService {
  final Dio _dio = ApiClient().dio;

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Parse response menjadi List<PengajuanModel>.
  /// Mendukung pola: { data: [...] }, [ ... ], { data: { data: [...] } }
  List<PengajuanModel> _parseList(dynamic data) {
    List<dynamic> list;

    if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    } else if (data is Map && data['data'] is Map && data['data']['data'] is List) {
      // Laravel pagination: { data: { data: [...], total: N, ... } }
      list = data['data']['data'] as List;
    } else if (data is List) {
      list = data;
    } else {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PengajuanModel.fromJson(e))
        .toList();
  }

  /// Parse response menjadi satu PengajuanModel.
  PengajuanModel _parseSingle(dynamic data) {
    final result = (data is Map && data['data'] != null) ? data['data'] : data;
    return PengajuanModel.fromJson(result as Map<String, dynamic>);
  }

  // ─── CRUD Operations ────────────────────────────────────────────────────────

  /// Ambil daftar pengajuan PKL milik siswa yang sedang login.
  Future<List<PengajuanModel>> getMyPengajuan() async {
    try {
      final response = await _dio.get('/pengajuan');
      return _parseList(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.parseErrorMessage(e));
    }
  }

  /// Kirim pengajuan PKL baru.
  /// Return [PengajuanModel] yang sudah tersimpan di server (dengan ID & status).
  Future<PengajuanModel> createPengajuan(PengajuanModel pengajuan) async {
    try {
      final response = await _dio.post(
        '/pengajuan',
        data: pengajuan.toJson(),
      );
      return _parseSingle(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.parseErrorMessage(e));
    }
  }

  /// Ambil detail pengajuan berdasarkan ID.
  Future<PengajuanModel> getPengajuanById(int id) async {
    try {
      final response = await _dio.get('/pengajuan/$id');
      return _parseSingle(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.parseErrorMessage(e));
    }
  }

  /// Batalkan pengajuan yang masih berstatus 'pending'.
  /// Hanya bisa dilakukan jika belum disetujui/ditolak.
  Future<void> cancelPengajuan(int id) async {
    try {
      await _dio.delete('/pengajuan/$id');
    } on DioException catch (e) {
      throw Exception(ApiClient.parseErrorMessage(e));
    }
  }

  /// Update pengajuan yang masih pending (sebelum disetujui).
  Future<PengajuanModel> updatePengajuan(int id, PengajuanModel pengajuan) async {
    try {
      final response = await _dio.put(
        '/pengajuan/$id',
        data: pengajuan.toJson(),
      );
      return _parseSingle(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.parseErrorMessage(e));
    }
  }
}

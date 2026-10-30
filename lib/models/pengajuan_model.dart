/// PengajuanModel — Representasi data pengajuan PKL.
///
/// Sesuaikan field dengan tabel di BE Laravel.
/// Status pengajuan: 'pending' | 'disetujui' | 'ditolak'
class PengajuanModel {
  final int? id;
  final int? siswaId;
  final String namaPerusahaan;
  final String alamat;
  final String bidangUsaha;
  final String namaKontak;
  final String noTelepon;
  final String? catatan;
  final String status; // 'pending' | 'disetujui' | 'ditolak'
  final String? alasanPenolakan;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? createdAt;
  final String? updatedAt;

  const PengajuanModel({
    this.id,
    this.siswaId,
    required this.namaPerusahaan,
    required this.alamat,
    required this.bidangUsaha,
    required this.namaKontak,
    required this.noTelepon,
    this.catatan,
    this.status = 'pending',
    this.alasanPenolakan,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.createdAt,
    this.updatedAt,
  });

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    return PengajuanModel(
      id: json['id'] as int?,
      siswaId: json['siswa_id'] as int?,
      namaPerusahaan: json['nama_perusahaan'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      bidangUsaha: json['bidang_usaha'] as String? ?? '',
      namaKontak: json['nama_kontak'] as String? ?? '',
      noTelepon: json['no_telepon'] as String? ?? '',
      catatan: json['catatan'] as String?,
      status: json['status'] as String? ?? 'pending',
      alasanPenolakan: json['alasan_penolakan'] as String?,
      tanggalMulai: json['tanggal_mulai'] as String?,
      tanggalSelesai: json['tanggal_selesai'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_perusahaan': namaPerusahaan,
        'alamat': alamat,
        'bidang_usaha': bidangUsaha,
        'nama_kontak': namaKontak,
        'no_telepon': noTelepon,
        if (catatan != null) 'catatan': catatan,
        if (tanggalMulai != null) 'tanggal_mulai': tanggalMulai,
        if (tanggalSelesai != null) 'tanggal_selesai': tanggalSelesai,
      };

  // Status label untuk UI
  String get statusLabel {
    switch (status) {
      case 'disetujui':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }
}

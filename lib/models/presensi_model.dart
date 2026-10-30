/// PresensiModel — Representasi satu record presensi harian siswa PKL.
///
/// Field ini sesuai dengan kebutuhan UI desain dan siap di-map
/// ke response JSON dari endpoint BE Laravel nanti.
class PresensiModel {
  final int? id;
  final String tanggal; // format: 'yyyy-MM-dd'
  final String statusKehadiran; // 'hadir' | 'izin' | 'sakit' | 'libur'
  final String? jamMasuk; // '07:30'
  final String? jamPulang; // '16:00'
  final String? shiftKerja; // '07:30 - 16:00 WIB'
  final String? fotoSelfie; // path file / URL
  final String? suratFile; // path file / URL untuk izin & sakit
  final String? keterangan; // keterangan izin/sakit/libur
  final double? latitude;
  final double? longitude;
  final String? alamatLokasi;
  final String? dikirimPada; // waktu submit, format: 'HH:mm WIB'
  final String status; // 'terkirim' | 'disetujui' | 'ditolak'

  const PresensiModel({
    this.id,
    required this.tanggal,
    required this.statusKehadiran,
    this.jamMasuk,
    this.jamPulang,
    this.shiftKerja,
    this.fotoSelfie,
    this.suratFile,
    this.keterangan,
    this.latitude,
    this.longitude,
    this.alamatLokasi,
    this.dikirimPada,
    this.status = 'terkirim',
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    return PresensiModel(
      id: json['id'] as int?,
      tanggal: json['tanggal'] as String,
      statusKehadiran: json['status_kehadiran'] as String,
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
      shiftKerja: json['shift_kerja'] as String?,
      fotoSelfie: json['foto_selfie'] as String?,
      suratFile: json['surat_file'] as String?,
      keterangan: json['keterangan'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      alamatLokasi: json['alamat_lokasi'] as String?,
      dikirimPada: json['dikirim_pada'] as String?,
      status: json['status'] as String? ?? 'terkirim',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tanggal': tanggal,
        'status_kehadiran': statusKehadiran,
        'jam_masuk': jamMasuk,
        'jam_pulang': jamPulang,
        'shift_kerja': shiftKerja,
        'foto_selfie': fotoSelfie,
        'surat_file': suratFile,
        'keterangan': keterangan,
        'latitude': latitude,
        'longitude': longitude,
        'alamat_lokasi': alamatLokasi,
        'dikirim_pada': dikirimPada,
        'status': status,
      };

  PresensiModel copyWith({
    int? id,
    String? tanggal,
    String? statusKehadiran,
    String? jamMasuk,
    String? jamPulang,
    String? shiftKerja,
    String? fotoSelfie,
    String? suratFile,
    String? keterangan,
    double? latitude,
    double? longitude,
    String? alamatLokasi,
    String? dikirimPada,
    String? status,
  }) {
    return PresensiModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      statusKehadiran: statusKehadiran ?? this.statusKehadiran,
      jamMasuk: jamMasuk ?? this.jamMasuk,
      jamPulang: jamPulang ?? this.jamPulang,
      shiftKerja: shiftKerja ?? this.shiftKerja,
      fotoSelfie: fotoSelfie ?? this.fotoSelfie,
      suratFile: suratFile ?? this.suratFile,
      keterangan: keterangan ?? this.keterangan,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      alamatLokasi: alamatLokasi ?? this.alamatLokasi,
      dikirimPada: dikirimPada ?? this.dikirimPada,
      status: status ?? this.status,
    );
  }
}

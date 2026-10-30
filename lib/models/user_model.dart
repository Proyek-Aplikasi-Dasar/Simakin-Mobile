/// UserModel — Representasi data user yang login.
///
/// Sesuaikan field dengan response JSON dari BE Laravel.
/// Contoh response /api/login:
/// {
///   "status": "success",
///   "message": "Login berhasil",
///   "data": {
///     "user": { "id": 1, "name": "Budi", "email": "budi@smkn1.sch.id", "role": "siswa" },
///     "token": "1|abc123..."
///   }
/// }
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'siswa', 'guru', 'admin'
  final String? nis; // Nomor Induk Siswa (hanya untuk role siswa)
  final String? kelas;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nis,
    this.kelas,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'siswa',
      nis: json['nis'] as String?,
      kelas: json['kelas'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'nis': nis,
        'kelas': kelas,
        'avatar': avatar,
      };
}

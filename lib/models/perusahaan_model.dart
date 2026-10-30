/// PerusahaanModel — Model data untuk direktori Mitra DU/DI Tempat PKL.
class PerusahaanModel {
  final String id;
  final String namaPerusahaan;
  final String namaPendek;
  final String tagKategori;
  final String lokasiSingkat;
  final String alamatLengkap;
  final List<String> programStudi;
  final String bidangUsaha;
  final String nomorTelepon;
  final String email;
  final String pembimbingIndustri;
  final String kuotaPkl;
  final String tentangPerusahaan;
  final String? imageUrl;

  const PerusahaanModel({
    required this.id,
    required this.namaPerusahaan,
    required this.namaPendek,
    required this.tagKategori,
    required this.lokasiSingkat,
    required this.alamatLengkap,
    required this.programStudi,
    required this.bidangUsaha,
    required this.nomorTelepon,
    required this.email,
    required this.pembimbingIndustri,
    required this.kuotaPkl,
    required this.tentangPerusahaan,
    this.imageUrl,
  });

  static const List<PerusahaanModel> dummyList = [
    PerusahaanModel(
      id: 'telkom',
      namaPerusahaan: 'PT Telkom Indonesia (Persero) Tbk',
      namaPendek: 'PT Telkom Indonesia',
      tagKategori: 'BUMN TELEKOMUNIKASI',
      lokasiSingkat: 'Magelang Utara, Kota Magelang',
      alamatLengkap:
          'Jl. Mayjen Bambang Soegeng No.1, Mertoyudan, Kec. Mertoyudan, Magelang, Jawa Tengah 56172',
      programStudi: ['RPL', 'DKV'],
      bidangUsaha: 'Telekomunikasi & TI',
      nomorTelepon: '(0293) 363 100',
      email: 'hrd.magelang@telkom.co.id',
      pembimbingIndustri: 'Bpk. Ahmad Fauzi',
      kuotaPkl: '6 siswa',
      tentangPerusahaan:
          'PT Telkom Witel Magelang berkomitmen mendukung vokasi kejuruan dengan membuka kesempatan praktik industri komprehensif. Peserta PKL akan dibimbing langsung oleh engineer profesional dalam instalasi infrastruktur fiber optik (FTTH), integrasi jaringan korporat, pemeliharaan data center lokal, dan pengelolaan IT solution skala enterprise.',
      imageUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop',
    ),
    PerusahaanModel(
      id: 'magelang_tekno',
      namaPerusahaan: 'PT Magelang Teknologi',
      namaPendek: 'PT Magelang Teknologi',
      tagKategori: 'SOFTWARE HOUSE',
      lokasiSingkat: 'Jl. Ahmad Yani 12, Kota Magelang',
      alamatLengkap:
          'Jl. Ahmad Yani No. 12, Kramat Selatan, Kec. Magelang Utara, Kota Magelang, Jawa Tengah 56115',
      programStudi: ['RPL', 'TKJ'],
      bidangUsaha: 'Software Development & IT Consulting',
      nomorTelepon: '(0293) 312 456',
      email: 'contact@magelangtekno.id',
      pembimbingIndustri: 'Bpk. Rahmat Hidayat',
      kuotaPkl: '4 siswa',
      tentangPerusahaan:
          'PT Magelang Teknologi berfokus pada pengembangan sistem informasi enterprise, aplikasi mobile, cloud computing, dan integrasi API untuk perusahaan modern.',
      imageUrl:
          'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1000&auto=format&fit=crop',
    ),
    PerusahaanModel(
      id: 'kreasi_digital',
      namaPerusahaan: 'CV Kreasi Digital',
      namaPendek: 'CV Kreasi Digital',
      tagKategori: 'CREATIVE AGENCY',
      lokasiSingkat: 'Jl. Pahlawan No. 8, Magelang Tengah',
      alamatLengkap:
          'Jl. Pahlawan No. 8, Potrobangsan, Kec. Magelang Tengah, Kota Magelang, Jawa Tengah 56117',
      programStudi: ['RPL', 'DKV'],
      bidangUsaha: 'Digital Marketing & Multimedia',
      nomorTelepon: '(0293) 321 889',
      email: 'info@kreasidigital.co.id',
      pembimbingIndustri: 'Ibu Maya Kusuma',
      kuotaPkl: '3 siswa',
      tentangPerusahaan:
          'Agensi kreatif yang melayani branding, desain UI/UX interaktif, animasi, dan produksi konten digital visual untuk beragam klien UMKM dan industri.',
      imageUrl:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=1000&auto=format&fit=crop',
    ),
    PerusahaanModel(
      id: 'diskominfo',
      namaPerusahaan: 'Diskominfo Kab. Magelang',
      namaPendek: 'Diskominfo Magelang',
      tagKategori: 'INSTANSI PEMERINTAH',
      lokasiSingkat: 'Komplek Setda Sawitan, Mungkid, Magelang',
      alamatLengkap:
          'Komplek Setda Pemkab Magelang, Jl. Soekarno Hatta No. 1, Kota Mungkid, Magelang, Jawa Tengah 56511',
      programStudi: ['TKJ', 'RPL'],
      bidangUsaha: 'Pemerintahan & Layanan Publik Digital',
      nomorTelepon: '(0293) 788 123',
      email: 'diskominfo@magelangkab.go.id',
      pembimbingIndustri: 'Bpk. Dwi Santoso, S.Kom',
      kuotaPkl: '5 siswa',
      tentangPerusahaan:
          'Pusat pengelolaan teknologi informasi, infrastruktur jaringan fiber optik internal pemerintah daerah, serta pusat koordinasi Smart City dan keamanan siber daerah.',
      imageUrl:
          'https://images.unsplash.com/photo-1577495508048-b635879837f1?q=80&w=1000&auto=format&fit=crop',
    ),
  ];
}

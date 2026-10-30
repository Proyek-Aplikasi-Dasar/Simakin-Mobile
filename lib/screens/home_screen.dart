import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/pengajuan_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pengajuan_provider.dart';
import '../theme/app_theme.dart';
import 'pengajuan_screen.dart';
import 'presensi_screen.dart';

/// HomeScreen — Tab Home dalam MainScreen (tanpa Scaffold).
///
/// Menampilkan dashboard utama PKL:
/// - SimakIn app header
/// - Hero card status PKL (otomatis sinkron dengan PengajuanProvider)
/// - Menu Utama PKL (grid 2x2)
/// - Feed pengumuman (horizontal scroll)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().loadPengajuan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSimakinHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserCard(),
                    const SizedBox(height: 24),
                    _buildMenuUtamaSection(),
                    const SizedBox(height: 24),
                    _buildPengumumanSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SimakIn Header ──────────────────────────────────────────────────────

  Widget _buildSimakinHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          // Logo "S"
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'S',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SimakIn',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                Text(
                  'SMK NEGERI 1 MAGELANG',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary, size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── User Card (Hero) ─────────────────────────────────────────────────────

  Widget _buildUserCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles (background)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: -40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User row
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final user = auth.currentUser;
                          final nama = user?.name ?? 'Siswa';
                          final nis = user?.nis;
                          final kelas = user?.kelas;
                          final subtitle = [
                            if (nis != null) 'NIS: $nis',
                            if (kelas != null) kelas,
                          ].join(' • ');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $nama 👋',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Status content (berbeda per state)
                _buildPklStatusContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPklStatusContent() {
    final pengajuanProvider = context.watch<PengajuanProvider>();
    final list = pengajuanProvider.pengajuanList;

    if (list.isEmpty) {
      return _contentBelumMengajukan();
    }

    final p = list.first;
    final isDisetujui = p.status == 'disetujui' || p.status == 'approved';
    final isDitolak = p.status == 'ditolak' || p.status == 'rejected';

    if (isDisetujui) {
      return _contentDiterima(p);
    } else if (isDitolak) {
      return _contentDitolak(p);
    } else {
      return _contentMenunggu(p);
    }
  }

  // State 1: Belum Mengajukan
  Widget _contentBelumMengajukan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kamu Belum Mengajukan Tempat PKL',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StatusPengajuanScreen(initialTabIndex: 0),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded,
                size: 16, color: Colors.white),
            label: Text(
              'Ajukan Tempat PKL',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  // State 2: Menunggu Verifikasi
  Widget _contentMenunggu(PengajuanModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Status Pengajuan PKL',
              style:
                  GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⏳ Menunggu',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          p.namaPerusahaan,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          p.bidangUsaha.isNotEmpty
              ? p.bidangUsaha
              : 'Menunggu verifikasi Koordinator PKL',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatusPengajuanScreen(initialTabIndex: 1)),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(
              'Cek Progres Pengajuan',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // State 3: Sudah Diterima di Perusahaan
  Widget _contentDiterima(PengajuanModel p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.namaPerusahaan,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      p.bidangUsaha.isNotEmpty
                          ? p.bidangUsaha
                          : 'Tempat PKL Resmi Diterima',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(0.18), height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_pin_rounded,
                  color: Colors.white60, size: 16),
              const SizedBox(width: 6),
              Text(
                p.namaKontak.isNotEmpty
                    ? p.namaKontak
                    : 'Pembimbing DU/DI Terkait',
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // State 4: Pengajuan Ditolak
  Widget _contentDitolak(PengajuanModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Status Pengajuan PKL',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '✕ Belum Diterima',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          p.namaPerusahaan,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          p.alasanPenolakan ?? 'Silakan ajukan permohonan ke tempat PKL lain',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatusPengajuanScreen(initialTabIndex: 0)),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Pilih Tempat PKL Lain',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Menu Utama PKL (2x2 Grid) ────────────────────────────────────────────

  Widget _buildMenuUtamaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Utama PKL',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildMenuCard(
              icon: Icons.how_to_reg_rounded,
              label: 'Presensi\nHarian',
              iconBg: AppColors.menuBlue,
              iconColor: AppColors.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PresensiScreen(),
                ),
              ),
            ),
            _buildMenuCard(
              icon: Icons.edit_note_rounded,
              label: 'Jurnal\nHarian',
              iconBg: AppColors.menuYellow,
              iconColor: AppColors.warning,
              onTap: () {},
            ),
            _buildMenuCard(
              icon: Icons.workspace_premium_rounded,
              label: 'Penilaian\nBulanan',
              iconBg: AppColors.menuGreen,
              iconColor: AppColors.success,
              onTap: () {},
            ),
            _buildMenuCard(
              icon: Icons.history_rounded,
              label: 'Riwayat\nAktivitas',
              iconBg: AppColors.menuGray,
              iconColor: AppColors.textSecondary,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Pengumuman / Feed (Horizontal Scroll) ────────────────────────────────

  Widget _buildPengumumanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pengumuman',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat semua →',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 216,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAnnouncementCard(
                tag: '⚠ Penting',
                tagColor: AppColors.error,
                time: 'Hari ini, 08:30 WIB',
                title: 'Batas Pengunggahan Berkas Monitoring 1 Guru Pembimbing',
                imageGradient: const [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                bgIcon: Icons.assignment_turned_in_rounded,
              ),
              const SizedBox(width: 12),
              _buildAnnouncementCard(
                tag: '📅 Agenda',
                tagColor: AppColors.info,
                time: 'Kemarin, 08:30 WIB',
                title: 'Webinar Sesi Industri Fresh Graduate',
                imageGradient: const [Color(0xFF047857), Color(0xFF34D399)],
                bgIcon: Icons.ondemand_video_rounded,
              ),
              const SizedBox(width: 12),
              _buildAnnouncementCard(
                tag: '📌 Info',
                tagColor: const Color(0xFF8B5CF6),
                time: '2 hari lalu',
                title: 'Jadwal Monitoring Dosen Pembimbing Bulan November',
                imageGradient: const [Color(0xFF92400E), Color(0xFFF59E0B)],
                bgIcon: Icons.people_alt_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard({
    required String tag,
    required Color tagColor,
    required String time,
    required String title,
    required List<Color> imageGradient,
    required IconData bgIcon,
  }) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Thumbnail area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 104,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: imageGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Background icon (dekoratif)
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      bgIcon,
                      size: 80,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  Center(
                    child: Icon(
                      bgIcon,
                      size: 42,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                  // Tag badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Baca selengkapnya →',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
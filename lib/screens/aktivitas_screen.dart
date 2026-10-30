import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'presensi_screen.dart';

/// AktivitasScreen — Tab Aktivitas dalam MainScreen.
///
/// Menampilkan aktivitas PKL hari ini:
/// - Presensi Harian
/// - Jurnal Kegiatan
/// - Akses cepat riwayat
class AktivitasScreen extends StatelessWidget {
  /// Callback saat user ingin berpindah tab dari dalam AktivitasScreen.
  /// Contoh: tap "Riwayat Presensi" → pindah ke tab Riwayat (index 2).
  final void Function(int tabIndex)? onNavigateTab;

  const AktivitasScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Senin, 18 Nov 2024',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aktivitas Hari Ini',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Yuk catat kehadiran dan laporan kegiatan PKL-mu tepat waktu!',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Presensi Harian Card
                  _buildActivityCard(
                    context: context,
                    icon: Icons.access_time_filled_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.menuBlue,
                    title: 'Presensi Harian',
                    desc:
                        'Catat kehadiran masuk & pulang PKL dengan verifikasi radius GPS dan kamera selfie secara akurat.',
                    buttonLabel: 'Isi Presensi Sekarang →',
                    buttonColor: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PresensiScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Jurnal Kegiatan Card
                  _buildActivityCard(
                    context: context,
                    icon: Icons.edit_note_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: AppColors.menuYellow,
                    title: 'Jurnal Kegiatan',
                    desc:
                        'Laporkan rincian pekerjaan dan tugas kejuruan kegiatan PKL industri.',
                    buttonLabel: 'Tulis Jurnal Hari Ini →',
                    buttonColor: const Color(0xFFF59E0B),
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),

                  // Akses Cepat Riwayat
                  Text(
                    'Akses Cepat Riwayat',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickCard(
                          context: context,
                          icon: Icons.how_to_reg_rounded,
                          iconColor: AppColors.primary,
                          iconBg: AppColors.menuBlue,
                          title: 'Riwayat Presensi',
                          subtitle: 'Daftar presensi',
                          onTap: () => onNavigateTab?.call(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickCard(
                          context: context,
                          icon: Icons.menu_book_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          iconBg: AppColors.menuYellow,
                          title: 'Riwayat Jurnal',
                          subtitle: 'Semua logbook PKL',
                          onTap: () => onNavigateTab?.call(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SimakIn',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              Text('SMK NEGERI 1 MAGELANG',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String desc,
    required String buttonLabel,
    required Color buttonColor,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonColor, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              child: Text(
                buttonLabel,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

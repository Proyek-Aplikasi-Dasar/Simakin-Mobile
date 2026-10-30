import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/pengajuan_provider.dart';
import '../theme/app_theme.dart';

/// ProfilScreen — Tab Profil dalam MainScreen.
///
/// Menampilkan data profil siswa dan opsi pengaturan,
/// termasuk tombol logout.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Text(
                  'Profil',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: AppColors.textSecondary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A56DB), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5), width: 2),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 12),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final user = auth.currentUser;
                            return Column(
                              children: [
                                Text(
                                  user?.name ?? 'Siswa',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                if (user?.nis != null)
                                  Text(
                                    'NIS: ${user!.nis}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                if (user?.kelas != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      user!.kelas!,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu items
                  _buildSection('Data Saya', [
                    _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Data Diri',
                        subtitle: 'Informasi pribadi',
                        onTap: () {}),
                    _buildMenuItem(
                        icon: Icons.school_outlined,
                        label: 'Data Akademik',
                        subtitle: 'Kelas & kompetensi keahlian',
                        onTap: () {}),
                    _buildMenuItem(
                        icon: Icons.family_restroom_rounded,
                        label: 'Data Orang Tua',
                        subtitle: 'Informasi wali',
                        onTap: () {}),
                  ]),
                  const SizedBox(height: 16),

                  _buildSection('Pengaturan', [
                    _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifikasi',
                        subtitle: 'Kelola notifikasi',
                        onTap: () {}),
                    _buildMenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Keamanan',
                        subtitle: 'Ubah password',
                        onTap: () {}),
                    _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Bantuan & FAQ',
                        subtitle: 'Pusat bantuan',
                        onTap: () {}),
                  ]),
                  const SizedBox(height: 20),

                  // Logout button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                // Reset data pengajuan agar tidak bocor ke sesi berikutnya
                                context.read<PengajuanProvider>().reset();
                                auth.logout();
                              },
                        icon: auth.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              )
                            : const Icon(Icons.logout_rounded,
                                color: AppColors.error, size: 20),
                        label: Text(
                          auth.isLoading ? 'Keluar...' : 'Keluar dari Akun',
                          style: GoogleFonts.poppins(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SimakIn v1.0.0 — SMK Negeri 1 Magelang',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }
}

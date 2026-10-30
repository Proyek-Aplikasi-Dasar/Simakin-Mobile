import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// ChatScreen — Tab Chat dalam MainScreen.
///
/// Fitur chat dengan koordinator PKL.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
                  'Chat',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 22),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChatItem(
                  name: 'Koordinator PKL',
                  subtitle: 'Hendra Gunawan, S.T.',
                  lastMsg: 'Silakan lengkapi berkas monitoring minggu ini.',
                  time: '10:30',
                  unread: 2,
                  avatarColor: AppColors.primary,
                  avatarIcon: Icons.school_rounded,
                ),
                _buildChatItem(
                  name: 'Guru Pembimbing',
                  subtitle: 'Ibu Sari, S.Kom',
                  lastMsg: 'Jurnal kamu sudah disetujui, lanjutkan! 👍',
                  time: 'Kemarin',
                  unread: 0,
                  avatarColor: const Color(0xFF22C55E),
                  avatarIcon: Icons.person_rounded,
                ),
                _buildChatItem(
                  name: 'Admin PKL',
                  subtitle: 'SMKN 1 Magelang',
                  lastMsg: 'Pengumuman: Batas pengunggahan berkas...',
                  time: '2 hari',
                  unread: 1,
                  avatarColor: const Color(0xFFF59E0B),
                  avatarIcon: Icons.admin_panel_settings_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required String name,
    required String subtitle,
    required String lastMsg,
    required String time,
    required int unread,
    required Color avatarColor,
    required IconData avatarIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(avatarIcon, color: avatarColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 4),
                Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 6),
              if (unread > 0)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$unread',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

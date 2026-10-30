import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'aktivitas_screen.dart';
import 'riwayat_screen.dart';
import 'chat_screen.dart';
import 'profil_screen.dart';

/// MainScreen — Shell utama aplikasi SimakIn.
///
/// Mengandung BottomNavigationBar dengan 5 tab:
/// Home, Aktivitas, Riwayat, Chat, Profil.
/// IndexedStack digunakan agar state setiap tab terjaga.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Screens dibuat via method agar bisa meneruskan callback navigasi tab
  List<Widget> get _screens => [
        const HomeScreen(),
        AktivitasScreen(onNavigateTab: (i) => setState(() => _currentIndex = i)),
        const RiwayatScreen(),
        const ChatScreen(),
        const ProfilScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.event_note_outlined, Icons.event_note_rounded, 'Aktivitas'),
              _buildNavItem(2, Icons.history_rounded, Icons.history_rounded, 'Riwayat'),
              _buildNavItem(3, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
              _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

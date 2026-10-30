import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/presensi_provider.dart';
import '../models/presensi_model.dart';
import '../theme/app_theme.dart';

/// RiwayatScreen — Tab Riwayat dalam MainScreen.
///
/// Menampilkan riwayat presensi dan jurnal PKL siswa
/// dengan dua tab: Presensi dan Jurnal.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPresensiTab(),
                _buildJurnalTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          _buildTabButton('Presensi', 0, Icons.how_to_reg_rounded),
          const SizedBox(width: 8),
          _buildTabButton('Jurnal', 1, Icons.menu_book_rounded),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => setState(() => _tabController.animateTo(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresensiTab() {
    return Consumer<PresensiProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final allItems = [
          if (provider.presensiHariIni != null) provider.presensiHariIni!,
          ...provider.riwayatPresensi,
        ];
        if (allItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded,
                    size: 56, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('Belum ada riwayat presensi',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return Column(
          children: [
            // Filter bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  Text(
                    '🔍 Filter Riwayat',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Reset Filter',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: allItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildPresensiCardFromModel(allItems[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresensiCardFromModel(PresensiModel item) {
    Color statusColor;
    String statusLabel;

    switch (item.statusKehadiran) {
      case 'hadir':
        statusColor = AppColors.success;
        statusLabel = '● Hadir';
        break;
      case 'izin':
        statusColor = AppColors.info;
        statusLabel = '📋 Izin';
        break;
      case 'sakit':
        statusColor = AppColors.error;
        statusLabel = '🤒 Sakit';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusLabel = '🏖 Libur';
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PresensiProvider.formatTanggalDisplay(item.tanggal),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary),
                ),
                if (item.shiftKerja != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        item.shiftKerja!,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
                if (item.dikirimPada != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.upload_rounded,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        'Dikirim: ${item.dikirimPada}',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Detail >',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJurnalTab() {
    final items = [
      _JurnalItem('Senin, 18 Nov 2024', 'Implementasi REST API & Validasi Token JWT', '16:15 WIB', 'disetujui'),
      _JurnalItem('Jumat, 15 Nov 2024', 'Slicing UI Dashboard Web & Refactoring Komponen', '16:30 WIB', 'menunggu'),
      _JurnalItem('Kamis, 14 Nov 2024', 'Perbaikan Bug Routing State & Testing End-to-End', '16:05 WIB', 'disetujui'),
      _JurnalItem('Rabu, 13 Nov 2024', 'Setup Database PostgreSQL & Query Optimization', '16:30 WIB', 'disetujui'),
      _JurnalItem('Selasa, 12 Nov 2024', 'Pengenalan Arsitektur Cloud & Onboarding Tim', '16:00 WIB', 'disetujui'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildJurnalCard(items[i]),
    );
  }

  Widget _buildJurnalCard(_JurnalItem item) {
    final isDisetujui = item.status == 'disetujui';
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.date,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDisetujui
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isDisetujui ? '✓ Disetujui' : '⏳ Menunggu',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDisetujui ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                'Dikirim: ${item.sentAt}',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
              const Spacer(),
              Text(
                'Detail >',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JurnalItem {
  final String date;
  final String title;
  final String sentAt;
  final String status;
  const _JurnalItem(this.date, this.title, this.sentAt, this.status);
}

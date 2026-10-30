import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/presensi_provider.dart';
import '../models/presensi_model.dart';
import '../theme/app_theme.dart';

/// PresensiScreen — Screen utama Presensi Harian PKL.
///
/// Menampilkan:
/// - Header info presensi hari ini (tanggal + shift kerja)
/// - Pilihan status kehadiran: Hadir / Izin / Sakit / Libur
/// - Form dinamis sesuai status yang dipilih:
///   • Hadir  → area foto selfie (simulasi dummy)
///   • Izin   → upload surat izin PKL
///   • Sakit  → upload surat dokter + keluhan
///   • Libur  → keterangan opsional
/// - Tombol submit presensi
///
/// Data dummy dikelola di [PresensiProvider].
/// Swap ke API: ganti bagian provider.submitPresensi() agar
/// memanggil service nyata tanpa mengubah UI ini.
class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  // ─── Form State ─────────────────────────────────────────────────────────────
  String _selectedStatus = 'hadir'; // default
  bool _hasFoto = false; // simulasi foto selfie sudah diambil
  bool _hasSuratFile = false; // simulasi file sudah diupload
  String? _suratFileName;
  final TextEditingController _keteranganController = TextEditingController();

  // Dummy koordinat GPS (nanti diganti geolocator)
  final double _dummyLat = -7.4778;
  final double _dummyLng = 110.2177;
  final String _dummyAlamat = 'Jl. Dr. Sutomo No.1, Magelang';

  // Validasi
  bool _showValidationError = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String get _todayFormatted {
    final now = DateTime.now();
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return '${hari[now.weekday - 1]}, ${now.day} ${bulan[now.month - 1]} ${now.year}';
  }

  bool get _isFormValid {
    if (_selectedStatus == 'hadir') return _hasFoto;
    if (_selectedStatus == 'izin') return _hasSuratFile;
    if (_selectedStatus == 'sakit') {
      return _hasSuratFile && _keteranganController.text.trim().isNotEmpty;
    }
    // libur tidak ada validasi wajib
    return true;
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  void _simulateAmbilFoto() {
    setState(() => _hasFoto = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Foto selfie berhasil diambil ✓',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _simulateUploadFile(String tipe) {
    // Simulasi pilih file — nanti diganti file_picker atau image_picker
    setState(() {
      _hasSuratFile = true;
      _suratFileName = tipe == 'izin'
          ? 'surat_izin_pkl_${DateTime.now().day}${DateTime.now().month}.pdf'
          : 'surat_sakit_dokter_${DateTime.now().day}${DateTime.now().month}.pdf';
    });
  }

  Future<void> _submit() async {
    if (!_isFormValid) {
      setState(() => _showValidationError = true);
      return;
    }
    setState(() => _showValidationError = false);

    final provider = context.read<PresensiProvider>();
    final success = await provider.submitPresensi(
      statusKehadiran: _selectedStatus,
      fotoPath: _hasFoto ? 'dummy_selfie_path.jpg' : null,
      suratPath: _hasSuratFile ? _suratFileName : null,
      keterangan: _keteranganController.text.trim().isEmpty
          ? null
          : _keteranganController.text.trim(),
      latitude: _dummyLat,
      longitude: _dummyLng,
      alamatLokasi: _dummyAlamat,
    );

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Presensi Terkirim!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presensi harian kamu hari ini berhasil dicatat. Tetap semangat PKL-nya! 💪',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    'Oke, Tutup',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<PresensiProvider>(
      builder: (context, provider, _) {
        // Jika sudah presensi hari ini, tampilkan halaman konfirmasi
        if (provider.sudahPresensiHariIni) {
          return _buildSudahPresensiView(provider.presensiHariIni!);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(provider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Presensi Harian',
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildForm(PresensiProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Info Card Presensi Hari Ini
          _buildInfoCard(),
          const SizedBox(height: 16),

          // 2. Status Kehadiran
          _buildStatusKehadiranSection(),
          const SizedBox(height: 16),

          // 3. Konten dinamis sesuai status
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _buildDynamicContent(),
          ),
          const SizedBox(height: 24),

          // 4. Tombol Submit
          _buildSubmitButton(provider),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Info Card Presensi Hari Ini ───────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.menuBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_note_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Presensi Hari Ini',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Dibuka 07:20 — 11:00 WIB sekat sehari',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          // Tanggal & Shift
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tanggal',
                  value: _todayFormatted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.access_time_rounded,
                  label: 'Shift Kerja 🔒',
                  value: '07:30 – 16:00 WIB',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Kehadiran ──────────────────────────────────────────────────────

  Widget _buildStatusKehadiranSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Status Kehadiran ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: '*Wajib',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Pilih status harian',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip('hadir', Icons.check_circle_rounded, 'Hadir'),
              const SizedBox(width: 8),
              _buildStatusChip('izin', Icons.assignment_rounded, 'Izin'),
              const SizedBox(width: 8),
              _buildStatusChip('sakit', Icons.medical_services_rounded, 'Sakit'),
              const SizedBox(width: 8),
              _buildStatusChip('libur', Icons.beach_access_rounded, 'Libur'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String value, IconData icon, String label) {
    final isSelected = _selectedStatus == value;
    Color chipColor;
    Color iconColor;
    switch (value) {
      case 'hadir':
        chipColor = AppColors.primary;
        iconColor = AppColors.primary;
        break;
      case 'izin':
        chipColor = AppColors.info;
        iconColor = AppColors.info;
        break;
      case 'sakit':
        chipColor = AppColors.error;
        iconColor = AppColors.error;
        break;
      default:
        chipColor = AppColors.textSecondary;
        iconColor = AppColors.textSecondary;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = value;
            _showValidationError = false;
            // Reset form saat ganti status
            _hasFoto = false;
            _hasSuratFile = false;
            _suratFileName = null;
            _keteranganController.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? chipColor : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : iconColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dynamic Content ───────────────────────────────────────────────────────

  Widget _buildDynamicContent() {
    switch (_selectedStatus) {
      case 'hadir':
        return _buildHadirContent();
      case 'izin':
        return _buildIzinContent();
      case 'sakit':
        return _buildSakitContent();
      case 'libur':
        return _buildLiburContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Hadir: Foto Selfie ────────────────────────────────────────────────────

  Widget _buildHadirContent() {
    return _buildCard(
      key: const ValueKey('hadir'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Bukti Foto Selfie Kehadiran',
            isWajib: false,
            subtitle: 'Ambil foto langsung di lokasi / di tempat PKL.',
          ),
          const SizedBox(height: 14),
          // Area foto
          GestureDetector(
            onTap: _simulateAmbilFoto,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _hasFoto
                    ? AppColors.successLight
                    : const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(14),
                border: _showValidationError && !_hasFoto
                    ? Border.all(color: AppColors.error, width: 2)
                    : Border.all(color: Colors.transparent),
              ),
              child: _hasFoto
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 48),
                        const SizedBox(height: 10),
                        Text(
                          'Foto selfie berhasil diambil!',
                          style: GoogleFonts.poppins(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ketuk untuk mengambil ulang',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white70, size: 30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ketuk untuk Ambil Selfie',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pastikan wajah terlihat jelas & cahaya cukup',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (_showValidationError && !_hasFoto) ...[
            const SizedBox(height: 6),
            _buildValidationText('Foto selfie wajib diambil'),
          ],
          const SizedBox(height: 14),
          // Info koordinat GPS
          _buildGpsInfo(),
        ],
      ),
    );
  }

  // ── Izin: Upload Surat ────────────────────────────────────────────────────

  Widget _buildIzinContent() {
    return _buildCard(
      key: const ValueKey('izin'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Surat Keterangan / Izin PKL',
            isWajib: true,
            subtitle:
                'Unggah bukti surat izin resmi atau surat dari orang tua/pihak terkait.',
          ),
          const SizedBox(height: 14),
          _buildFileUploadArea(
            isError: _showValidationError && !_hasSuratFile,
            onTap: () => _simulateUploadFile('izin'),
          ),
          const SizedBox(height: 14),
          _buildKeteranganField(
            label: 'Keterangan / Alasan Izin',
            isWajib: true,
            hint: 'Tuliskan alasan izin dengan jelas, contoh: menghadiri...',
            maxLength: 255,
            isError: _showValidationError &&
                _keteranganController.text.trim().isEmpty,
          ),
        ],
      ),
    );
  }

  // ── Sakit: Upload Surat Dokter + Keluhan ──────────────────────────────────

  Widget _buildSakitContent() {
    return _buildCard(
      key: const ValueKey('sakit'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Surat Keterangan Sakit',
            isWajib: true,
            subtitle: 'Unggah surat keterangan dokter / puskesmas / rumah sakit.',
          ),
          const SizedBox(height: 14),
          _buildFileUploadArea(
            isError: _showValidationError && !_hasSuratFile,
            onTap: () => _simulateUploadFile('sakit'),
          ),
          const SizedBox(height: 14),
          _buildKeteranganField(
            label: 'Keluhan Sakit / Diagnosis',
            isWajib: true,
            hint: 'Tuliskan keluhan, contoh: demam dan batuk, ...',
            maxLength: 255,
            isError: _showValidationError &&
                _keteranganController.text.trim().isEmpty,
          ),
        ],
      ),
    );
  }

  // ── Libur: Keterangan Opsional ────────────────────────────────────────────

  Widget _buildLiburContent() {
    return _buildCard(
      key: const ValueKey('libur'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.menuGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.beach_access_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Libur',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Itu santai, format ini minta mitra untuk kamu!',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tanpa foto & dokumen. Presensi cukup dikirim tanpa swafoto atau berkas.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildKeteranganField(
            label: 'Keterangan Libur (opsional)',
            isWajib: false,
            hint:
                'Contoh: libur karena jadwal pelatihan di pembimbing / industri...',
            maxLength: 255,
            isError: false,
          ),
        ],
      ),
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton(PresensiProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isSubmitting ? null : _submit,
        icon: provider.isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(
          provider.isSubmitting ? 'Mengirim...' : 'Presensi Sekarang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Sudah Presensi View ───────────────────────────────────────────────────

  Widget _buildSudahPresensiView(PresensiModel presensi) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Success banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF16a34a), Color(0xFF22c55e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Presensi Hari Ini Terkirim',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Dikirim pukul ${presensi.dikirimPada ?? '-'}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Detail presensi
            _buildCard(
              key: const ValueKey('detail'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Presensi',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow('Tanggal',
                      PresensiProvider.formatTanggalDisplay(presensi.tanggal)),
                  _buildDetailRow(
                      'Status', _statusLabel(presensi.statusKehadiran)),
                  if (presensi.shiftKerja != null)
                    _buildDetailRow('Shift Kerja', presensi.shiftKerja!),
                  if (presensi.jamMasuk != null)
                    _buildDetailRow(
                        'Jam Masuk', '${presensi.jamMasuk} WIB'),
                  if (presensi.alamatLokasi != null)
                    _buildDetailRow('Lokasi', presensi.alamatLokasi!),
                  if (presensi.latitude != null)
                    _buildDetailRow('Koordinat',
                        '${presensi.latitude!.toStringAsFixed(4)}, ${presensi.longitude!.toStringAsFixed(4)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'hadir':
        return '● Hadir';
      case 'izin':
        return '📋 Izin';
      case 'sakit':
        return '🤒 Sakit';
      default:
        return '🏖 Libur';
    }
  }

  // ── Reusable Widgets ──────────────────────────────────────────────────────

  Widget _buildCard({required Widget child, required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildSectionTitle(
    String title, {
    required bool isWajib,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isWajib)
                TextSpan(
                  text: ' *',
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileUploadArea({
    required bool isError,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isError
                  ? AppColors.errorLight
                  : _hasSuratFile
                      ? AppColors.successLight
                      : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isError
                    ? AppColors.error
                    : _hasSuratFile
                        ? AppColors.success
                        : AppColors.border,
                width: isError ? 1.5 : 1,
                style: _hasSuratFile
                    ? BorderStyle.solid
                    : BorderStyle.solid,
              ),
            ),
            child: _hasSuratFile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        _suratFileName ?? 'File terunggah',
                        style: GoogleFonts.poppins(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berkas Tersimpan',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 36,
                        color: isError
                            ? AppColors.error
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unggah File',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isError
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PDF, JPG, PNG • Maks. 5MB',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_hasSuratFile) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Berkas Tersimpan',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  '↑ Upload Ulang',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (isError) ...[
          const SizedBox(height: 6),
          _buildValidationText('File surat wajib diunggah'),
        ],
      ],
    );
  }

  Widget _buildKeteranganField({
    required String label,
    required bool isWajib,
    required String hint,
    required int maxLength,
    required bool isError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isWajib)
                TextSpan(
                  text: ' *Wajib',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _keteranganController,
          maxLines: 3,
          maxLength: maxLength,
          onChanged: (_) {
            if (_showValidationError) setState(() {});
          },
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: isError ? AppColors.errorLight : AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isError ? AppColors.error : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isError ? AppColors.error : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(14),
            counterStyle: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        if (isError) ...[
          _buildValidationText(
              isWajib ? 'Keterangan wajib diisi' : ''),
        ],
      ],
    );
  }

  Widget _buildGpsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dummyAlamat,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_dummyLat.toStringAsFixed(4)}, ${_dummyLng.toStringAsFixed(4)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '✓ GPS',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationText(String msg) {
    if (msg.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.error),
          const SizedBox(width: 4),
          Text(
            msg,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

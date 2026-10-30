import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/pengajuan_model.dart';
import '../models/perusahaan_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pengajuan_provider.dart';
import 'detail_perusahaan_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PengajuanScreen (Form Pengajuan Lokasi PKL Baru)
// ═══════════════════════════════════════════════════════════════════════════════

/// PengajuanScreen — Form pengajuan lokasi PKL.
///
/// Menggunakan [PengajuanProvider] untuk state management dan
/// [AuthProvider] untuk mengambil data siswa yang sedang login.
class PengajuanScreen extends StatefulWidget {
  final String? initialPerusahaan;
  final String? initialAlamat;
  final String? initialBidangUsaha;
  final String? initialKontak;
  final String? initialTelepon;

  const PengajuanScreen({
    super.key,
    this.initialPerusahaan,
    this.initialAlamat,
    this.initialBidangUsaha,
    this.initialKontak,
    this.initialTelepon,
  });

  @override
  State<PengajuanScreen> createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaPerusahaanCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _bidangUsahaCtrl;
  late final TextEditingController _namaKontakCtrl;
  late final TextEditingController _noTeleponCtrl;
  final _catatanCtrl = TextEditingController();

  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _namaPerusahaanCtrl = TextEditingController(text: widget.initialPerusahaan ?? '');
    _alamatCtrl = TextEditingController(text: widget.initialAlamat ?? '');
    _bidangUsahaCtrl = TextEditingController(text: widget.initialBidangUsaha ?? '');
    _namaKontakCtrl = TextEditingController(text: widget.initialKontak ?? '');
    _noTeleponCtrl = TextEditingController(text: widget.initialTelepon ?? '');
  }

  @override
  void dispose() {
    _namaPerusahaanCtrl.dispose();
    _alamatCtrl.dispose();
    _bidangUsahaCtrl.dispose();
    _namaKontakCtrl.dispose();
    _noTeleponCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final pengajuan = PengajuanModel(
      namaPerusahaan: _namaPerusahaanCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      bidangUsaha: _bidangUsahaCtrl.text.trim(),
      namaKontak: _namaKontakCtrl.text.trim(),
      noTelepon: _noTeleponCtrl.text.trim(),
      catatan: _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
    );

    final success = await context
        .read<PengajuanProvider>()
        .submitPengajuan(pengajuan);

    if (success && mounted) {
      setState(() => _isSubmitted = true);
    } else if (mounted) {
      final err = context.read<PengajuanProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Terjadi kesalahan. Coba lagi.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) return _buildSuccessView();

    final isSubmitting = context.watch<PengajuanProvider>().isSubmitting;
    final userName = context.watch<AuthProvider>().currentUser?.name ?? 'Siswa';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Ajukan Tempat PKL',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(userName),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Data Perusahaan / Instansi'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    id: 'pengajuan_nama_perusahaan',
                    controller: _namaPerusahaanCtrl,
                    label: 'Nama Perusahaan / Instansi',
                    hint: 'PT Telkom Indonesia (Persero) Tbk',
                    icon: Icons.apartment_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    id: 'pengajuan_alamat',
                    controller: _alamatCtrl,
                    label: 'Alamat Lengkap',
                    hint: 'Jl. Mayjen Bambang Soegeng No.1, Magelang',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    required: true,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    id: 'pengajuan_bidang_usaha',
                    controller: _bidangUsahaCtrl,
                    label: 'Bidang Usaha / Divisi',
                    hint: 'Telekomunikasi & TI, Software, dll.',
                    icon: Icons.work_outline_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Kontak Penanggung Jawab'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    id: 'pengajuan_nama_kontak',
                    controller: _namaKontakCtrl,
                    label: 'Nama PIC / Pembimbing',
                    hint: 'Bpk. Ahmad Fauzi',
                    icon: Icons.person_outline_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    id: 'pengajuan_no_telepon',
                    controller: _noTeleponCtrl,
                    label: 'No. Telepon / WhatsApp',
                    hint: '(0293) 363 100 / 0812-xxxx-xxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    required: true,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Catatan Tambahan (Opsional)'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    id: 'pengajuan_catatan',
                    controller: _catatanCtrl,
                    label: 'Catatan',
                    hint: 'Alasan memilih divisi tertentu atau preferensi jadwal...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                    required: false,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      key: const Key('pengajuan_submit_button'),
                      onPressed: isSubmitting ? null : _handleSubmit,
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                        isSubmitting ? 'Mengirim...' : 'Kirim Pengajuan PKL',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(String userName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $userName!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pastikan data tempat PKL telah sesuai sebelum dikirim untuk proses verifikasi.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildTextField({
    required String id,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final bool isMultiline = maxLines > 1;

    return TextFormField(
      key: Key(id),
      controller: controller,
      maxLines: maxLines,
      keyboardType: isMultiline ? TextInputType.multiline : (keyboardType ?? TextInputType.text),
      style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 12.5),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF16A34A)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pengajuan Terkirim!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pengajuan tempat PKL kamu sudah diterima sistem dan akan segera diverifikasi oleh Koordinator PKL.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const StatusPengajuanScreen(initialTabIndex: 1)),
                      );
                    },
                    icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                    label: Text(
                      'Lihat Status Pengajuan',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// StatusPengajuanScreen (Tab Daftar Perusahaan & Tab Status Pengajuan)
// ═══════════════════════════════════════════════════════════════════════════════

/// StatusPengajuanScreen — Halaman utama pengajuan PKL dengan 2 tab:
/// 1. Daftar Perusahaan (Daftar Tempat)
/// 2. Status Pengajuan (3 Kondisi: Menunggu, Diterima, Tidak Diterima)
class StatusPengajuanScreen extends StatefulWidget {
  final int initialTabIndex;
  const StatusPengajuanScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<StatusPengajuanScreen> createState() => _StatusPengajuanScreenState();
}

class _StatusPengajuanScreenState extends State<StatusPengajuanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & filter state
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedJurusan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    // Load pengajuan melalui provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().loadPengajuan();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<PengajuanProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isDaftarTempat = _tabController.index == 0;
    final appBarTitle = isDaftarTempat ? 'Daftar Perusahaan' : 'Status Pengajuan';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Column(
        children: [
          // ─── Segmented Switcher Header ─────────────────────────────────────
          _buildSegmentedTabBar(),

          // ─── Tab Content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDaftarPerusahaanTab(),
                _buildStatusPengajuanTabWrapper(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Segmented Tab Switcher (Capsule Pill Design) ───────────────────────────
  Widget _buildSegmentedTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(child: _buildSegmentItem('Daftar Tempat', 0, Icons.apartment_rounded)),
            const SizedBox(width: 4),
            Expanded(child: _buildSegmentItem('Status Pengajuan', 1, Icons.assignment_turned_in_rounded)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem(String label, int index, IconData icon) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => setState(() => _tabController.animateTo(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: DAFTAR PERUSAHAAN
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDaftarPerusahaanTab() {
    final filteredList = PerusahaanModel.dummyList.where((item) {
      final matchesQuery = _searchQuery.isEmpty ||
          item.namaPerusahaan.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.lokasiSingkat.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.bidangUsaha.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesJurusan = _selectedJurusan == null ||
          item.programStudi.contains(_selectedJurusan);
      return matchesQuery && matchesJurusan;
    }).toList();

    return Column(
      children: [
        // ─── Search and Filter Bar ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari tempat PKL / nama mitra...',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12.5,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedJurusan != null
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: _selectedJurusan != null
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                    size: 20,
                  ),
                  onPressed: _showFilterDialog,
                ),
              ),
            ],
          ),
        ),

        // ─── List of Company Cards ───────────────────────────────────────────
        Expanded(
          child: filteredList.isEmpty
              ? Center(
                  child: Text(
                    'Perusahaan tidak ditemukan',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return _buildCompanyCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(PerusahaanModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailPerusahaanScreen(perusahaan: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaPerusahaan,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.lokasiSingkat,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.school_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Program Studi: ${item.programStudi.join(', ')}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Detail',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Program Keahlian',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Semua', 'RPL', 'TKJ', 'DKV'].map((jurusan) {
                  final isSelected = jurusan == 'Semua'
                      ? _selectedJurusan == null
                      : _selectedJurusan == jurusan;
                  return ChoiceChip(
                    label: Text(
                      jurusan,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFF1F5F9),
                    onSelected: (selected) {
                      setState(() {
                        _selectedJurusan = (jurusan == 'Semua' || !selected) ? null : jurusan;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: STATUS PENGAJUAN (3 STATES: Menunggu, Diterima, Tidak Diterima)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatusPengajuanTabWrapper() {
    return Consumer<PengajuanProvider>(
      builder: (context, pengajuanProvider, _) {
        if (pengajuanProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        }

        final list = pengajuanProvider.pengajuanList;
        if (list.isEmpty) {
          return _buildEmptyStatusView();
        }

        final p = list.first;
        return RefreshIndicator(
          onRefresh: () => context.read<PengajuanProvider>().refresh(),
          color: const Color(0xFF2563EB),
          child: _buildStatusPengajuanContent(p),
        );
      },
    );
  }

  /// Tampilan kosong jika siswa belum pernah mengajukan tempat PKL
  Widget _buildEmptyStatusView() {
    return RefreshIndicator(
      onRefresh: () => context.read<PengajuanProvider>().refresh(),
      color: const Color(0xFF2563EB),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.assignment_late_outlined,
                          size: 44,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Belum Ada Pengajuan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status pengajuan PKL akan ditampilkan di sini setelah kamu mengirimkan permohonan pengajuan tempat PKL.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _tabController.animateTo(0));
                          },
                          icon: const Icon(Icons.apartment_rounded, size: 18),
                          label: Text(
                            'Pilih Tempat PKL Sekarang',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusPengajuanContent(PengajuanModel p) {
    final isDisetujui = p.status == 'disetujui' || p.status == 'approved';
    final isDitolak = p.status == 'ditolak' || p.status == 'rejected';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Card 1: Header Perusahaan & Kondisi Pengajuan ───────────────────
          _buildKondisiPengajuanCard(p),
          const SizedBox(height: 14),

          // ─── Card 2: Catatan Koordinator (Jika Diterima / Ditolak) ────────────
          if (isDisetujui || isDitolak) ...[
            _buildCatatanKoordinatorCard(p),
            const SizedBox(height: 14),
          ],

          // ─── Card 3: Tahapan Verifikasi Stepper ──────────────────────────────
          _buildTahapanVerifikasiCard(p),
          const SizedBox(height: 14),

          // ─── Card 4: Data Permohonan PKL ────────────────────────────────────
          _buildDataPermohonanCard(p),
          const SizedBox(height: 16),

          // ─── Bottom Button (Jika Tidak Diterima) ─────────────────────────────
          if (isDitolak) ...[
            _buildPilihTempatLainButton(),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  // ─── Card 1: Kondisi Pengajuan ─────────────────────────────────────────────
  Widget _buildKondisiPengajuanCard(PengajuanModel p) {
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;
    IconData badgeIcon;
    String descText;

    final isDisetujui = p.status == 'disetujui' || p.status == 'approved';
    final isDitolak = p.status == 'ditolak' || p.status == 'rejected';

    if (isDisetujui) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeTextColor = const Color(0xFF16A34A);
      badgeText = 'Diterima';
      badgeIcon = Icons.check_circle_outline_rounded;
      descText =
          'Selamat! Permohonan PKL Anda di ${p.namaPerusahaan} telah disetujui. Silakan mulai PKL sesuai jadwal yang ditentukan.';
    } else if (isDitolak) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
      badgeText = 'Tidak Diterima';
      badgeIcon = Icons.cancel_outlined;
      descText = p.alasanPenolakan != null && p.alasanPenolakan!.isNotEmpty
          ? p.alasanPenolakan!
          : 'Pengajuan tempat PKL di ${p.namaPerusahaan} belum dapat diterima.';
    } else {
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
      badgeText = 'Menunggu Verifikasi';
      badgeIcon = Icons.hourglass_empty_rounded;
      descText =
          'Pengajuan Anda di ${p.namaPerusahaan} sedang ditinjau oleh Koordinator PKL SMKN 1 Magelang dan pihak DU/DI terkait.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.namaPerusahaan,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Kondisi Pengajuan:',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13, color: badgeTextColor),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descText,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card 2: Catatan Koordinator ───────────────────────────────────────────
  // ─── Card 2: Catatan Koordinator ───────────────────────────────────────────
  Widget _buildCatatanKoordinatorCard(PengajuanModel p) {
    final bool isDiterima = p.status == 'disetujui' || p.status == 'approved';
    final Color bgColor = isDiterima ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final Color borderColor = isDiterima ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);
    final Color iconColor = isDiterima ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final Color titleColor = isDiterima ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    final Color textColor = isDiterima ? const Color(0xFF166534) : const Color(0xFF991B1B);

    final String text = isDiterima
        ? (p.catatan != null && p.catatan!.isNotEmpty
            ? p.catatan!
            : 'Pengajuan kamu di ${p.namaPerusahaan} telah disetujui. Silakan hubungi Koordinator PKL untuk surat tugas dan arahan teknis.')
        : (p.alasanPenolakan != null && p.alasanPenolakan!.isNotEmpty
            ? p.alasanPenolakan!
            : 'Kuota penerimaan di ${p.namaPerusahaan} belum tersedia atau telah penuh. Silakan pilih alternatif industri lain.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Koordinator:',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card 3: Tahapan Verifikasi ────────────────────────────────────────────
  Widget _buildTahapanVerifikasiCard(PengajuanModel p) {
    final isDisetujui = p.status == 'disetujui' || p.status == 'approved';
    final isDitolak = p.status == 'ditolak' || p.status == 'rejected';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tahapan Verifikasi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (isDisetujui) ..._buildStepsDiterima(p),
          if (isDitolak) ..._buildStepsDitolak(p),
          if (!isDisetujui && !isDitolak) ..._buildStepsMenunggu(p),
        ],
      ),
    );
  }

  List<Widget> _buildStepsMenunggu(PengajuanModel p) {
    final dateStr = p.createdAt ?? 'Telah dikirim';
    return [
      _buildStepItem(
        icon: Icons.check_rounded,
        iconColor: Colors.white,
        iconBg: const Color(0xFF16A34A),
        title: 'Pengajuan Tempat PKL',
        subtitle: 'Pengajuan tempat PKL di ${p.namaPerusahaan} berhasil dikirim.',
        dateText: dateStr,
        badgeText: 'Selesai',
        badgeColor: const Color(0xFF16A34A),
        isLast: false,
      ),
      _buildStepItem(
        icon: Icons.hourglass_top_rounded,
        iconColor: const Color(0xFFD97706),
        iconBg: const Color(0xFFFEF3C7),
        title: 'Verifikasi & Peninjauan',
        subtitle: 'Sedang ditinjau oleh Koordinator PKL SMKN 1 Magelang & ${p.namaPerusahaan}.',
        badgeText: 'Sedang Berjalan',
        badgeColor: const Color(0xFFD97706),
        isLast: false,
      ),
      _buildStepItem(
        icon: Icons.circle_outlined,
        iconColor: const Color(0xFF94A3B8),
        iconBg: const Color(0xFFF1F5F9),
        title: 'Hasil Keputusan',
        subtitle: 'Penetapan status persetujuan oleh Koordinator PKL.',
        badgeText: 'Menunggu',
        badgeColor: const Color(0xFF94A3B8),
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildStepsDiterima(PengajuanModel p) {
    final dateStr = p.createdAt ?? 'Telah dikirim';
    return [
      _buildStepItem(
        icon: Icons.check_rounded,
        iconColor: Colors.white,
        iconBg: const Color(0xFF16A34A),
        title: 'Pengajuan Tempat PKL',
        subtitle: 'Pengajuan tempat PKL di ${p.namaPerusahaan} berhasil dikirim.',
        dateText: dateStr,
        badgeText: 'Selesai',
        badgeColor: const Color(0xFF16A34A),
        isLast: false,
      ),
      _buildStepItem(
        icon: Icons.check_rounded,
        iconColor: Colors.white,
        iconBg: const Color(0xFF16A34A),
        title: 'Verifikasi',
        subtitle: 'Disetujui oleh Koordinator PKL SMKN 1 Magelang & ${p.namaPerusahaan}.',
        badgeText: 'Selesai',
        badgeColor: const Color(0xFF16A34A),
        isLast: false,
      ),
      _buildStepItem(
        icon: Icons.check_rounded,
        iconColor: Colors.white,
        iconBg: const Color(0xFF16A34A),
        title: 'Hasil Keputusan',
        subtitle: 'Selamat! Permohonan PKL Anda resmi disetujui. Penempatan telah ditetapkan.',
        badgeText: 'Diterima',
        badgeColor: const Color(0xFF16A34A),
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildStepsDitolak(PengajuanModel p) {
    final dateStr = p.createdAt ?? 'Telah dikirim';
    return [
      _buildStepItem(
        icon: Icons.check_rounded,
        iconColor: Colors.white,
        iconBg: const Color(0xFF16A34A),
        title: 'Pengajuan Tempat PKL',
        subtitle: 'Pengajuan tempat PKL di ${p.namaPerusahaan} berhasil dikirim.',
        dateText: dateStr,
        badgeText: 'Selesai',
        badgeColor: const Color(0xFF16A34A),
        isLast: false,
      ),
      _buildStepItem(
        icon: Icons.check_rounded,
        iconColor: Colors.white,
        iconBg: const Color(0xFF16A34A),
        title: 'Verifikasi',
        subtitle: 'Telah ditinjau oleh Koordinator PKL SMKN 1 Magelang & ${p.namaPerusahaan}.',
        badgeText: 'Selesai',
        badgeColor: const Color(0xFF16A34A),
        isLast: false,
      ),
      _buildStepItem(
        icon: Icons.close_rounded,
        iconColor: Colors.white,
        iconBg: const Color(0xFFDC2626),
        title: 'Hasil Keputusan',
        subtitle: p.alasanPenolakan != null && p.alasanPenolakan!.isNotEmpty
            ? p.alasanPenolakan!
            : 'Mohon maaf, kuota peserta PKL di ${p.namaPerusahaan} telah terisi penuh.',
        badgeText: 'Tidak Diterima',
        badgeColor: const Color(0xFFDC2626),
        isLast: true,
      ),
    ];
  }

  Widget _buildStepItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    String? dateText,
    required String badgeText,
    required Color badgeColor,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and connecting line
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 13),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Texts and status badge
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  if (dateText != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      dateText,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card 4: Data Permohonan PKL ───────────────────────────────────────────
  Widget _buildDataPermohonanCard(PengajuanModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Permohonan PKL',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          _buildDataRow('Nama Instansi / DU/DI', p.namaPerusahaan),
          if (p.alamat.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDataRow('Alamat Instansi', p.alamat),
          ],
          if (p.bidangUsaha.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDataRow('Bidang Usaha', p.bidangUsaha),
          ],
          if (p.namaKontak.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDataRow('Kontak Person', p.namaKontak),
          ],
          if (p.noTelepon.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDataRow('No. Telepon / WA', p.noTelepon),
          ],
          if (p.createdAt != null && p.createdAt!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDataRow('Waktu Pengajuan', p.createdAt!),
          ],
          if (p.catatan != null && p.catatan!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDataRow('Catatan Tambahan', p.catatan!),
          ],
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Button (Pilih Tempat PKL Lain) ──────────────────────────────────
  Widget _buildPilihTempatLainButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _tabController.animateTo(0);
          });
        },
        icon: const Icon(Icons.apartment_rounded, size: 18),
        label: Text(
          'Pilih Tempat PKL Lain',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

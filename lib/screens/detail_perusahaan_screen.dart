import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/perusahaan_model.dart';
import '../models/pengajuan_model.dart';
import '../services/pengajuan_service.dart';
import 'pengajuan_screen.dart';

/// DetailPerusahaanScreen — Tampilan detail profil DU/DI tempat PKL
/// sesuai dengan desain UI/UX, dengan fitur pengajuan langsung 1-klik.
class DetailPerusahaanScreen extends StatefulWidget {
  final PerusahaanModel perusahaan;

  const DetailPerusahaanScreen({
    super.key,
    required this.perusahaan,
  });

  @override
  State<DetailPerusahaanScreen> createState() => _DetailPerusahaanScreenState();
}

class _DetailPerusahaanScreenState extends State<DetailPerusahaanScreen> {
  final _service = PengajuanService();
  bool _isSubmitting = false;

  void _showKonfirmasiPengajuan(BuildContext context) {
    final catatanCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Konfirmasi Pengajuan PKL',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pastikan tempat PKL yang Anda pilih sudah sesuai program keahlian Anda.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ringkasan Perusahaan
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.perusahaan.namaPerusahaan,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '${widget.perusahaan.bidangUsaha} • Kuota: ${widget.perusahaan.kuotaPkl}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Catatan (Opsional)
                  Text(
                    'Catatan / Pilihan Divisi (Opsional)',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: catatanCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Ingin ditempatkan di divisi Web Development...',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Kirim
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setModalState(() => _isSubmitting = true);
                              try {
                                final pengajuan = PengajuanModel(
                                  namaPerusahaan: widget.perusahaan.namaPerusahaan,
                                  alamat: widget.perusahaan.alamatLengkap,
                                  bidangUsaha: widget.perusahaan.bidangUsaha,
                                  namaKontak: widget.perusahaan.pembimbingIndustri,
                                  noTelepon: widget.perusahaan.nomorTelepon,
                                  catatan: catatanCtrl.text.trim().isEmpty
                                      ? null
                                      : catatanCtrl.text.trim(),
                                  status: 'pending',
                                );

                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);

                                await _service.createPengajuan(pengajuan);

                                if (modalContext.mounted) {
                                  Navigator.of(modalContext).pop();
                                }

                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Pengajuan PKL berhasil dikirim!',
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF16A34A),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );

                                  // Langsung redirect ke tab Status Pengajuan
                                  navigator.pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const StatusPengajuanScreen(
                                        initialTabIndex: 1,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => _isSubmitting = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal mengirim: $e'),
                                      backgroundColor: const Color(0xFFDC2626),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _isSubmitting ? 'Mengirim...' : 'Kirim Pengajuan Sekarang',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Perusahaan',
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero Image with Floating Badge ──────────────────────────────
            _buildHeroImage(),
            const SizedBox(height: 16),

            // ─── Card 1: Nama & Lokasi Perusahaan ────────────────────────────
            _buildCompanyMainCard(),
            const SizedBox(height: 14),

            // ─── Card 2: Informasi Perusahaan ────────────────────────────────
            _buildInformasiPerusahaanCard(),
            const SizedBox(height: 14),

            // ─── Card 3: Tentang Perusahaan ──────────────────────────────────
            _buildTentangPerusahaanCard(),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(context),
    );
  }

  // ─── Hero Image ────────────────────────────────────────────────────────────
  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              image: DecorationImage(
                image: NetworkImage(
                  widget.perusahaan.imageUrl ??
                      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.perusahaan.tagKategori,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.perusahaan.namaPendek,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main Card ─────────────────────────────────────────────────────────────
  Widget _buildCompanyMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.perusahaan.namaPerusahaan,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.perusahaan.alamatLengkap,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 23),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Buka Peta & Petunjuk Arah',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 13,
                    color: Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card Informasi Perusahaan ─────────────────────────────────────────────
  Widget _buildInformasiPerusahaanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Text(
                'Informasi Perusahaan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          _buildInfoItem('Bidang Usaha', widget.perusahaan.bidangUsaha),
          const SizedBox(height: 10),
          _buildInfoItem('Nomor Telepon', widget.perusahaan.nomorTelepon),
          const SizedBox(height: 10),
          _buildInfoItem('Email', widget.perusahaan.email),
          const SizedBox(height: 10),
          _buildInfoItem('Pembimbing Industri', widget.perusahaan.pembimbingIndustri),
          const SizedBox(height: 10),
          _buildInfoItem('Kuota PKL', widget.perusahaan.kuotaPkl),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
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

  // ─── Card Tentang Perusahaan ───────────────────────────────────────────────
  Widget _buildTentangPerusahaanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Text(
                'Tentang Perusahaan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.perusahaan.tentangPerusahaan,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Action Bar ─────────────────────────────────────────────────────
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showKonfirmasiPengajuan(context),
            icon: const Icon(Icons.apartment_rounded, size: 20),
            label: Text(
              'Ajukan Tempat PKL',
              style: GoogleFonts.poppins(
                fontSize: 15,
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
        ),
      ),
    );
  }
}

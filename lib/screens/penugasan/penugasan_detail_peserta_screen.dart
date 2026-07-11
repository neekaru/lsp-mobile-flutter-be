import 'package:flutter/material.dart';
import '../../models/jadwal_models.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';

class PenugasanDetailPesertaScreen extends StatefulWidget {
  final AsesiItem asesi;
  final String jadwalTitle;
  final int jadwalId;

  const PenugasanDetailPesertaScreen({
    super.key,
    required this.asesi,
    required this.jadwalTitle,
    required this.jadwalId,
  });

  @override
  State<PenugasanDetailPesertaScreen> createState() => _PenugasanDetailPesertaScreenState();
}

class _PenugasanDetailPesertaScreenState extends State<PenugasanDetailPesertaScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  ParticipantDetailData? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  Future<void> _fetchDetailData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await ApiService.getParticipantDetail(widget.jadwalId, widget.asesi.id);
      if (res != null && res.status == 'success') {
        setState(() {
          _detailData = res.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res?.message ?? 'Gagal memuat detail peserta.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data.';
        _isLoading = false;
      });
    }
  }

  Color _getBadgeBgColor(String status) {
    switch (status) {
      case 'Lengkap':
      case 'Hadir':
      case 'Kompeten':
      case 'Selesai':
        return const Color(0xFFA5D6A7); // Green light
      case 'Belum Kompeten':
        return const Color(0xFFFFCDD2); // Red light
      default:
        return const Color(0xFFFFCC80); // Orange/Beige light
    }
  }

  Color _getBadgeTextColor(String status) {
    switch (status) {
      case 'Lengkap':
      case 'Hadir':
      case 'Kompeten':
      case 'Selesai':
        return const Color(0xFF2E7D32); // Green dark
      case 'Belum Kompeten':
        return const Color(0xFFC62828); // Red dark
      default:
        return const Color(0xFFE65100); // Orange dark
    }
  }

  String _formatIndonesianDate(String yyyymmdd) {
    try {
      final dt = DateTime.tryParse(yyyymmdd);
      if (dt == null) return yyyymmdd;
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthName = months[dt.month - 1];
      return '${dt.day} $monthName ${dt.year}';
    } catch (e) {
      return yyyymmdd;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchDetailData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FD8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Fallbacks if data is still loading or unavailable
    final String displayNoPeserta = _detailData?.noPeserta != null && _detailData!.noPeserta.isNotEmpty
        ? _detailData!.noPeserta
        : 'PES-2026-0724-${widget.asesi.id.toString().padLeft(3, '0')}';

    final String displayNik = _detailData?.nik != null && _detailData!.nik.isNotEmpty
        ? _detailData!.nik
        : '6253748567382';

    final String displayTempatLahir = _detailData?.tempatLahir ?? 'Yogyakarta';
    final String displayTanggalLahir = _detailData?.tanggalLahir != null && _detailData!.tanggalLahir.isNotEmpty
        ? _formatIndonesianDate(_detailData!.tanggalLahir)
        : '10 Mei 1998';
    final String displayTTL = '$displayTempatLahir, $displayTanggalLahir';

    final String displaySkema = _detailData?.skemaSertifikat != null && _detailData!.skemaSertifikat.isNotEmpty
        ? _detailData!.skemaSertifikat
        : widget.jadwalTitle;

    final String displayInstitusi = _detailData?.institusi != null && _detailData!.institusi.isNotEmpty
        ? _detailData!.institusi
        : 'LPP Jigja';

    final String displayEmail = _detailData?.email != null && _detailData!.email.isNotEmpty
        ? _detailData!.email
        : '${widget.asesi.namaLengkap.toLowerCase().replaceAll(' ', '')}@gmail.com';

    final String displayNoTelepon = _detailData?.noTelepon != null && _detailData!.noTelepon.isNotEmpty
        ? _detailData!.noTelepon
        : '085678736521';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          CustomAppBar(
            title: 'Detail Peserta',
            rightWidget: const SizedBox(width: 32),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : RefreshIndicator(
                        onRefresh: _fetchDetailData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Header Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Circle Avatar
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person_outline_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Name and No Peserta
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _detailData?.namaLengkap ?? widget.asesi.namaLengkap,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'No Peserta :$displayNoPeserta',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 2. Profile Details list
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildProfileRow('NIK', displayNik),
                                    _buildProfileRow('Tempat, Tanggal Lahir', displayTTL),
                                    _buildProfileRow('Skema Sertifikat', displaySkema),
                                    _buildProfileRow('Institusi', displayInstitusi),
                                    _buildProfileRow('Email', displayEmail),
                                    _buildProfileRow('No.Telepon', displayNoTelepon),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 3. Status Kelengkapan Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1FC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFB3D7F4),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Status Kelengkapan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatusRow(
                                      icon: Icons.insert_drive_file_outlined,
                                      label: 'Portofolio',
                                      statusText: _detailData?.statusKelengkapan.portofolio ?? 'Lengkap',
                                    ),
                                    _buildStatusRow(
                                      icon: Icons.insert_drive_file_outlined,
                                      label: 'Dokumen Pendukung',
                                      statusText: _detailData?.statusKelengkapan.dokumenPendukung ?? 'Belum Lengkap',
                                    ),
                                    _buildStatusRow(
                                      icon: Icons.insert_drive_file_outlined,
                                      label: 'Persyaratan',
                                      statusText: _detailData?.statusKelengkapan.persyaratan ?? 'Belum Lengkap',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 4. Status Assessment Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1FC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFB3D7F4),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Status Asessment',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatusRow(
                                      icon: Icons.insert_drive_file_outlined,
                                      label: 'Kehadiran',
                                      statusText: _detailData?.statusAssessment.kehadiran ?? 'Belum tersedia',
                                    ),
                                    _buildStatusRow(
                                      icon: Icons.insert_drive_file_outlined,
                                      label: 'Tugas Asessmen',
                                      statusText: _detailData?.statusAssessment.tugasAsesmen ?? 'Belum Dinilai',
                                    ),
                                    _buildStatusRow(
                                      icon: Icons.insert_drive_file_outlined,
                                      label: 'Laporan',
                                      statusText: _detailData?.statusAssessment.laporan ?? 'Belum Dibuat',
                                    ),
                                    _buildStatusRow(
                                      icon: Icons.insert_drive_file_outlined,
                                      label: 'Rekaman',
                                      statusText: _detailData?.statusAssessment.rekaman ?? 'Belum Diunggah',
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String statusText,
  }) {
    final bg = _getBadgeBgColor(statusText);
    final textCol = _getBadgeTextColor(statusText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

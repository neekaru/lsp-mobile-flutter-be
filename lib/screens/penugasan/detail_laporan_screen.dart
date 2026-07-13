import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/asesor_service.dart';

class DetailLaporanScreen extends StatefulWidget {
  final Map<String, String> reportData;

  const DetailLaporanScreen({
    super.key,
    required this.reportData,
  });

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _apiDetails;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final String? idStr = widget.reportData['id'];
    if (idStr != null && idStr.isNotEmpty) {
      final int? id = int.tryParse(idStr);
      if (id != null) {
        setState(() {
          _isLoading = true;
        });
        final details = await AsesorService.getLaporanDetail(id);
        if (mounted) {
          setState(() {
            _apiDetails = details;
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Determine the values from reportData or API details or defaults
    final String code = _apiDetails?['kode_laporan']?.toString() ?? widget.reportData['code'] ?? 'LAP-2026-001';
    final String status = _apiDetails?['status']?.toString() ?? widget.reportData['status'] ?? 'Terkonfirmasi';
    final String tanggal = _apiDetails?['tanggal_pelaksanaan']?.toString() ?? widget.reportData['tanggal'] ?? '24 Juli 2026';
    final String skema = _apiDetails?['skema_sertifikasi']?.toString() ?? widget.reportData['skema'] ?? 'Desaign UI/Ux';
    final String asesor = _apiDetails?['nama_asesor']?.toString() ?? widget.reportData['asesor'] ?? 'Muhammad Hanafi';
    final String tuk = _apiDetails?['tuk']?.toString() ?? widget.reportData['tuk'] ?? 'LPP Jogja';
    final String noSuratTugas = _apiDetails?['no_surat_tugas']?.toString() ?? 'ST-2026-00125';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(title: 'Detail Laporan Tugas'),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon, Code, Status & Date
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: Color(0xFF3B82F6),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    code,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Laporan Tugas Assessor',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dibuat : $tanggal',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),

                        // Surat Tugas Section
                        const Text(
                          'Surat Tugas:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('No. Surat Tugas', noSuratTugas),
                        _buildDetailRow('Skema', skema),
                        _buildDetailRow('TUK', tuk),
                        _buildDetailRow('Tanggal', tanggal),
                        _buildDetailRow('Asesor', asesor),

                        const SizedBox(height: 16),
                        // Lihat Surat Tugas Button
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF3B82F6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: const Color(0xFF3B82F6),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Lihat Surat Tugas',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Video Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF3B82F6),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Skema $skema',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Dokumentasi_Pelaksanaan.mp4',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Mp4 . 87 MB',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 34,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF3B82F6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              foregroundColor: const Color(0xFF3B82F6),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Lihat Video',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.chevron_right_rounded, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. REDESIGNED Execution Summary (Formerly the Pink Box)
                  const Text(
                    'Ringkasan Pelaksanaan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium KPI Grid Row 1 (Kehadiran & Kompetensi)
                        Row(
                          children: [
                            Expanded(
                              child: _buildKPICard(
                                title: 'Peserta Hadir',
                                value: '${_apiDetails?['ringkasan']?['hadir'] ?? 10} Orang',
                                subtitle: '100% Kehadiran',
                                icon: Icons.people_alt_rounded,
                                color: const Color(0xFF3B82F6),
                                bgColor: const Color(0xFFEFF6FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildKPICard(
                                title: 'Kompeten [K]',
                                value: '${_apiDetails?['ringkasan']?['kompeten'] ?? 10} Orang',
                                subtitle: '100% Kompeten',
                                icon: Icons.check_circle_rounded,
                                color: const Color(0xFF10B981),
                                bgColor: const Color(0xFFECFDF5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Breakdown list
                        const Text(
                          'Detail Pelaksanaan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildStatItem('Total Terdaftar', '${_apiDetails?['ringkasan']?['total_peserta'] ?? 10} Orang', const Color(0xFF1E293B)),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildStatItem('Peserta Hadir', '${_apiDetails?['ringkasan']?['hadir'] ?? 10} Orang', const Color(0xFF10B981)),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildStatItem('Peserta Absen', '${_apiDetails?['ringkasan']?['absen'] ?? "-"}', const Color(0xFFEF4444)),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildStatItem('Hasil Kompeten [K]', '${_apiDetails?['ringkasan']?['kompeten'] ?? 10} Orang', const Color(0xFF10B981)),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildStatItem('Hasil Belum Kompeten [TK]', '${_apiDetails?['ringkasan']?['belum_kompeten'] ?? "-"}', const Color(0xFFEF4444)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Catatan Asessor
                  const Text(
                    'Catatan Asessor',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _apiDetails?['catatan']?.toString() ?? 'Asesi telah mengumpulkan seluruh tugas implementasi UI Design dengan lengkap. Melalui sesi wawancara, Asesi mampu membuktikan keaslian karya secara mandiri, menjelaskan alur user flow dengan logis, serta menggunakan design system yang terkini. Seluruh kriteria unjuk kerja telah terpenuhi dengan cukup.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Lampiran Bukti
                  const Text(
                    'Lampiran Bukti',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: (_apiDetails?['lampiran_pendukung'] is List && (_apiDetails?['lampiran_pendukung'] as List).isNotEmpty)
                          ? (_apiDetails?['lampiran_pendukung'] as List).asMap().entries.map<Widget>((entry) {
                              final idx = entry.key;
                              final String url = entry.value.toString();
                              final String name = url.split('/').last;
                              return Column(
                                children: [
                                  if (idx > 0) const Divider(height: 16, color: Color(0xFFE2E8F0)),
                                  _buildAttachmentRow(name),
                                ],
                              );
                            }).toList()
                          : [
                              _buildAttachmentRow('Daftar_Hadir.JPG'),
                              const Divider(height: 16, color: Color(0xFFE2E8F0)),
                              _buildAttachmentRow('Surat_Tugas.Pdf'),
                              const Divider(height: 16, color: Color(0xFFE2E8F0)),
                              _buildAttachmentRow('Dokumentasi.Mp4'),
                            ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCBD5E1),
                        foregroundColor: const Color(0xFF475569),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentRow(String name) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

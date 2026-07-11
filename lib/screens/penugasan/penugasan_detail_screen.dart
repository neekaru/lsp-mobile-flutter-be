import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import '../../services/api_service.dart';
import 'penugasan_peserta_screen.dart';

class PenugasanDetailScreen extends StatefulWidget {
  final JadwalItem jadwal;
  final UserRole userRole;

  const PenugasanDetailScreen({
    super.key,
    required this.jadwal,
    required this.userRole,
  });

  @override
  State<PenugasanDetailScreen> createState() => _PenugasanDetailScreenState();
}

class _PenugasanDetailScreenState extends State<PenugasanDetailScreen> {
  bool _isLoading = false;
  JadwalAsesorDetailData? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  Future<void> _fetchDetailData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await ApiService.getJadwalAsesorDetail(widget.jadwal.id);
      if (res != null && mounted) {
        setState(() {
          _detailData = res.data;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error loading assessor detail: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatIndonesianDayAndDate(String yyyymmdd) {
    try {
      final dt = DateTime.tryParse(yyyymmdd);
      if (dt == null) return yyyymmdd;
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    } catch (e) {
      return yyyymmdd;
    }
  }

  String _getDisplayDateAndTime() {
    final dateStr = _formatIndonesianDayAndDate(widget.jadwal.tanggalMulai);
    final timeStr = (_detailData?.waktuAsesmen != null && _detailData!.waktuAsesmen!.isNotEmpty)
        ? _detailData!.waktuAsesmen!
        : '09:00 - 11:00 WIB';
    return '$dateStr $timeStr';
  }

  String _getDisplayAsesor() {
    if (_detailData != null && _detailData!.asesor.isNotEmpty) {
      return _detailData!.asesor.map((e) => e.namaAsesor).join(', ');
    }
    if (widget.jadwal.asesor.isNotEmpty) {
      return widget.jadwal.asesor.join(', ');
    }
    return 'Eko Setiabudi';
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Status badge styling matching the screenshot (Waiting = Light Blue background/blue text)
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;
    
    final status = widget.jadwal.status.toLowerCase();
    if (status == 'waiting') {
      badgeText = 'Waiting';
      badgeBg = const Color(0xFFCBE0F5);
      badgeTextColor = const Color(0xFF2C6C9C);
    } else if (status == 'running') {
      badgeText = 'Berjalan';
      badgeBg = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF2563EB);
    } else if (status == 'pelaporan') {
      badgeText = 'Pelaporan';
      badgeBg = const Color(0xFFF3E8FF);
      badgeTextColor = const Color(0xFF7C3AED);
    } else if (status == 'canceled') {
      badgeText = 'Batal';
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
    } else if (status == 'completed') {
      badgeText = 'Selesai';
      badgeBg = const Color(0xFFD1FAE5);
      badgeTextColor = const Color(0xFF059669);
    } else {
      badgeText = widget.jadwal.status;
      badgeBg = const Color(0xFFE2E8F0);
      badgeTextColor = const Color(0xFF475569);
    }

    final String skemaName = widget.jadwal.skema;
    final String tukName = _detailData?.tuk ?? widget.jadwal.tuk;
    final String lokasiName = _detailData != null && _detailData!.alamatTuk.isNotEmpty
        ? _detailData!.alamatTuk
        : 'Kalimantan Tengah';
    
    final String jumlahPeserta = _detailData?.jumlahPeserta != null
        ? '${_detailData!.jumlahPeserta}'
        : '${widget.jadwal.jumlahAsesi}';
        
    final String leadAsesor = (_detailData != null && _detailData!.asesor.isNotEmpty)
        ? _detailData!.asesor.first.namaAsesor
        : (_detailData?.leadAsesor != null && _detailData!.leadAsesor!.isNotEmpty)
            ? _detailData!.leadAsesor!
            : _getDisplayAsesor();

    final String catatanAdmin = widget.jadwal.catatan ?? 'Harap hadir 20 menit sebelum pelaksanaan asessmen.';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          CustomAppBar(
            title: 'Detail Penugasan',
            rightWidget: const SizedBox(width: 32),
          ),

          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C6C9C)),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Main Card matching screenshot
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Section: Icon, Text, Status Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Blue calendar icon container
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1FC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFF2C6C9C),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Title and Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      skemaName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tukName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    color: badgeTextColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(
                            thickness: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                          const SizedBox(height: 16),

                          // Details Rows matching screenshot field names exactly
                          _buildDetailRow(
                            icon: LucideIcons.clock,
                            label: 'Jadwal Asessmen',
                            valueWidget: Text(
                              _getDisplayDateAndTime(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          _buildDetailRow(
                            icon: LucideIcons.users,
                            label: 'Peserta',
                            valueWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  jumlahPeserta,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Peserta',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildDetailRow(
                            icon: LucideIcons.map_pin,
                            label: 'Tempat',
                            iconColor: Colors.orange,
                            valueWidget: Text(
                              lokasiName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          _buildDetailRow(
                            icon: LucideIcons.user,
                            label: 'Asessor',
                            valueWidget: Text(
                              leadAsesor,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          _buildDetailRow(
                            icon: LucideIcons.file_text,
                            label: 'No.Surat Tugas',
                            valueWidget: Text(
                              leadAsesor, // Matches Eko Setiabudi value in screenshot
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          _buildDetailRow(
                            icon: LucideIcons.file_text,
                            label: 'Status Penugasan',
                            valueWidget: const Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981), // Green Color
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Catatan Admin Box
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE8D7), // Peach color background
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF3CBB3),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Catatan Admin',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    catatanAdmin,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Bottom Buttons Row
                  Row(
                    children: [
                      // Kembali Button
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCCCCCC),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Kembali',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Lihat Peserta Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B9FD8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PenugasanPesertaScreen(
                                    jadwalId: widget.jadwal.id,
                                    jadwalTitle: widget.jadwal.skema,
                                    tanggal: widget.jadwal.tanggalMulai,
                                    waktu: _detailData?.waktuAsesmen ?? '09:00 - 11:00 WIB',
                                    tuk: _detailData?.tuk ?? widget.jadwal.tuk,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Lihat Peserta',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required Widget valueWidget,
    Color iconColor = Colors.grey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon and Label with fixed width for perfect vertical alignment
          SizedBox(
            width: 155,
            child: Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Value
          Expanded(child: valueWidget),
        ],
      ),
    );
  }
}

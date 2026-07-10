import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import 'jadwal_edit_screen.dart';
import '../../services/auth_repository.dart';
import '../../services/api_service.dart';
import 'profil_asesor_screen.dart';

class JadwalDetailScreen extends StatefulWidget {
  final JadwalItem jadwal;
  final UserRole userRole;

  const JadwalDetailScreen({
    super.key,
    required this.jadwal,
    required this.userRole,
  });

  @override
  State<JadwalDetailScreen> createState() => _JadwalDetailScreenState();
}

class _JadwalDetailScreenState extends State<JadwalDetailScreen> {
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

  String _formatIndonesianDate(String yyyymmdd) {
    try {
      final parts = yyyymmdd.split('-');
      if (parts.length != 3) return yyyymmdd;
      final year = parts[0];
      final monthIndex = int.parse(parts[1]);
      final day = int.parse(parts[2]).toString();

      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthName = months[monthIndex - 1];
      return '$day $monthName $year';
    } catch (e) {
      return yyyymmdd;
    }
  }

  String _getDurationString() {
    try {
      final start = DateTime.parse(widget.jadwal.tanggalMulai);
      final end = DateTime.parse(widget.jadwal.tanggalSelesai);
      final diff = end.difference(start).inDays + 1;
      return '$diff Hari';
    } catch (e) {
      return '7 Hari'; // Fallback matching the image
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'waiting':
        return 'Waiting';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      case 'running':
        return 'Running';
      case 'pelaporan':
        return 'Pelaporan';
      default:
        return status;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label = _getStatusLabel(status);

    switch (status) {
      case 'waiting':
        bgColor = const Color(0xFFFFEAD2);
        textColor = const Color(0xFFE67E22);
        icon = LucideIcons.clock;
        break;
      case 'completed':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = LucideIcons.circle_check;
        break;
      case 'canceled':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = LucideIcons.circle_x;
        break;
      case 'running':
        bgColor = const Color(0xFFE5F1FC);
        textColor = const Color(0xFF2C6C9C);
        icon = LucideIcons.play;
        break;
      case 'pelaporan':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        icon = LucideIcons.file_text;
        break;
      default:
        bgColor = const Color(0xFFECEFF1);
        textColor = const Color(0xFF546E7A);
        icon = LucideIcons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 32),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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

  String _getDisplayAsesor() {
    if (widget.jadwal.asesor.isEmpty) {
      return 'Belum ditentukan';
    }
    return widget.jadwal.asesor.first;
  }

  String _formatAsesiDateRange() {
    try {
      final start = DateTime.tryParse(widget.jadwal.tanggalMulai);
      final end = DateTime.tryParse(widget.jadwal.tanggalSelesai);
      if (start == null || end == null) return '${widget.jadwal.tanggalMulai} - ${widget.jadwal.tanggalSelesai}';
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final startDay = days[start.weekday - 1];
      final monthName = months[start.month - 1];

      if (start.month == end.month && start.year == end.year) {
        if (start.day == end.day) {
          return '$startDay, ${start.day} $monthName ${start.year}';
        }
        return '$startDay, ${start.day}-${end.day} $monthName ${start.year}';
      } else {
        final endDay = days[end.weekday - 1];
        final endMonthName = months[end.month - 1];
        return '$startDay, ${start.day} $monthName ${start.year} - $endDay, ${end.day} $endMonthName ${end.year}';
      }
    } catch (e) {
      return '${widget.jadwal.tanggalMulai} - ${widget.jadwal.tanggalSelesai}';
    }
  }

  Widget _buildChecklistItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_box_rounded,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsesiInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = Colors.grey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsesorStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'waiting':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        label = 'Waiting';
        break;
      case 'completed':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        label = 'Complete';
        break;
      case 'canceled':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'Canceled';
        break;
      case 'running':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        label = 'Running';
        break;
      case 'pelaporan':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7C3AED);
        label = 'Pelaporan';
        break;
      default:
        bgColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF475569);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAsesorDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = Colors.grey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F1FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2C6C9C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF2C6C9C),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAsesorDetailView(BuildContext context) {
    final String leadAsesor = (_detailData != null && _detailData!.asesor.isNotEmpty)
        ? _detailData!.asesor.first.namaAsesor
        : _getDisplayAsesor();

    final String totalPeserta = '${widget.jadwal.jumlahAsesi} Peserta';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Main info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Title & Subtitle, Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F1FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF2C6C9C),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.jadwal.skema,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _detailData?.tuk ?? widget.jadwal.tuk,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildAsesorStatusBadge(widget.jadwal.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFECEFF1)),
                const SizedBox(height: 16),

                // Info rows
                _buildAsesorDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Asesmen',
                  value: _formatAsesiDateRange(),
                ),
                _buildAsesorDetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Waktu Asesmen',
                  value: '09:00 - 11:00 WIB',
                ),
                _buildAsesorDetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi Asesmen',
                  value: _detailData != null && _detailData!.alamatTuk.isNotEmpty
                      ? _detailData!.alamatTuk
                      : 'Yogyakarta',
                  iconColor: Colors.orange,
                ),
                _buildAsesorDetailRow(
                  icon: Icons.people_outline_rounded,
                  label: 'Peserta',
                  value: totalPeserta,
                ),
                _buildAsesorDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Lead Asesor',
                  value: leadAsesor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Lihat Surat Tugas
          _buildActionButtonCard(
            icon: Icons.description_rounded,
            title: 'Lihat Surat Tugas',
            onTap: () {
              // Action for Surat Tugas
            },
          ),
          const SizedBox(height: 12),

          // Card 3: Lihat Peserta
          _buildActionButtonCard(
            icon: Icons.people_rounded,
            title: 'Lihat Peserta',
            onTap: () {
              // Action for Lihat Peserta
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAsesiDetailView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Jadwal Terverifikasi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Jadwal Anda telah diverifikasi oleh pihak lsp',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Calendar Icon, Scheme, TUK
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F1FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF2C6C9C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.jadwal.skema,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _detailData?.tuk ?? widget.jadwal.tuk,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details List
                _buildAsesiInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Asesmen',
                  value: _formatAsesiDateRange(),
                ),
                _buildAsesiInfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Waktu Asesmen',
                  value: '09:00 - 11:00 WIB',
                ),
                _buildAsesiInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi Asesmen',
                  value: _detailData != null && _detailData!.alamatTuk.isNotEmpty
                      ? _detailData!.alamatTuk
                      : 'Yogyakarta',
                  iconColor: Colors.orange,
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFECEFF1)),
                const SizedBox(height: 12),

                // Asesor Section
                const Text(
                  'Asesor',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                if (_detailData != null && _detailData!.asesor.isNotEmpty)
                  ..._detailData!.asesor.map((asesorItem) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        asesorItem.namaAsesor,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'No Reg: ${asesorItem.noReg}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD2E3F4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF6C8BB4), width: 1),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfilAsesorScreen(
                                          name: asesorItem.namaAsesor,
                                          skema: widget.jadwal.skema,
                                          lokasi: asesorItem.kabupatenKota,
                                          asesorDetail: asesorItem,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Lihat Profil Asesor',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C6C9C),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                else ...[
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDisplayAsesor(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.jadwal.skema,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2E3F4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF6C8BB4), width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilAsesorScreen(
                                name: _getDisplayAsesor(),
                                skema: widget.jadwal.skema,
                                lokasi: 'Yogyakarta',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Lihat Profil Asesor',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C6C9C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFECEFF1)),
                const SizedBox(height: 12),

                // Checklist Section
                _buildChecklistItem('Portofolio Lengkap'),
                _buildChecklistItem('Bukti Kompetensi Valid'),
                _buildChecklistItem('Pra Asesmen Disetujui'),

                const SizedBox(height: 16),
                // Hubungi Admin Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2E3F4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6C8BB4), width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Action for Hubungi Admin
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Hubungi Admin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C6C9C),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final role = AuthRepository.currentUserInstance?.role;
    final bool isAsesi = role == 'asesi';
    final bool isAsesor = role == 'asesor';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          // Header with consistent style (Statistics Header)
          CustomAppBar(
            title: 'Detail Jadwal',
            rightWidget: (isAsesi || isAsesor)
                ? const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.black,
                    size: 24,
                  )
                : const SizedBox(width: 32),
          ),

          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),

          // Content
          Expanded(
            child: isAsesi
                ? _buildAsesiDetailView(context)
                : isAsesor
                    ? _buildAsesorDetailView(context)
                    : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Title & Badge & ID (exactly matching image except dynamic details)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.jadwal.skema,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'ID Jadwal : OKM-2026-0606-${widget.jadwal.id.toString().padLeft(3, '0')}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildStatusBadge(widget.jadwal.status),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card 2: Informasi Jadwal (exactly matching image)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with Edit icon on the right
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Informasi Jadwal',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (widget.userRole.canEditSchedule)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => JadwalEditScreen(
                                                jadwal: widget.jadwal,
                                                userRole: widget.userRole,
                                              ),
                                            ),
                                          );
                                          if (!context.mounted) return;
                                          if (result == true) {
                                            Navigator.pop(context, true);
                                          }
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFD3E4F6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            LucideIcons.pencil,
                                            color: Color(0xFF2F80ED),
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                                const SizedBox(height: 8),

                                // Rows
                                _buildInfoRow(
                                  icon: LucideIcons.map_pin,
                                  iconColor: const Color(0xFFEF5350),
                                  iconBgColor: const Color(0xFFFFEBEE),
                                  label: 'Tempat Uji Kompetensi',
                                  value: _detailData != null && _detailData!.alamatTuk.isNotEmpty
                                      ? '${_detailData!.tuk}\n(${_detailData!.alamatTuk})'
                                      : widget.jadwal.tuk,
                                ),
                                _buildInfoRow(
                                  icon: LucideIcons.calendar,
                                  iconColor: const Color(0xFF2F80ED),
                                  iconBgColor: const Color(0xFFE5F1FC),
                                  label: 'Periode Asesmen',
                                  value: '${_formatIndonesianDate(widget.jadwal.tanggalMulai)} - ${_formatIndonesianDate(widget.jadwal.tanggalSelesai)}',
                                ),
                                _buildInfoRow(
                                  icon: LucideIcons.clock,
                                  iconColor: const Color(0xFF2F80ED),
                                  iconBgColor: const Color(0xFFE5F1FC),
                                  label: 'Durasi Pelaksanaan',
                                  value: _getDurationString(),
                                ),
                                _buildInfoRow(
                                  icon: LucideIcons.user,
                                  iconColor: const Color(0xFF2F80ED),
                                  iconBgColor: const Color(0xFFE5F1FC),
                                  label: 'Asesor',
                                  value: _detailData != null && _detailData!.asesor.isNotEmpty
                                      ? _detailData!.asesor.map((e) => e.namaAsesor).join(', ')
                                      : (widget.jadwal.asesor.isEmpty
                                          ? 'Belum ditentukan'
                                          : widget.jadwal.asesor.join(', ')),
                                ),
                                _buildInfoRow(
                                  icon: LucideIcons.users,
                                  iconColor: const Color(0xFF2F80ED),
                                  iconBgColor: const Color(0xFFE5F1FC),
                                  label: 'Jumlah asesi',
                                  value: '${widget.jadwal.jumlahAsesi} Asesi',
                                ),

                                const SizedBox(height: 12),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                                const SizedBox(height: 16),

                                // Warning/Info Banner inside card
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFDE7), // Light yellow
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFFF59D), width: 1),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_rounded,
                                        color: Color(0xFFFBC02D),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Pelaksanaan uji kompetensi untuk skema ${widget.jadwal.skema} sudah sesuai dengan standar yang berlaku.',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // Card 3: Daftar Asesor Tugas (Only shown when detailData has assessors)
                          if (_detailData != null && _detailData!.asesor.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Daftar Asesor Tugas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                                  const SizedBox(height: 12),
                                  ..._detailData!.asesor.map((asesorItem) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF5F5F5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person_outline_rounded,
                                                color: Colors.grey,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    asesorItem.namaAsesor,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Reg: ${asesorItem.noReg}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFE5F1FC),
                                                foregroundColor: const Color(0xFF2C6C9C),
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProfilAsesorScreen(
                                                      name: asesorItem.namaAsesor,
                                                      skema: widget.jadwal.skema,
                                                      lokasi: asesorItem.kabupatenKota,
                                                      asesorDetail: asesorItem,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Profil',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
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
}

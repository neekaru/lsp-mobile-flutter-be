import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/jadwal_models.dart';
import 'jadwal_edit_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          // Header with consistent style (Statistics Header)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular Black Back Arrow Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                
                // Bold screen title
                const Text(
                  'Detail Jadwal',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                
                // Spacing to keep title centered
                const SizedBox(width: 32),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
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
                          label: 'Tempat uji Kompetensi',
                          value: widget.jadwal.tuk,
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
                          value: widget.jadwal.asesor.isEmpty
                              ? 'Belum ditentukan'
                              : widget.jadwal.asesor.join(', '),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

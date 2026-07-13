import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/jadwal_models.dart';
import '../../services/auth_repository.dart';

class JadwalListItem extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;

  const JadwalListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  String _formatIndonesianDate(String yyyymmdd) {
    try {
      final parts = yyyymmdd.split('-');
      if (parts.length != 3) return yyyymmdd;
      final year = parts[0];
      final monthIndex = int.parse(parts[1]);
      final day = int.parse(parts[2]).toString();

      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final monthName = months[monthIndex - 1];
      return '$day $monthName $year';
    } catch (e) {
      return yyyymmdd;
    }
  }

  Color _getStatusColor() {
    switch (item.status) {
      case 'waiting':
        return const Color(0xFFFBC02D); // Yellow
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'canceled':
        return const Color(0xFFE53935); // Red
      case 'running':
        return const Color(0xFF2196F3); // Blue
      case 'pelaporan':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF2C6C9C);
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case 'waiting':
        return 'Waiting';
      case 'completed':
        return ''; // Hidden - no bottom status text for completed
      case 'canceled':
        return 'Canceled';
      case 'running':
        // Jika ada days_late (terlambat), tampilkan badge terlambat
        if (item.daysLate != null && item.daysLate! > 0) {
          return 'Telat ${item.daysLate} hari';
        }
        return 'Sisa ${item.sisaHari} hari';
      case 'pelaporan':
        return 'Pelaporan';
      default:
        return item.status;
    }
  }

  String _getDisplayAsesor() {
    if (item.asesor.isEmpty) {
      return 'Belum ditentukan';
    }
    return item.asesor.join(', ');
  }

  String _getDisplayAsesi() {
    // Backend sudah return jumlah_asesi
    // Jika 0, kemungkinan memang belum ada peserta
    if (item.jumlahAsesi == 0) {
      return '0 Asesi';
    }
    return '${item.jumlahAsesi} Asesi';
  }

  bool _shouldShowWarning() {
    // Tampilkan warning jika:
    // 1. Status running dan sisa hari <= 3
    // 2. Status running dan ada days_late (terlambat)
    if (item.status == 'running') {
      if (item.daysLate != null && item.daysLate! > 0) {
        return true; // Terlambat
      }
      if (item.sisaHari <= 3) {
        return true; // Segera berakhir
      }
    }
    return false;
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

  Widget _buildAsesiCard(BuildContext context) {
    String badgeText;
    Color badgeBg;
    Color badgeTextColor;

    if (item.status == 'running' || item.status == 'waiting') {
      badgeText = 'Terjadwal';
      badgeBg = const Color(0xFFD2E3F4);
      badgeTextColor = const Color(0xFF2C6C9C);
    } else if (item.status == 'pelaporan') {
      badgeText = 'Berjalan';
      badgeBg = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF4CAF50);
    } else {
      badgeText = 'Selesai';
      badgeBg = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFEF5350);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon, Title & TUK, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
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

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.skema,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.tuk,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Yogyakarta',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFECEFF1)),
              const SizedBox(height: 12),

              // Columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Jadwal Asesmen',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatIndonesianDayAndDate(item.tanggalMulai)}\n08:00 - 11:00 WIB',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 44, color: const Color(0xFFECEFF1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Asesor',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDisplayAsesor(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 44, color: const Color(0xFFECEFF1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Jadwal Selesai',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatIndonesianDayAndDate(item.tanggalSelesai)}\n08:00 - 11:00 WIB',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Button
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
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Lihat Detail',
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
      ),
    );
  }

  Widget _buildAsesorCard(BuildContext context) {
    String badgeText;
    Color badgeBg;
    Color badgeTextColor;

    if (item.status == 'waiting') {
      badgeText = 'Menunggu';
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
    } else if (item.status == 'running') {
      badgeText = 'Berjalan';
      badgeBg = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF2563EB);
    } else if (item.status == 'pelaporan') {
      badgeText = 'Pelaporan';
      badgeBg = const Color(0xFFF3E8FF);
      badgeTextColor = const Color(0xFF7C3AED);
    } else if (item.status == 'canceled') {
      badgeText = 'Batal';
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
    } else if (item.status == 'completed') {
      badgeText = 'Selesai';
      badgeBg = const Color(0xFFD1FAE5);
      badgeTextColor = const Color(0xFF059669);
    } else {
      badgeText = item.status;
      badgeBg = const Color(0xFFE2E8F0);
      badgeTextColor = const Color(0xFF475569);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon, Title & TUK, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
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

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.skema,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.tuk,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Yogyakarta',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFECEFF1)),
              const SizedBox(height: 12),

              // Columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Jadwal Asesmen',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatIndonesianDayAndDate(item.tanggalMulai)}\n08:00 - 11:00 WIB',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 44, color: const Color(0xFFECEFF1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Asesor',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDisplayAsesor(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 44, color: const Color(0xFFECEFF1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Jadwal Selesai',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatIndonesianDayAndDate(item.tanggalSelesai)}\n08:00 - 11:00 WIB',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Button
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
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Lihat Detail',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthRepository.currentUserInstance?.role;
    final bool isAsesi = role == 'asesi';
    final bool isAsesor = role == 'asesor';

    if (isAsesi) {
      return _buildAsesiCard(context);
    }
    if (isAsesor) {
      return _buildAsesorCard(context);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F1FC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.file_text,
                      color: Color(0xFF2C6C9C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.skema,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.map_pin,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.tuk,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatIndonesianDate(item.tanggalMulai)} - ${_formatIndonesianDate(item.tanggalSelesai)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Jumlah Asesi
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.users,
                                    size: 12,
                                    color: Color(0xFF666666),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getDisplayAsesi(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Asesor
                            Expanded(
                              child: Text(
                                'Asesor: ${_getDisplayAsesor()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Warning badge untuk item dengan sisa waktu <= 3 hari atau terlambat
                      if (_shouldShowWarning())
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.circle_alert,
                                size: 12,
                                color: const Color(0xFFFF6B6B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.daysLate != null && item.daysLate! > 0
                                    ? 'Terlambat'
                                    : 'Segera Berakhir',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.needsAcc ? const Color(0xFFFFEBEE) : _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.needsAcc ? 'Butuh ACC' : (
                          item.status == 'waiting' ? 'Waiting' : 
                          item.status == 'completed' ? 'Completed' :
                          item.status == 'canceled' ? 'Canceled' :
                          item.status == 'running' ? 'Running' :
                          item.status == 'pelaporan' ? 'Pelaporan' : item.status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.needsAcc ? const Color(0xFFE53935) : _getStatusColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_shouldShowWarning())
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                LucideIcons.clock,
                                size: 12,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _shouldShowWarning() ? const Color(0xFFFF6B6B) : _getStatusColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Action Button
            if (item.needsAcc)
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.circle_check,
                            size: 16,
                            color: const Color(0xFF2C6C9C),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Detail & ACC Jadwal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C6C9C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else if (item.status != 'completed' && item.status != 'canceled' && item.status != 'pelaporan')
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: const Color(0xFF5B9FD8),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ubah Status Jadwal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B9FD8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  }
}

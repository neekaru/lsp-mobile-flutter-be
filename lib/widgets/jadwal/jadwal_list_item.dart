import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/jadwal_models.dart';

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
    // Untuk status selesai, gunakan warna biru
    if (item.status == 'selesai') {
      return const Color(0xFF2C6C9C); // Biru
    }
    
    // Untuk status lainnya, tentukan berdasarkan sisa hari
    if (item.sisaHari <= 3) {
      return const Color(0xFFFF6B6B); // Merah
    } else {
      return const Color(0xFFFFA726); // Kuning/Orange
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case 'akan_berakhir':
        return item.sisaHari <= 3 ? 'Sisa ${item.sisaHari} hari lagi' : '${item.sisaHari} hari lagi';
      case 'sedang_berjalan':
        return 'Sisa ${item.sisaHari} hari';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Terjadwal';
    }
  }

  String _getDisplayAsesor() {
    // Backend sudah return asesor name
    if (item.asesor.isEmpty || item.asesor == '-') {
      return 'Belum ditentukan';
    }
    return item.asesor;
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
    return item.status == 'sedang_berjalan' && item.sisaHari <= 3;
  }

  @override
  Widget build(BuildContext context) {
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
                      // Warning badge untuk item dengan sisa waktu <= 3 hari
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
                              const Text(
                                'Segera Berakhir',
                                style: TextStyle(
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
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status == 'akan_berakhir' ? 'Terjadwal' : 
                          item.status == 'sedang_berjalan' ? 'Berjalan' : 'Selesai',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
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

            // Bottom Action Button (hanya untuk akan_berakhir dan sedang_berjalan)
            if (item.status != 'selesai')
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

import 'package:material_ui/material_ui.dart';
import '../../services/api_service.dart';
import '../../models/jadwal_models.dart';
import '../../utils/date_format_helper.dart';

class NotificationCard extends StatelessWidget {
  final WaitingSchedule schedule;
  final VoidCallback onTap;
  final VoidCallback onStatusUpdated;

  /// Whether the current user may confirm the schedule (admin & asesor).
  final bool canConfirm;

  const NotificationCard({
    super.key,
    required this.schedule,
    required this.onTap,
    required this.onStatusUpdated,
    required this.canConfirm,
  });

  void _confirmStatusUpdate(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF2E7D32),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Konfirmasi Jadwal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin mengonfirmasi jadwal "${schedule.jadwal}"?\n\nStatus jadwal ini akan berubah menjadi Running.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF455A64),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _performStatusUpdate(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Konfirmasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performStatusUpdate(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            ),
          ),
        );
      },
    );

    // Call API
    final result = await ApiService.updateJadwalStatus(
      jadwalId: schedule.id,
      rule: 'draft_to_ongoing',
    );

    // Hide loading indicator
    if (context.mounted) {
      Navigator.pop(context);
    }

    if (result['success'] == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jadwal "${schedule.jadwal}" berhasil dikonfirmasi ke Running.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      onStatusUpdated();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Gagal memperbarui status jadwal.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.statusLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Jadwal Name
            Text(
              schedule.jadwal,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // TUK Info
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    schedule.tuk,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Date Info
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateRange(schedule.tanggal, schedule.tanggalAkhir),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom Info
            Row(
              children: [
                // Asesi Count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 12,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${schedule.jumlahAsesi} Asesi',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Asesor
                Expanded(
                  child: Text(
                    'Asesor: ${schedule.asesor.isEmpty ? 'Belum ditentukan' : schedule.asesor.join(', ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (canConfirm) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _confirmStatusUpdate(context),
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Konfirmasi Jadwal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32), // Forest Green
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateRange(String startDate, String? endDate) {
    try {
      final start = DateFormatHelper.formatToIndonesian(startDate);
      if (endDate == null || endDate.isEmpty) {
        return start;
      }
      final end = DateFormatHelper.formatToIndonesian(endDate);
      return '$start - $end';
    } catch (e) {
      return startDate;
    }
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../screens/jadwal_screen.dart';

class JadwalAsesmen extends StatefulWidget {
  final List<JadwalBaru>? data;
  final bool? isLoading;
  final VoidCallback? onTapLihatSemua;

  const JadwalAsesmen({
    super.key,
    this.data,
    this.isLoading,
    this.onTapLihatSemua,
  });

  @override
  State<JadwalAsesmen> createState() => _JadwalAsesmenState();
}

class _JadwalAsesmenState extends State<JadwalAsesmen> {
  late Future<List<JadwalBaru>>? _jadwalFuture;

  @override
  void initState() {
    super.initState();
    // Hanya fetch jika data tidak disediakan dari parent
    if (widget.data == null) {
      _jadwalFuture = ApiService.getJadwalBaru();
    } else {
      _jadwalFuture = null;
    }
  }

  @override
  void didUpdateWidget(JadwalAsesmen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update ketika data dari parent berubah
    if (widget.data != oldWidget.data) {
      setState(() {
        _jadwalFuture = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan data dari parent jika ada
    if (widget.data != null) {
      return _buildContent(widget.data!, widget.isLoading ?? false);
    }

    // Fallback: Gunakan FutureBuilder jika standalone
    return FutureBuilder<List<JadwalBaru>>(
      future: _jadwalFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? [];
        return _buildContent(data, isLoading);
      },
    );
  }

  Widget _buildContent(List<JadwalBaru> data, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Asesmen Baru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.onTapLihatSemua != null) {
                  widget.onTapLihatSemua!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JadwalScreen(),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4FA8E8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildJadwalList(data, isLoading),
      ],
    );
  }

  Widget _buildJadwalList(List<JadwalBaru> data, bool isLoading) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF2C6C9C),
          ),
        ),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Tidak ada jadwal baru',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = data[index];
        return JadwalItemCard(item: item);
      },
    );
  }
}

class JadwalItemCard extends StatelessWidget {
  final JadwalBaru item;

  const JadwalItemCard({super.key, required this.item});

  String _getMonthAbbreviation(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return 'Des';
      final monthIndex = int.parse(parts[1]);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return months[monthIndex - 1];
    } catch (_) {
      return 'Des';
    }
  }

  String _getDayNumber(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return '01';
      return int.parse(parts[2]).toString();
    } catch (_) {
      return '01';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // black with 0.03 opacity
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon Box: Calendar Sheet showing Date & Month
          Container(
            width: 50,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Month Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FA8E8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    _getMonthAbbreviation(item.tanggal).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Day Number
                Expanded(
                  child: Center(
                    child: Text(
                      _getDayNumber(item.tanggal),
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Center Text: Jadwal & TUK
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.jadwal,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.tuk,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Column: Quota Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kuota',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people_alt_rounded,
                    size: 14,
                    color: Color(0xFF4FA8E8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.kuota}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../../models/dashboard_models.dart';
import '../../screens/statistik/masa_berlaku_asesor_detail_screen.dart';

/// Kartu status sertifikat — bisa membuka daftar masa berlaku saat diketuk.
class StatusCard extends StatelessWidget {
  final String title;
  final String count;
  final String desc;
  final Color color;
  final IconData icon;
  final String? statusKey;
  final int numericCount;

  const StatusCard({
    super.key,
    required this.title,
    required this.count,
    required this.desc,
    required this.color,
    required this.icon,
    this.statusKey,
    this.numericCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isClickable = statusKey != null;

    Widget cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
        boxShadow: isClickable
            ? [
                BoxShadow(
                  color: color.withAlpha(15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                count,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
              if (isClickable) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: color,
                ),
              ],
            ],
          ),
          if (isClickable) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lihat Daftar Asesor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: color,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (!isClickable) return cardContent;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MasaBerlakuAsesorDetailScreen(
                statusFilter: statusKey!,
                count: numericCount,
              ),
            ),
          );
        },
        child: cardContent,
      ),
    );
  }
}

/// Kartu bulan masa tenggang sertifikat.
class BulanTenggangCard extends StatelessWidget {
  final MasaTenggangSertifikatBulanItem item;

  const BulanTenggangCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFFD97706);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_outlined, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.bulan.isEmpty ? item.tahunBulan : item.bulan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.totalExpired} sertifikat expired',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.skemaDetail.map(
            (skema) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      skema.namaSkema,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    '${skema.jumlahAsesi} asesi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
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

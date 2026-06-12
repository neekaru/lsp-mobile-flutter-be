import 'package:flutter/material.dart';
import 'skema_detail_summary.dart';
import 'asesmen_header_cards.dart';

class AsesmenMandiriForm extends StatelessWidget {
  final String selectedSkema;
  final List<Map<String, dynamic>> unitKompetensi;
  final Function(int index) onUnitTap;
  final VoidCallback? onBuktiTap;

  const AsesmenMandiriForm({
    super.key,
    required this.selectedSkema,
    required this.unitKompetensi,
    required this.onUnitTap,
    this.onBuktiTap,
  });

  // Helper to generate dynamic mock KUK count label
  String _getKukCount(String kode) {
    if (kode.contains('001')) return '8 KUK';
    if (kode.contains('002')) return '10 KUK';
    if (kode.contains('003')) return '12 KUK';
    if (kode.contains('007')) return '13 KUK';
    return '11 KUK'; // Default matching standard screenshot
  }

  @override
  Widget build(BuildContext context) {
    // Determine the metric counts for the SkemaDetailSummary based on the scheme
    final isProgrammer = selectedSkema.toLowerCase().contains('programmer');
    final unitCount = isProgrammer ? 5 : 11;
    final elemenCount = isProgrammer ? 20 : 48;
    final totalKukCount = isProgrammer ? 65 : 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Asesmen Header Cards (Separated Widget)
        AsesmenHeaderCards(onBuktiTap: onBuktiTap),
        const SizedBox(height: 20),

        // 3. Separated Skema Detail Summary Widget (from Image 2)
        SkemaDetailSummary(
          selectedSkema: selectedSkema,
          unitCount: unitCount,
          elemenCount: elemenCount,
          kukCount: totalKukCount,
        ),
        const SizedBox(height: 24),

        // List of unit cards
        ...List.generate(unitKompetensi.length, (index) {
          final unit = unitKompetensi[index];
          final kode = unit['kode'] as String? ?? '';
          final judul = unit['judul'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: InkWell(
              onTap: () => onUnitTap(index),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kode,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getKukCount(kode),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: Color(0xFF378CE7),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // "Lihat Semua Unit Kompetensi" card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: InkWell(
            onTap: () {
              // Action triggers all list view
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      color: Color(0xFF378CE7),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lihat Semua Unit Kopetensi',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F4C81),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '11 Unit',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Color(0xFF378CE7),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

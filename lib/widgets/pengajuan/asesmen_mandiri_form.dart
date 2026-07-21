import 'package:flutter/material.dart';
import 'skema_detail_summary.dart';
import 'asesmen_header_cards.dart';

class AsesmenMandiriForm extends StatelessWidget {
  final String selectedSkema;
  /// Each unit: `kode`, `judul`, `kuk_count` (label), `elemen` (list)
  final List<Map<String, dynamic>> unitKompetensi;
  final bool isLoading;
  final Function(int index) onUnitTap;
  final VoidCallback? onBuktiTap;

  const AsesmenMandiriForm({
    super.key,
    required this.selectedSkema,
    required this.unitKompetensi,
    required this.onUnitTap,
    this.isLoading = false,
    this.onBuktiTap,
  });

  int get _totalElemen {
    var n = 0;
    for (final u in unitKompetensi) {
      final el = u['elemen'];
      if (el is List) n += el.length;
    }
    return n;
  }

  int get _totalKuk {
    var n = 0;
    for (final u in unitKompetensi) {
      final groups = u['elemen'];
      if (groups is! List) continue;
      for (final g in groups) {
        if (g is Map) {
          final items = g['items'];
          if (items is List) {
            n += items.length;
          } else {
            n += 1;
          }
        }
      }
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final unitCount = unitKompetensi.length;
    final elemenCount = _totalElemen;
    final kukCount = _totalKuk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AsesmenHeaderCards(onBuktiTap: onBuktiTap),
        const SizedBox(height: 20),
        SkemaDetailSummary(
          selectedSkema: selectedSkema,
          unitCount: unitCount,
          elemenCount: elemenCount,
          kukCount: kukCount,
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (unitKompetensi.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              selectedSkema.trim().isEmpty
                  ? 'Unit kompetensi belum tersedia. Pilih skema di Data Pengajuan.'
                  : 'Unit/elemen/KUK skema "$selectedSkema" belum termuat. Kembali ke Data Pengajuan lalu pilih ulang skema.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          )
        else
          ...List.generate(unitKompetensi.length, (index) {
            final unit = unitKompetensi[index];
            final kode = unit['kode'] as String? ?? '';
            final judul = unit['judul'] as String? ?? '';
            final kukLabel = unit['kuk_count'] as String? ??
                '${(unit['elemen'] as List?)?.length ?? 0} item';

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              kukLabel,
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
        if (!isLoading && unitKompetensi.isNotEmpty)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Semua Unit Kompetensi',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F4C81),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$unitCount Unit · $elemenCount elemen · $kukCount KUK',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
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
    );
  }
}

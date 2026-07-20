import 'package:flutter/material.dart';
import 'asesmen_header_cards.dart';
import 'skema_detail_summary.dart';

class DokumenPortofolioForm extends StatelessWidget {
  final String selectedSkema;
  /// From GET pra-asesmen kompetensi — same shape as AsesmenMandiriForm.
  final List<Map<String, dynamic>> unitKompetensi;
  final bool isLoading;
  final VoidCallback? onBuktiTap;
  final VoidCallback? onUnitTap;

  const DokumenPortofolioForm({
    super.key,
    required this.selectedSkema,
    this.unitKompetensi = const [],
    this.isLoading = false,
    this.onBuktiTap,
    this.onUnitTap,
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
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SkemaDetailSummary(
            selectedSkema: selectedSkema,
            unitCount: unitCount,
            elemenCount: elemenCount,
            kukCount: kukCount,
            onUnitTap: onUnitTap,
          ),
      ],
    );
  }
}

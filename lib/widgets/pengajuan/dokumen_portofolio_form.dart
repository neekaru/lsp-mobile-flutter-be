import 'package:flutter/material.dart';
import 'asesmen_header_cards.dart';
import 'skema_detail_summary.dart';

class DokumenPortofolioForm extends StatelessWidget {
  final String selectedSkema;
  final VoidCallback? onBuktiTap;

  const DokumenPortofolioForm({
    super.key,
    required this.selectedSkema,
    this.onBuktiTap,
  });

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
        // 1. Asesmen Header Cards (Image 1)
        AsesmenHeaderCards(onBuktiTap: onBuktiTap),
        const SizedBox(height: 20),

        // 2. Skema Detail Summary (Image 2)
        SkemaDetailSummary(
          selectedSkema: selectedSkema,
          unitCount: unitCount,
          elemenCount: elemenCount,
          kukCount: totalKukCount,
        ),
      ],
    );
  }
}

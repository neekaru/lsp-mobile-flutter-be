import 'package:flutter/material.dart';

class SkemaDetailSummary extends StatelessWidget {
  final String selectedSkema;
  final int unitCount;
  final int elemenCount;
  final int kukCount;

  const SkemaDetailSummary({
    super.key,
    required this.selectedSkema,
    required this.unitCount,
    required this.elemenCount,
    required this.kukCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Blue Info Alert Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD), // Light blue background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBBDEFB), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '1. Upload dapat lebih dari 1 file. Klik Browse.',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '2. Ekstensi file yang di perbolehkan Image dan PDF',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '3. Maksimal Ukuran File adalah 2 MB',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. Skema Title Header
        Text(
          'Skema ${selectedSkema.toUpperCase()}',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),

        // 3. Three Metric Cards (Unit, Elemen, KUK)
        _buildMetricCard(
          icon: Icons.assignment_outlined,
          title: 'Unit Kompetensi',
          value: '$unitCount Unit',
        ),
        const SizedBox(height: 8),
        _buildMetricCard(
          icon: Icons.account_tree_outlined,
          title: 'Elemen Kompetensi',
          value: '$elemenCount Element',
        ),
        const SizedBox(height: 8),
        _buildMetricCard(
          icon: Icons.checklist_rtl_rounded,
          title: 'Kriteria Unjuk Kerja(KUK)',
          value: '$kukCount KUK',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2D9CDB),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

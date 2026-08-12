import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

class SkemaWilayahCard extends StatelessWidget {
  final List<TopProvinsi> topProvinces;

  const SkemaWilayahCard({
    super.key,
    required this.topProvinces,
  });

  @override
  Widget build(BuildContext context) {
    final items = topProvinces.isNotEmpty
        ? topProvinces
        : const [
            TopProvinsi(name: 'ACEH', value: 2, percentage: '2,7%'),
            TopProvinsi(name: 'SUMATRA UTARA', value: 1, percentage: '1,4%'),
            TopProvinsi(name: 'RIAU', value: 1, percentage: '1,4%'),
            TopProvinsi(name: 'SUMATRA SELATAN', value: 2, percentage: '1,4%'),
            TopProvinsi(name: 'DKI JAKARTA', value: 11, percentage: '15,1%'),
          ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skema/Wilayah Asesor',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '${item.value} (${item.percentage})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
              ],
            );
          }),
        ],
      ),
    );
  }
}

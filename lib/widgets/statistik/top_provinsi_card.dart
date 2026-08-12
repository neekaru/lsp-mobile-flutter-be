import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../utils/number_format_helper.dart';

class TopProvinsiCard extends StatelessWidget {
  final Future<List<TopProvinsi>> topProvincesFuture;
  final VoidCallback? onViewAll;

  const TopProvinsiCard({
    super.key,
    required this.topProvincesFuture,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Provinsi (Asesor Aktif)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<TopProvinsi>>(
              future: topProvincesFuture,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

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

                return Column(
                  children: items.map((item) {
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
                                  color: const Color(0xFF0F4C81),
                                  borderRadius: BorderRadius.circular(2),
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
                                '${NumberFormatHelper.formatWithDots(item.value)} (${item.percentage})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey[200],
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton(
                onPressed: onViewAll ?? () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2C6C9C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Lihat Semua Provinsi',
                  style: TextStyle(
                    color: Color(0xFF2C6C9C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

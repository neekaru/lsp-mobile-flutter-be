import 'package:flutter/material.dart';
import 'island_data.dart';

class DetailBreakdownCard extends StatelessWidget {
  final IslandData selectedData;

  const DetailBreakdownCard({
    super.key,
    required this.selectedData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedData.baseColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.map_rounded,
                    color: selectedData.baseColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedData.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${selectedData.percentage}% dari total asesi nasional',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedData.assessments} Asesi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C6C9C),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.8),

            const Text(
              'Tingkat Kompetensi Wilayah',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: selectedData.competenceRate,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFECEFF1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        selectedData.baseColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(selectedData.competenceRate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kompeten: ${(selectedData.assessments * selectedData.competenceRate).round()} asesi',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  'Belum Kompeten: ${(selectedData.assessments * (1.0 - selectedData.competenceRate)).round()} asesi',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Rincian Sebaran Provinsi Utama',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(selectedData.topProvinces.length, (index) {
              final provName = selectedData.topProvinces[index];
              final provCount = selectedData.provinceAssessments[index];
              final maxVal = selectedData.provinceAssessments[0];
              final pct = maxVal > 0 ? provCount / maxVal : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '$provCount Asesi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF1F3F5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          selectedData.baseColor.withAlpha(204),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

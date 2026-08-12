import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

class SkemaMetricsCard extends StatelessWidget {
  final bool isLoading;
  final List<SebaranSkemaAsesorItem> sebaranSkemaAsesorList;
  final SebaranSkemaAsesorItem? selectedSkema;
  final String searchQuery;
  final ValueChanged<SebaranSkemaAsesorItem?> onSelectSkema;

  const SkemaMetricsCard({
    super.key,
    required this.isLoading,
    required this.sebaranSkemaAsesorList,
    required this.selectedSkema,
    required this.searchQuery,
    required this.onSelectSkema,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Color(0xFF2C6C9C)),
        ),
      );
    }

    if (sebaranSkemaAsesorList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text('Tidak ada data skema yang disetujui.'),
        ),
      );
    }

    final filteredDropdownList = sebaranSkemaAsesorList.where((item) {
      return item.skema.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.kodeSkema.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown selector for Scheme
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9ECF0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SebaranSkemaAsesorItem>(
                value: selectedSkema != null &&
                        filteredDropdownList.contains(selectedSkema)
                    ? selectedSkema
                    : null,
                hint: const Text('Pilih Skema Sertifikasi',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_circle_outlined,
                    color: Color(0xFF2C6C9C), size: 20),
                menuMaxHeight: 350,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                items: filteredDropdownList.map((item) {
                  return DropdownMenuItem<SebaranSkemaAsesorItem>(
                    value: item,
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_outlined,
                            size: 16, color: Color(0xFF2C6C9C)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.skema} (${item.jumlahAsesor} Asesor)',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onSelectSkema,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Scheme metrics cards
          if (selectedSkema != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildSkemaMetricTile(
                    icon: Icons.people_outline_rounded,
                    iconColor: const Color(0xFF2C6C9C),
                    title: 'Jumlah Asesor',
                    value: '${selectedSkema!.jumlahAsesor}',
                    subtitle: 'Terdaftar',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSkemaMetricTile(
                    icon: Icons.star_border_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Wilayah Terbanyak',
                    value: selectedSkema!.wilayahTerbanyak,
                    subtitle: 'Konsentrasi',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Regional Breakdown List for the selected Scheme
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE9ECF0)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lokasi/Wilayah Asesor Skema',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F1FC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${selectedSkema!.wilayahDetail.length} Provinsi',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C6C9C)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (selectedSkema!.wilayahDetail.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          'Tidak ada data wilayah untuk skema ini.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedSkema!.wilayahDetail.length > 5
                          ? 5
                          : selectedSkema!.wilayahDetail.length,
                      itemBuilder: (context, idx) {
                        final det = selectedSkema!.wilayahDetail[idx];
                        double pct = selectedSkema!.jumlahAsesor > 0
                            ? (det.jumlahAsesor /
                                selectedSkema!.jumlahAsesor *
                                100)
                            : 0.0;
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C6C9C),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      det.provinsiNama,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${det.jumlahAsesor} Asesor (${pct.toStringAsFixed(1).replaceAll('.', ',')}%)',
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
                                color: Colors.grey[200]),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkemaMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
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
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5F6E7D),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8E99A4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/jadwal_models.dart';

class JadwalChart extends StatelessWidget {
  final List<JadwalItem> data;

  const JadwalChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Hitung data untuk chart
    Map<int, int> sisaHariCount = {};
    for (var item in data) {
      sisaHariCount[item.sisaHari] = (sisaHariCount[item.sisaHari] ?? 0) + 1;
    }

    // Buat data chart dengan urutan
    List<ChartData> chartData = [];
    for (int i = 1; i <= 7; i++) {
      chartData.add(ChartData(
        label: '$i',
        value: sisaHariCount[i] ?? 0,
        sisaHari: i,
      ));
    }

    // Cari nilai maksimum untuk scaling
    int maxValue = chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF5B9FD8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Distribusi Jadwal Berdasarkan Sisa Hari',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Jumlah Jadwal',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Chart Area
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildYAxisLabel(maxValue),
                    _buildYAxisLabel((maxValue * 0.75).toInt()),
                    _buildYAxisLabel((maxValue * 0.5).toInt()),
                    _buildYAxisLabel((maxValue * 0.25).toInt()),
                    _buildYAxisLabel(0),
                  ],
                ),
                const SizedBox(width: 8),

                // Chart Bars
                Expanded(
                  child: Stack(
                    children: [
                      // Grid Lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          return Container(
                            height: 1,
                            color: const Color(0xFFF1F3F5),
                          );
                        }),
                      ),

                      // Bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartData.map((item) {
                          double heightPercentage = item.value / maxValue;
                          return ChartBarItem(
                            value: item.value,
                            heightPercentage: heightPercentage,
                            label: item.label,
                            sisaHari: item.sisaHari,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Mendesak (1-3 hari)',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FA8E8), Color(0xFF2C6C9C)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Normal (4-7 hari)',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabel(int value) {
    return Text(
      value.toString(),
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    );
  }
}

class ChartData {
  final String label;
  final int value;
  final int sisaHari;

  ChartData({
    required this.label,
    required this.value,
    required this.sisaHari,
  });
}

class ChartBarItem extends StatelessWidget {
  final int value;
  final double heightPercentage;
  final String label;
  final int sisaHari;

  const ChartBarItem({
    super.key,
    required this.value,
    required this.heightPercentage,
    required this.label,
    required this.sisaHari,
  });

  @override
  Widget build(BuildContext context) {
    // Warna berbeda untuk jadwal mendesak (1-3 hari)
    final bool isUrgent = sisaHari <= 3;
    final List<Color> barColors = isUrgent
        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
        : [const Color(0xFF4FA8E8), const Color(0xFF2C6C9C)];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Value text on top
            if (value > 0)
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? const Color(0xFFFF6B6B) : const Color(0xFF2C6C9C),
                ),
              ),
            if (value > 0) const SizedBox(height: 6),

            // Bar
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: heightPercentage > 0 ? heightPercentage : 0.02,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: barColors,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(
              'hari',
              style: TextStyle(fontSize: 8, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TrenAsesmenChart extends StatelessWidget {
  const TrenAsesmenChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // black with 0.04 opacity
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          const Text(
            'Tren Asesmen Bulanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Jumlah Asesmen',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Chart Drawing (Pure Flutter visual placeholder)
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('2.500', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('2.000', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('1.500', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('1.000', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('500', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 8),

                // Chart Bars Area
                Expanded(
                  child: Stack(
                    children: [
                      // Grid Lines (Horizontal Background Lines)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
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
                        children: const [
                          ChartBarItem(
                            valueText: '1.600',
                            heightPercentage: 0.64, // 1600 / 2500
                            label: 'Minggu 1',
                            subLabel: '(1 - 4 Mei)',
                          ),
                          ChartBarItem(
                            valueText: '1.850',
                            heightPercentage: 0.74, // 1850 / 2500
                            label: 'Minggu 2',
                            subLabel: '(5 - 11 Mei)',
                          ),
                          ChartBarItem(
                            valueText: '2.050',
                            heightPercentage: 0.82, // 2050 / 2500
                            label: 'Minggu 3',
                            subLabel: '(12 - 18 Mei)',
                          ),
                          ChartBarItem(
                            valueText: '2.545',
                            heightPercentage: 1.0, // 2545 / 2500 (capped/full)
                            label: 'Minggu 4',
                            subLabel: '(19 - 31 Mei)',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartBarItem extends StatelessWidget {
  final String valueText;
  final double heightPercentage;
  final String label;
  final String subLabel;

  const ChartBarItem({
    super.key,
    required this.valueText,
    required this.heightPercentage,
    required this.label,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Value text on top of the bar
            Text(
              valueText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C6C9C),
              ),
            ),
            const SizedBox(height: 6),
            // The Bar itself
            Expanded(
              flex: (heightPercentage * 100).toInt(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4FA8E8),
                      Color(0xFF2C6C9C),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),
            ),
            // Expanded space at the bottom to balance structure
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subLabel,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

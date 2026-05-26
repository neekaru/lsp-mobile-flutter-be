import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../helpers/number_format_helper.dart';

class TrenAsesmenChart extends StatefulWidget {
  const TrenAsesmenChart({super.key});

  @override
  State<TrenAsesmenChart> createState() => _TrenAsesmenChartState();
}

class _TrenAsesmenChartState extends State<TrenAsesmenChart> {
  late Future<List<MonthlyAssessment>> _chartFuture;

  @override
  void initState() {
    super.initState();
    _chartFuture = ApiService.getMonthlyAssessments();
  }

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
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          FutureBuilder<List<MonthlyAssessment>>(
            future: _chartFuture,
            builder: (context, snapshot) {
              final isSearching =
                  snapshot.connectionState == ConnectionState.waiting;
              final data = snapshot.data ?? [];

              // Calculate dynamic Y-axis scale based on maximum data value
              int maxVal = 2500;
              if (data.isNotEmpty) {
                int dataMax = data.map((e) => e.total).reduce(max);
                if (dataMax > 0) {
                  maxVal =
                      ((dataMax + 499) ~/ 500) *
                      500; // Round up to next 500 for clean steps
                }
              }

              final yAxisLabels = [
                NumberFormatHelper.formatWithDots(maxVal),
                NumberFormatHelper.formatWithDots((maxVal * 0.8).toInt()),
                NumberFormatHelper.formatWithDots((maxVal * 0.6).toInt()),
                NumberFormatHelper.formatWithDots((maxVal * 0.4).toInt()),
                NumberFormatHelper.formatWithDots((maxVal * 0.2).toInt()),
                '0',
              ];

              return SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Y-Axis Labels
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: yAxisLabels
                          .map(
                            (label) => Text(
                              label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          .toList(),
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
                          if (isSearching)
                            const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF2C6C9C),
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: data.map((item) {
                                // Calculate height factor against rounded maxVal
                                double percentage = item.total / maxVal;
                                if (percentage > 1.0) percentage = 1.0;
                                if (percentage < 0.0) percentage = 0.0;

                                // Format label
                                final labelParts = item.label.split(' ');
                                final displayLabel =
                                    labelParts.first; // e.g. "Mei"
                                final displaySub = labelParts.length > 1
                                    ? '(${labelParts[1]})'
                                    : ''; // e.g. "(2026)"

                                return ChartBarItem(
                                  valueText: NumberFormatHelper.formatWithDots(item.total),
                                  heightPercentage: percentage,
                                  label: displayLabel,
                                  subLabel: displaySub,
                                  isCurrentMonth: item.isCurrentMonth,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
  final bool isCurrentMonth;

  const ChartBarItem({
    super.key,
    required this.valueText,
    required this.heightPercentage,
    required this.label,
    required this.subLabel,
    this.isCurrentMonth = false,
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
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCurrentMonth ? const Color(0xFFFF9800) : const Color(0xFF2C6C9C),
              ),
            ),
            const SizedBox(height: 6),
            // The Bar itself with dynamic fractional height scaling
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: heightPercentage,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isCurrentMonth 
                          ? [const Color(0xFFFFB74D), const Color(0xFFFF9800)]
                          : [const Color(0xFF4FA8E8), const Color(0xFF2C6C9C)],
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
            // Spacing at the bottom
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isCurrentMonth) ...[
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.access_time,
                    size: 10,
                    color: Color(0xFFFF9800),
                  ),
                ],
              ],
            ),
            Text(
              subLabel,
              style: const TextStyle(fontSize: 8, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

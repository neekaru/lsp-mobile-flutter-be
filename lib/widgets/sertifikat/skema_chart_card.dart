import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/sertifikat_models.dart';

class SkemaChartCard extends StatelessWidget {
  final List<SertifikatDistribusi> distribusiData;
  final String? periode;

  const SkemaChartCard({
    super.key,
    required this.distribusiData,
    this.periode,
  });

  String _getCurrentMonthYear() {
    if (periode != null && periode!.isNotEmpty) {
      return periode!;
    }
    
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total dari data secara dinamis
    final int totalCount = distribusiData.fold(0, (sum, item) => sum + item.totalPemegang);
    
    // Format ribuan (misal: 3960 menjadi 3.960)
    String formatNumber(int number) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }
    
    final String formattedTotal = formatNumber(totalCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Pemegang Sertifikat Perskema (Top 10 Skema)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Berdasarkan Jumlah Pemegang Sertifikat',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCurrentMonthYear(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Donut Chart and Legend Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Chart Container
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Use RepaintBoundary for GPU acceleration
                    RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(140, 140),
                        painter: DonutChartPainter(distribusiData),
                        isComplex: true,
                        willChange: false,
                      ),
                    ),
                    // Inner Circle Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedTotal,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3C9E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pemegang\nSertifikat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 7.5,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Legend Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: distribusiData.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(int.parse('FF${item.color}', radix: 16)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.skema,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 12),

          // Footer Row
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Data diambil per ${_getCurrentMonthYear()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk Donut Chart
class DonutChartPainter extends CustomPainter {
  final List<SertifikatDistribusi> data;

  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2; // Start from top

    // Pre-calculate common values
    final strokeWidth = radius - innerRadius;
    final arcRadius = (radius + innerRadius) / 2;

    for (var item in data) {
      final sweepAngle = (item.persentase / 100) * 2 * math.pi;
      
      // Reuse paint object with different colors
      final paint = Paint()
        ..color = Color(int.parse('FF${item.color}', radix: 16))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = true; // Enable anti-aliasing for smooth edges

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Draw segment percentage text inside donut segments
      if (item.persentase > 5) {
        final textAngle = startAngle + sweepAngle / 2;
        final textX = center.dx + arcRadius * math.cos(textAngle);
        final textY = center.dy + arcRadius * math.sin(textAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${item.persentase.toStringAsFixed(1).replaceAll('.', ',')}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    // Repaint if data changes
    if (oldDelegate.data.length != data.length) return true;
    
    for (int i = 0; i < data.length; i++) {
      if (oldDelegate.data[i].idSkema != data[i].idSkema ||
          oldDelegate.data[i].totalPemegang != data[i].totalPemegang ||
          oldDelegate.data[i].persentase != data[i].persentase) {
        return true;
      }
    }
    
    return false;
  }

  @override
  bool shouldRebuildSemantics(DonutChartPainter oldDelegate) => false;
}

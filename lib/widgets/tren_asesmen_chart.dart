import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../helpers/number_format_helper.dart';

class TrenAsesmenChart extends StatefulWidget {
  final List<MonthlyAssessment>? data;
  final bool? isLoading;

  const TrenAsesmenChart({super.key, this.data, this.isLoading});

  @override
  State<TrenAsesmenChart> createState() => _TrenAsesmenChartState();
}

class _TrenAsesmenChartState extends State<TrenAsesmenChart> {
  late Future<List<MonthlyAssessment>>? _chartFuture;
  int _selectedMonths = 12; // Default 12 months
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Hanya fetch jika data tidak disediakan dari parent
    if (widget.data == null) {
      _loadData();
    } else {
      _chartFuture = null;
    }
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
      _chartFuture = ApiService.getAssessmentGraph(months: _selectedMonths);
    });
    
    _chartFuture!.then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onMonthsChanged(int? newMonths) {
    if (newMonths != null && newMonths != _selectedMonths) {
      setState(() {
        _selectedMonths = newMonths;
      });
      _loadData();
    }
  }

  @override
  void didUpdateWidget(TrenAsesmenChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update ketika data dari parent berubah
    if (widget.data != oldWidget.data) {
      setState(() {
        _chartFuture = null;
      });
    }
  }

  /// Filter data untuk N bulan terakhir (historical data)
  /// Contoh: Sekarang Juni 2026, selectedMonths=6
  /// Return: Jan 2026, Feb 2026, Mar 2026, Apr 2026, Mei 2026, Juni 2026
  List<MonthlyAssessment> _filterRollingMonths(List<MonthlyAssessment> data, int selectedMonths) {
    if (data.isEmpty) return data;
    
    final now = DateTime.now();
    final currentYearMonth = now.year * 12 + now.month;
    
    // Filter: ambil N bulan terakhir (past months) sampai bulan sekarang
    return data.where((item) {
      // Parse label format: "Mei 2026" atau "Mei (2026)"
      final labelParts = item.label.replaceAll('(', '').replaceAll(')', '').split(' ');
      if (labelParts.length < 2) return false;
      
      final monthName = labelParts[0];
      final year = int.tryParse(labelParts[1]);
      if (year == null) return false;
      
      // Map nama bulan ke angka
      final monthMap = {
        'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
        'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
        'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      
      final month = monthMap[monthName];
      if (month == null) return false;
      
      final itemYearMonth = year * 12 + month;
      
      // Include jika dalam range: currentMonth - selectedMonths < item <= currentMonth
      return itemYearMonth > currentYearMonth - selectedMonths && 
             itemYearMonth <= currentYearMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan data dari parent jika ada
    if (widget.data != null) {
      return _buildContent(widget.data!, widget.isLoading ?? false);
    }

    // Fallback: Gunakan FutureBuilder jika standalone
    return FutureBuilder<List<MonthlyAssessment>>(
      future: _chartFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? [];
        return _buildContent(data, isLoading);
      },
    );
  }

  Widget _buildContent(List<MonthlyAssessment> data, bool isLoading) {
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
          // Card Title with Filter Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grafik Asesmen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Jumlah Asesmen',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              // Filter Dropdown
              if (widget.data == null) // Only show filter if not using parent data
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE9ECF0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMonths,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      items: const [
                        DropdownMenuItem(value: 6, child: Text('6 Bulan')),
                        DropdownMenuItem(value: 12, child: Text('12 Bulan')),
                        DropdownMenuItem(value: 18, child: Text('18 Bulan')),
                        DropdownMenuItem(value: 24, child: Text('24 Bulan')),
                      ],
                      onChanged: _onMonthsChanged,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          _buildChart(data, isLoading || _isLoading),
        ],
      ),
    );
  }

  Widget _buildChart(List<MonthlyAssessment> data, bool isLoading) {
    // Filter data: hanya ambil N bulan ke depan dari bulan sekarang (rolling window)
    List<MonthlyAssessment> filteredData = _filterRollingMonths(data, _selectedMonths);
    
    // Calculate dynamic Y-axis scale based on maximum data value
    int maxVal = 2500;
    if (filteredData.isNotEmpty) {
      int dataMax = filteredData.map((e) => e.total).reduce(max);
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
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                    return Container(height: 1, color: const Color(0xFFF1F3F5));
                  }),
                ),

                // Bars
                if (isLoading)
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
                    children: filteredData.map((item) {
                      // Calculate height factor against rounded maxVal
                      double percentage = item.total / maxVal;
                      if (percentage > 1.0) percentage = 1.0;
                      if (percentage < 0.0) percentage = 0.0;

                      // Format label
                      final labelParts = item.label.split(' ');
                      final displayLabel = labelParts.first; // e.g. "Mei"
                      final displaySub = labelParts.length > 1
                          ? '(${labelParts[1]})'
                          : ''; // e.g. "(2026)"

                      return ChartBarItem(
                        valueText: NumberFormatHelper.formatWithDots(
                          item.total,
                        ),
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
                color: isCurrentMonth
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF2C6C9C),
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
                            : [
                                const Color(0xFF4FA8E8),
                                const Color(0xFF2C6C9C),
                              ],
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

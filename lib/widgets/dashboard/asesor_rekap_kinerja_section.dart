import 'package:flutter/material.dart';
import '../../models/asesor_statistik_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../utils/date_format_helper.dart';

class AsesorRekapKinerjaSection extends StatefulWidget {
  final int tahun;
  final AsesorStatistikData? initialData;

  const AsesorRekapKinerjaSection({
    super.key,
    this.tahun = 2026,
    this.initialData,
  });

  @override
  State<AsesorRekapKinerjaSection> createState() =>
      _AsesorRekapKinerjaSectionState();
}

class _AsesorRekapKinerjaSectionState extends State<AsesorRekapKinerjaSection> {
  bool _isLoading = false;
  AsesorStatistikData? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    if (_data == null) {
      _fetchStatistik();
    }
  }

  @override
  void didUpdateWidget(covariant AsesorRekapKinerjaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != null && widget.initialData != oldWidget.initialData) {
      setState(() => _data = widget.initialData);
    }
  }

  Future<void> _fetchStatistik() async {
    setState(() => _isLoading = true);
    final res = await AsesorService.getAsesorStatistikBulanan(tahun: widget.tahun);
    if (!mounted) return;
    setState(() {
      _data = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _data == null) {
      return Container(
        width: double.infinity,
        height: 180,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3B82F6),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final data = _data ?? AsesorStatistikData.empty(tahun: widget.tahun);
    final isAktif = data.statusMasaBerlaku.toLowerCase() == 'aktif';
    final statusColor = isAktif ? const Color(0xFF10B981) : const Color(0xFFD97706);
    final statusBgColor = isAktif ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekap Kinerja Asesor ${data.tahun}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.namaAsesor.isNotEmpty
                          ? data.namaAsesor
                          : 'SPT & Asesi Bulanan',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.statusMasaBerlaku,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          if (data.tglExpired != null && data.tglExpired!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  'Masa Berlaku s/d: ${DateFormatHelper.formatToIndonesian(data.tglExpired!)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // 2. KPI Total Surat Tugas & Total Asesi Diuji
          Row(
            children: [
              Expanded(
                child: _buildKpiTile(
                  label: 'Total Surat Tugas',
                  value: '${data.totalSpt} SPT',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildKpiTile(
                  label: 'Total Asesi Diuji',
                  value: '${data.totalAsesi} Asesi',
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFF0D9488),
                  bgColor: const Color(0xFFF0FDFA),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Section Title Bulanan
          Row(
            children: [
              Text(
                'Rincian Bulanan (${data.tahun})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              const Text(
                'SPT | Asesi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 4. Grid of 12 Months
          _buildMonthlyGrid(data.bulanan),
        ],
      ),
    );
  }

  Widget _buildKpiTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyGrid(List<AsesorStatistikBulanItem> items) {
    const monthLabels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    // Fallback mapping if list is sparse
    final Map<int, AsesorStatistikBulanItem> monthMap = {};
    for (var item in items) {
      monthMap[item.month] = item;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.65,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthNum = index + 1;
        final item = monthMap[monthNum];
        final sptCount = item?.jumlahSpt ?? 0;
        final asesiCount = item?.jumlahAsesi ?? 0;
        final hasActivity = sptCount > 0 || asesiCount > 0;

        return Container(
          decoration: BoxDecoration(
            color: hasActivity ? const Color(0xFFF8FAFC) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasActivity
                  ? const Color(0xFF93C5FD)
                  : const Color(0xFFE2E8F0),
              width: hasActivity ? 1.2 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthLabels[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hasActivity
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF64748B),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SPT Count
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 11,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$sptCount',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: hasActivity
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  // Asesi Count
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 11,
                        color: Color(0xFF0D9488),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$asesiCount',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: hasActivity
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

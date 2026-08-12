import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../utils/number_format_helper.dart';
import '../../screens/statistik/distribusi_asesor_sertifikasi_screen.dart';

class AdminKpiRow extends StatelessWidget {
  final AsesorStats stats;
  final StatistikOverview overview;

  const AdminKpiRow({
    super.key,
    required this.stats,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildTotalAsesorCard(context, stats)),
          const SizedBox(width: 8),
          Expanded(child: _buildJumlahAsesiCard(overview)),
          const SizedBox(width: 8),
          Expanded(child: _buildTotalTukCard(stats)),
        ],
      ),
    );
  }

  Widget _buildTotalAsesorCard(BuildContext context, AsesorStats stats) {
    final String valStr = NumberFormatHelper.formatWithDots(stats.totalAsesor);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DistribusiAsesorSertifikasiScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x03000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Total Asesor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F4C81),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    valStr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Terdaftar',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Internal',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Eksternal',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: stats.asesorInternal > 0
                          ? stats.asesorInternal
                          : 75,
                      child: Container(color: const Color(0xFF3B82F6)),
                    ),
                    Expanded(
                      flex: stats.asesorExternal > 0
                          ? stats.asesorExternal
                          : 25,
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJumlahAsesiCard(StatistikOverview overview) {
    final String valStr = NumberFormatHelper.formatWithDots(
      overview.totalAsesi,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAD2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Jumlah Asesi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C81),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valStr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Terdaftar',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTukCard(AsesorStats stats) {
    final String valStr = NumberFormatHelper.formatWithDots(stats.totalTuk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.domain,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Total TUK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valStr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Tempat Uji Kompetensi',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
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

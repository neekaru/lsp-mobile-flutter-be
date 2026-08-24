import 'package:material_ui/material_ui.dart';
import '../../screens/jadwal/jadwal_screen.dart';
import '../../models/dashboard_models.dart';
import '../../utils/date_format_helper.dart';
import 'asesor_dashboard_cards.dart';

class RangkumanAsesor extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onNavigateToJadwal;
  final AsesorDashboardData? data;

  const RangkumanAsesor({
    super.key,
    this.isLoading = false,
    this.onNavigateToJadwal,
    this.data,
  });

  @override
  State<RangkumanAsesor> createState() => _RangkumanAsesorState();
}

class _RangkumanAsesorState extends State<RangkumanAsesor> {
  void _openJadwalScreen() {
    if (widget.onNavigateToJadwal != null) {
      widget.onNavigateToJadwal!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const JadwalScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final stat = widget.data?.statistikBulanan;
    final tglExp = stat?.tglExpired;
    final formattedExp = (tglExp != null && tglExp.isNotEmpty)
        ? DateFormatHelper.formatToIndonesian(tglExp)
        : (stat?.statusMasaBerlaku ?? 'Aktif');

    final totalSpt = stat?.totalSpt ?? 0;
    final isKompeten = totalSpt >= 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. "Dashboard Asesor" Overlapping Card (Design matches RangkumanUtama)
        AsesorDashboardHeaderCard(
          formattedExp: formattedExp,
          isKompeten: isKompeten,
          totalSpt: totalSpt,
          data: widget.data,
          onTapSpt: _openJadwalScreen,
          onTapMuk: () {
            showAsesorStatDetailDialog(
              context: context,
              title: 'Jumlah MUK 2026',
              count: widget.data?.summary.jumlahMuk2026 ?? 0,
              unit: 'Perangkat',
              description:
                  'Total perangkat MUK / MAPA yang dikembangkan atau ditugaskan kepada Anda pada tahun 2026.',
              icon: Icons.menu_book_rounded,
              iconColor: const Color(0xFFF59E0B),
              iconBgColor: const Color(0xFFFEF3C7),
            );
          },
          onTapMitra: () {
            showAsesorStatDetailDialog(
              context: context,
              title: 'Jumlah Mitra',
              count: widget.data?.summary.jumlahMitra ?? 0,
              unit: 'Mitra',
              description:
                  'Total mitra kerja sama asosiasi, instansi, atau TUK terkait penugasan asesmen Anda.',
              icon: Icons.handshake_rounded,
              iconColor: const Color(0xFF10B981),
              iconBgColor: const Color(0xFFECFDF5),
            );
          },
        ),
        const SizedBox(height: 28),

        // 2. Jadwal Asesmen Hari Ini Section Header
        AsesorSectionHeader(
          title: 'Jadwal Asesmen Hari Ini',
          onTapLihatSemua: _openJadwalScreen,
        ),
        const SizedBox(height: 12),

        // Jadwal Hari Ini Cards
        if (widget.data == null || widget.data!.jadwalHariIni.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded, color: Color(0xFF94A3B8), size: 36),
                SizedBox(height: 8),
                Text(
                  'Tidak ada jadwal asesmen hari ini',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: widget.data!.jadwalHariIni
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AsesorJadwalHariIniCard(item: item),
                    ))
                .toList(),
          ),
        const SizedBox(height: 28),

        // 3. Jadwal Belum Lengkap Section Header
        AsesorSectionHeader(
          title: 'Jadwal Belum Lengkap',
          onTapLihatSemua: _openJadwalScreen,
        ),
        const SizedBox(height: 12),

        // Jadwal Belum Lengkap List
        if (widget.data == null || widget.data!.jadwalBelumLengkap.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF94A3B8), size: 36),
                SizedBox(height: 8),
                Text(
                  'Tidak ada jadwal yang belum lengkap',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: widget.data!.jadwalBelumLengkap
                .map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AsesorJadwalBelumLengkapCard(task: task),
                    ))
                .toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

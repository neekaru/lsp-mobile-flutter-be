import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/dashboard_models.dart';

class AdminRingkasanScreen extends StatelessWidget {
  final DashboardSummary? summaryData;
  final VoidCallback? onNavigateToJadwal;

  const AdminRingkasanScreen({
    super.key,
    this.summaryData,
    this.onNavigateToJadwal,
  });

  @override
  Widget build(BuildContext context) {
    final approveJadwalCount = summaryData?.jadwalBelumTerkonfirmasi ?? 0;
    final laporanCount = summaryData?.suratTugasMenungguPengiriman ?? 0;
    final pendaftaranCount = summaryData?.pendaftaranAsesiBaru ?? 0;
    final honorCount = summaryData?.honorAsesorBelumDibayar ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Ringkasan',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildRingkasanItem(
                    context: context,
                    icon: Icons.calendar_today_rounded,
                    title: 'Approve Jadwal',
                    subtitle: '$approveJadwalCount Jadwal menunggu...',
                    onTap: () {
                      Navigator.pop(context); // Go back to dashboard first
                      if (onNavigateToJadwal != null) {
                        onNavigateToJadwal!();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildRingkasanItem(
                    context: context,
                    icon: Icons.assignment_rounded,
                    title: 'Laporan',
                    subtitle: '$laporanCount Laporan menunggu...',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Halaman Laporan Admin sedang dikembangkan'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildRingkasanItem(
                    context: context,
                    icon: Icons.assignment_ind_rounded,
                    title: 'Pendaftaran',
                    subtitle: '$pendaftaranCount Pendaftaran asessi baru',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Halaman Pendaftaran Admin sedang dikembangkan'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildRingkasanItem(
                    context: context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Honor',
                    subtitle: '$honorCount Honor asesor belum dibayar',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Halaman Honor Admin sedang dikembangkan'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/dashboard/asesor_rekap_kinerja_section.dart';

class StatistikAsesorScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const StatistikAsesorScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<StatistikAsesorScreen> createState() => _StatistikAsesorScreenState();
}

class _StatistikAsesorScreenState extends State<StatistikAsesorScreen> {
  int _selectedYear = 2026;
  final List<int> _availableYears = [2026, 2025, 2024];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Statistik Asesor',
            onBack: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Tahun
                    _buildYearFilter(),
                    const SizedBox(height: 12),

                    // 1. Rekap Kinerja Asesor (SPT & Asesi Bulanan)
                    AsesorRekapKinerjaSection(
                      key: ValueKey('rekap_$_selectedYear'),
                      tahun: _selectedYear,
                    ),
                    const SizedBox(height: 20),

                    // 2. Section Header: Menu Statistik Asesor
                    const Text(
                      'Menu Statistik Asesor',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pantau kepatuhan administrasi dan hak profesional Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Menu 1: Kepatuhan Pelaporan
                    _buildMenuCard(
                      title: 'Kepatuhan Pelaporan',
                      subtitle:
                          'Monitoring ketepatan waktu pengiriman laporan hasil asesmen & berita acara.',
                      badgeText: 'Tertib & Patuh',
                      badgeBgColor: const Color(0xFFEFF6FF),
                      badgeTextColor: const Color(0xFF2563EB),
                      icon: Icons.fact_check_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFDBEAFE),
                      onTap: () => _showKepatuhanDetailDialog(context),
                    ),
                    const SizedBox(height: 12),

                    // Menu 2: Distribusi Honor
                    _buildMenuCard(
                      title: 'Distribusi Honor',
                      subtitle:
                          'Rekapitulasi dan transparansi verifikasi serta pencairan honor penugasan.',
                      badgeText: 'Transparan',
                      badgeBgColor: const Color(0xFFECFDF5),
                      badgeTextColor: const Color(0xFF059669),
                      icon: Icons.payments_rounded,
                      iconColor: const Color(0xFF059669),
                      iconBgColor: const Color(0xFFD1FAE5),
                      onTap: () => _showHonorDetailDialog(context),
                    ),
                    const SizedBox(height: 12),

                    // Menu 3: Pemeliharaan Kompetensi (RCC)
                    _buildMenuCard(
                      title: 'Pemeliharaan Kompetensi (RCC)',
                      subtitle:
                          'Riwayat pemenuhan syarat minimal 6 penugasan SPT untuk proses perpanjangan masa berlaku sertifikat asesor.',
                      badgeText: 'Memenuhi Syarat',
                      badgeBgColor: const Color(0xFFF5F3FF),
                      badgeTextColor: const Color(0xFF7C3AED),
                      icon: Icons.verified_user_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBgColor: const Color(0xFFEDE9FE),
                      onTap: () => _showRccDetailDialog(context),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text(
                'Periode Tahun',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          Row(
            children: _availableYears.map((year) {
              final isSelected = _selectedYear == year;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: InkWell(
                  onTap: () {
                    if (_selectedYear != year) {
                      setState(() => _selectedYear = year);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF3F8CFF) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKepatuhanDetailDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.fact_check_rounded, color: Color(0xFF2563EB), size: 28),
                SizedBox(width: 12),
                Text(
                  'Kepatuhan Pelaporan Asesor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Menu Kepatuhan Pelaporan memantau ketepatan waktu asesor dalam mengunggah Berita Acara, Lembar Penilaian, dan Laporan Hasil Asesmen maksimal H+2 setelah jadwal berakhir.',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHonorDetailDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.payments_rounded, color: Color(0xFF059669), size: 28),
                SizedBox(width: 12),
                Text(
                  'Distribusi Honor Asesor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Menu Distribusi Honor menampilkan rincian honorarium pelaksanaan asesmen berdasarkan SPT yang telah selesai dilaporkan dan diverifikasi oleh manajemen LSP.',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRccDetailDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF7C3AED), size: 28),
                SizedBox(width: 12),
                Text(
                  'Pemeliharaan Kompetensi (RCC)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Sesuai ketentuan BNSP, Asesor Kompetensi wajib menguji minimal 6 kali penugasan (SPT) dalam 3 tahun masa berlaku sertifikat untuk dapat mengajukan Recognition of Current Competency (RCC).',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

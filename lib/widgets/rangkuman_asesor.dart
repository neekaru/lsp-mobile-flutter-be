import 'package:flutter/material.dart';
import '../screens/jadwal/jadwal_screen.dart';
import '../screens/jadwal/jadwal_detail_screen.dart';
import '../models/dashboard_models.dart';
import '../models/jadwal_models.dart';
import '../services/auth_repository.dart';

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
  final String _selectedDate = '20 April';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. "Tugas Hari Ini" Overlapping Card (Design matches RangkumanUtama)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF559AD4), Color(0xFF2C6C9C)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000), // black with 0.15 opacity
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Date dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tugas Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  // Dropdown pill
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0x99FFFFFF), // white with 0.6 opacity
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Pantau dan selesaikan tugas asessmen Anda',
                style: TextStyle(
                  color: Color(0xB3FFFFFF), // white with 0.7 opacity
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              // Alert banner inside card
              if (widget.data?.alertBanner.hasAlert == true) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD97706),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: Color(0xFFFBBF24),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.data!.alertBanner.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.data!.alertBanner.subtitle,
                              style: const TextStyle(
                                color: Color(0xE0FFFFFF),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Row of 3 Category Cards
              SizedBox(
                height: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        title: 'Menunggu Verifikasi',
                        count: (widget.data?.summary.menungguVerifikasi ?? 0).toString(),
                        icon: Icons.access_time_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        iconBgColor: const Color(0xFFFEF3C7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCategoryCard(
                        title: 'Asessmen Berlangsung',
                        count: (widget.data?.summary.asesmenBerlangsung ?? 0).toString(),
                        icon: Icons.assignment_rounded,
                        iconColor: const Color(0xFF3F8CFF),
                        iconBgColor: const Color(0xFFF0F5FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCategoryCard(
                        title: 'Asessmen Selesai',
                        count: (widget.data?.summary.asesmenSelesai ?? 0).toString(),
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFECFDF5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 2. Jadwal Asessmen Hari Ini Section Header
        _buildSectionHeader(
          title: 'Jadwal Asessmen Hari Ini',
          onTapLihatSemua: () {
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
          },
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
                      child: _buildJadwalHariIniCard(item),
                    ))
                .toList(),
          ),
        const SizedBox(height: 28),

        // 3. Tugas Prioritas Section Header
        _buildSectionHeader(
          title: 'Tugas Prioritas',
          onTapLihatSemua: () {},
        ),
        const SizedBox(height: 12),

        // Tugas Prioritas List
        if (widget.data == null || widget.data!.tugasPrioritas.isEmpty)
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
                  'Tidak ada tugas prioritas saat ini',
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: widget.data!.tugasPrioritas.length,
              itemBuilder: (context, index) {
                final task = widget.data!.tugasPrioritas[index];
                IconData icon = Icons.assignment_rounded;
                Color iconColor = const Color(0xFF3FA8F8);
                Color iconBgColor = const Color(0xFFE8F5FF);

                switch (task.type) {
                  case 'menunggu_verifikasi':
                    icon = Icons.access_time_rounded;
                    iconColor = const Color(0xFFF59E0B);
                    iconBgColor = const Color(0xFFFEF3C7);
                    break;
                  case 'penugasan_baru':
                    icon = Icons.assignment_rounded;
                    iconColor = const Color(0xFF3FA8F8);
                    iconBgColor = const Color(0xFFE8F5FF);
                    break;
                  case 'asesmen_berlangsung':
                    icon = Icons.play_circle_outline_rounded;
                    iconColor = const Color(0xFF3F8CFF);
                    iconBgColor = const Color(0xFFF0F5FF);
                    break;
                  case 'asesmen_selesai':
                    icon = Icons.check_circle_rounded;
                    iconColor = const Color(0xFF10B981);
                    iconBgColor = const Color(0xFFECFDF5);
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPriorityTaskCard(
                    title: task.title,
                    subtitle: task.subtitle,
                    icon: icon,
                    iconColor: iconColor,
                    iconBgColor: iconBgColor,
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onTapLihatSemua,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: onTapLihatSemua,
          borderRadius: BorderRadius.circular(4),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lihat semua',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF2563EB),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalHariIniCard(AsesorDashboardJadwal item) {
    String statusLabel = 'waiting';
    Color statusColor = const Color(0xFFEA580C);
    Color statusBgColor = const Color(0xFFFFEDD5);

    switch (item.status) {
      case '0':
        statusLabel = 'waiting';
        statusColor = const Color(0xFFEA580C);
        statusBgColor = const Color(0xFFFFEDD5);
        break;
      case '1':
        statusLabel = 'completed';
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFECFDF5);
        break;
      case '2':
        statusLabel = 'canceled';
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      case '3':
        statusLabel = 'running';
        statusColor = const Color(0xFF3F8CFF);
        statusBgColor = const Color(0xFFF0F5FF);
        break;
      case '4':
        statusLabel = 'pelaporan';
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
    }

    return InkWell(
      onTap: () {
        final user = AuthRepository.currentUserInstance;
        final userRole = UserRole(
          role: user?.role ?? 'asesor',
          name: user?.name ?? '',
          email: user?.email ?? '',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JadwalDetailScreen(
              jadwal: item.toJadwalItem(),
              userRole: userRole,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF3F8CFF),
                    size: 40,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Color(0xFF3F8CFF),
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Asesmen Mandiri',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Skema : ${item.skema}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.waktu,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.tuk,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityTaskCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
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

  Widget _buildCategoryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Box
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          // Texts
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                'Asessmen',
                style: TextStyle(
                  color: Color(0xFF0D9488),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

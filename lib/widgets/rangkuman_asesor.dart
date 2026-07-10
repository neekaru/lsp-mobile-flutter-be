import 'package:flutter/material.dart';
import '../screens/jadwal/jadwal_screen.dart';

class RangkumanAsesor extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onNavigateToJadwal;

  const RangkumanAsesor({
    super.key,
    this.isLoading = false,
    this.onNavigateToJadwal,
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD97706),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Color(0xFFFBBF24),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verivikasi Laporan Anda Tertunda',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Anda memiliki 2 laporan yang menunggu verifikasi',
                            style: TextStyle(
                              color: Color(0xE0FFFFFF),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFFBBF24),
                      size: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 2. Grid of category cards using Rows for fixed height to prevent stretching
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: _buildCategoryCard(
                            title: 'Menunggu Penugasan',
                            count: '3',
                            icon: Icons.calendar_month_rounded,
                            iconColor: const Color(0xFF3FA8F8),
                            iconBgColor: const Color(0xFFE8F5FF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: _buildCategoryCard(
                            title: 'Asessmen Berlangsung',
                            count: '1',
                            icon: Icons.assignment_rounded,
                            iconColor: const Color(0xFF3F8CFF),
                            iconBgColor: const Color(0xFFF0F5FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: _buildCategoryCard(
                            title: 'Menunggu Verifikasi',
                            count: '3',
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            iconBgColor: const Color(0xFFFEF3C7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: _buildCategoryCard(
                            title: 'Asessmen Selesai',
                            count: '2',
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFF10B981),
                            iconBgColor: const Color(0xFFECFDF5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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

        // Jadwal Hari Ini Card
        _buildJadwalHariIniCard(),
        const SizedBox(height: 28),

        // 3. Tugas Prioritas Section Header
        _buildSectionHeader(
          title: 'Tugas Prioritas',
          onTapLihatSemua: () {},
        ),
        const SizedBox(height: 12),

        // Tugas Prioritas List
        _buildPriorityTaskCard(
          title: 'Penugasan Asessmen baru',
          subtitle: 'Skema Diigital Marketing - TUK Digital Marketing',
          icon: Icons.assignment_rounded,
          iconColor: const Color(0xFF3FA8F8),
          iconBgColor: const Color(0xFFE8F5FF),
        ),
        const SizedBox(height: 10),
        _buildPriorityTaskCard(
          title: 'Asessmen Selesai',
          subtitle: 'Skema UI/UX Designer - TUK LPP Sampit',
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF10B981),
          iconBgColor: const Color(0xFFECFDF5),
        ),
        const SizedBox(height: 10),
        _buildPriorityTaskCard(
          title: 'Laporan Menunggu Verifikasi',
          subtitle: 'Skema Ilmuan Big Data - TUK LPP Sampit',
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFFF59E0B),
          iconBgColor: const Color(0xFFFEF3C7),
        ),
        const SizedBox(height: 10),
        _buildPriorityTaskCard(
          title: 'Rekam Vidio Pengajar',
          subtitle: 'Skema Digital Marketing - TUK LPP Digital Marketing',
          icon: Icons.play_circle_outline_rounded,
          iconColor: const Color(0xFF3FA8F8),
          iconBgColor: const Color(0xFFE8F5FF),
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

  Widget _buildJadwalHariIniCard() {
    return Container(
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
          // Left side: Calendar with Pencil Icon
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
          // Center & Right: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Eko Setiabudi',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Status Badge: waiting
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5), // light orange
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'waiting',
                        style: TextStyle(
                          color: Color(0xFFEA580C), // dark orange
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Skema : Digital Marketing',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '09:00 - 12:00',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'TUK Kampus Digital',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 8),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      count,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
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
          ),
        ],
      ),
    );
  }
}

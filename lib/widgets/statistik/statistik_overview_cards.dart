import 'package:flutter/material.dart';

class StatistikOverviewCards extends StatelessWidget {
  const StatistikOverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildStatCard(
            title: 'Total Asesi',
            value: '25.890',
            subtitle: 'Telah terdaftar',
            trend: '+14.2%',
            isTrendPositive: true,
            icon: Icons.people_alt_rounded,
            iconBgColor: const Color(0xFFE5F1FC),
            iconColor: const Color(0xFF2C6C9C),
          ),
          _buildStatCard(
            title: 'Sertifikat Terbit',
            value: '21.435',
            subtitle: 'Aktif & Valid',
            trend: '+11.8%',
            isTrendPositive: true,
            icon: Icons.verified_user_rounded,
            iconBgColor: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF4CAF50),
          ),
          _buildStatCard(
            title: 'LSP Terdaftar',
            value: '145',
            subtitle: 'Lembaga Aktif',
            trend: '+4.5%',
            isTrendPositive: true,
            icon: Icons.account_balance_rounded,
            iconBgColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF9C27B0),
          ),
          _buildStatCard(
            title: 'Tingkat Kelulusan',
            value: '82.8%',
            subtitle: 'Kompeten',
            trend: '+1.2%',
            isTrendPositive: true,
            icon: Icons.school_rounded,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required String trend,
    required bool isTrendPositive,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
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
                  size: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
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

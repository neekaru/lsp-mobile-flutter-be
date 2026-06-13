import 'package:flutter/material.dart';

class MenuProfilWidget extends StatelessWidget {
  final VoidCallback? onDataDiriTap;
  final VoidCallback? onInstansiTap;
  final VoidCallback? onKeamananTap;
  final VoidCallback? onSertifikasiTap;
  final VoidCallback? onKeluarTap;

  const MenuProfilWidget({
    super.key,
    this.onDataDiriTap,
    this.onInstansiTap,
    this.onKeamananTap,
    this.onSertifikasiTap,
    this.onKeluarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.person_rounded,
                title: 'Data Diri',
                iconColor: const Color(0xFF378CE7),
                onTap: onDataDiriTap,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                icon: Icons.apartment_rounded,
                title: 'Instansi / Lembaga',
                iconColor: const Color(0xFF378CE7),
                onTap: onInstansiTap,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                icon: Icons.shield_rounded,
                title: 'Keamanan',
                iconColor: const Color(0xFF378CE7),
                onTap: onKeamananTap,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                icon: Icons.stars_rounded,
                title: 'Sertifikasi',
                iconColor: const Color(0xFF378CE7),
                onTap: onSertifikasiTap,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                iconColor: const Color(0xFFEF4444),
                textColor: const Color(0xFFEF4444),
                onTap: onKeluarTap,
                showChevron: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    Color textColor = const Color(0xFF1E293B),
    required VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      trailing: showChevron
          ? Icon(
              Icons.chevron_right_rounded,
              color: iconColor,
              size: 22,
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

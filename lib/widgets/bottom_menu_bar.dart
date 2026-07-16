import 'package:flutter/material.dart';
import '../services/auth_repository.dart';

class BottomMenuBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomMenuBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<BottomMenuBar> createState() => _BottomMenuBarState();
}

class _BottomMenuBarState extends State<BottomMenuBar> {
  @override
  Widget build(BuildContext context) {
    final user = AuthRepository.currentUserInstance;
    final bool isGuest = user == null;
    final bool isAsesor = !isGuest && user.role == 'asesor';
    final bool isAsesi = !isGuest && user.role == 'asesi';

    final List<Widget> menuItems = isGuest
        ? [
            _buildMenuItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Beranda',
            ),
            _buildMenuItem(
              index: 1,
              icon: Icons.newspaper_rounded,
              label: 'Berita',
            ),
            _buildMenuItem(
              index: 2,
              icon: Icons.workspace_premium_rounded,
              label: 'Sertifikat',
            ),
            _buildMenuItem(
              index: 3,
              icon: Icons.account_circle_rounded,
              label: 'Profil',
            ),
          ]
        : (isAsesor
            ? [
                _buildMenuItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  isAsesor: true,
                ),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.pending_actions_rounded,
                  label: 'Jadwal',
                  isAsesor: true,
                ),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.assignment_outlined,
                  label: 'Tugas',
                  isAsesor: true,
                ),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.description_rounded,
                  label: 'Laporan',
                  isAsesor: true,
                ),
                _buildMenuItem(
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  isAsesor: true,
                ),
              ]
            : (isAsesi
                ? [
                    _buildMenuItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Beranda',
                    ),
                    _buildMenuItem(
                      index: 1,
                      icon: Icons.calendar_month_rounded,
                      label: 'Jadwal',
                    ),
                    _buildMenuItem(
                      index: 2,
                      icon: Icons.workspace_premium_rounded,
                      label: 'Skema',
                    ),
                    _buildMenuItem(
                      index: 3,
                      icon: Icons.account_circle_rounded,
                      label: 'Profil',
                    ),
                  ]
                : [
                    _buildMenuItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Beranda',
                    ),
                    _buildMenuItem(
                      index: 1,
                      icon: Icons.bar_chart_rounded,
                      label: 'Statistik',
                    ),
                    _buildMenuItem(
                      index: 2,
                      icon: Icons.calendar_month_rounded,
                      label: 'Jadwal',
                    ),
                    _buildMenuItem(
                      index: 3,
                      icon: Icons.workspace_premium_rounded,
                      label: 'Sertifikat',
                    ),
                    _buildMenuItem(
                      index: 4,
                      icon: Icons.account_circle_rounded,
                      label: 'Profil',
                    ),
                  ]));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isAsesor ? Colors.white : const Color(0xFFE5E5E5), // White background for assessor
        border: Border(
          top: BorderSide(
            color: isAsesor ? const Color(0xFFE2E8F0) : const Color(0x339E9E9E),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: menuItems,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
    bool isAsesor = false,
  }) {
    final bool isActive = widget.selectedIndex == index;
    final Color activeColor = isAsesor ? const Color(0xFF3B82F6) : Colors.black;
    final Color inactiveColor = isAsesor ? const Color(0xFF94A3B8) : const Color(0xFF4A4A4A);
    final Color itemColor = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: () => widget.onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: itemColor,
              size: isActive ? 28 : 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: itemColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
                      icon: Icons.assignment_rounded,
                      label: 'Skema',
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
    // Brand blue for active selection (all roles)
    const Color activeColor = Color(0xFF2563EB);
    final Color inactiveColor =
        isAsesor ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color itemColor = isActive ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: activeColor.withValues(alpha: 0.12),
        highlightColor: activeColor.withValues(alpha: 0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active top indicator bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isActive ? 20 : 0,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                icon,
                color: itemColor,
                size: isActive ? 26 : 24,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: itemColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

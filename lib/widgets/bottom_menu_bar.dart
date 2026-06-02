import 'package:flutter/material.dart';

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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5), // Light grey background matching screenshot
        border: Border(
          top: BorderSide(
            color: const Color(0x339E9E9E),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
              label: 'Sertifikat', // Spelled with 'v' to match screenshot exactly
            ),
            _buildMenuItem(
              index: 4,
              icon: Icons.account_circle_rounded,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = widget.selectedIndex == index;
    final Color itemColor = isActive ? Colors.black : const Color(0xFF4A4A4A);

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

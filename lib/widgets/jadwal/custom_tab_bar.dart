import 'package:flutter/material.dart';
import '../../services/auth_repository.dart';

class JadwalTabBar extends StatefulWidget {
  final TabController controller;
  final int runningCount;
  final int pelaporanCount;
  final int selesaiCount;

  const JadwalTabBar({
    super.key,
    required this.controller,
    required this.runningCount,
    this.pelaporanCount = 0,
    this.selesaiCount = 0,
  });

  @override
  State<JadwalTabBar> createState() => _JadwalTabBarState();
}

class _JadwalTabBarState extends State<JadwalTabBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTabSelection);
  }

  @override
  void didUpdateWidget(covariant JadwalTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTabSelection);
      widget.controller.addListener(_handleTabSelection);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabSelection);
    super.dispose();
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAsesi = AuthRepository.currentUserInstance?.role == 'asesi';

    return Row(
      children: [
        Expanded(
          child: TabItem(
            label: isAsesi ? 'Mendatang' : 'Running',
            badgeCount: widget.runningCount,
            isSelected: widget.controller.index == 0,
            onTap: () => widget.controller.animateTo(0),
            isAsesi: isAsesi,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TabItem(
            label: isAsesi ? 'Berjalan' : 'Pelaporan',
            badgeCount: isAsesi ? widget.pelaporanCount : null,
            isSelected: widget.controller.index == 1,
            onTap: () => widget.controller.animateTo(1),
            isAsesi: isAsesi,
          ),
        ),
        if (!isAsesi) ...[
          const SizedBox(width: 8),
          Expanded(
            child: TabItem(
              label: 'Selesai',
              badgeCount: null,
              isSelected: widget.controller.index == 2,
              onTap: () => widget.controller.animateTo(2),
              isAsesi: isAsesi,
            ),
          ),
        ],
      ],
    );
  }
}

class TabItem extends StatelessWidget {
  final String label;
  final int? badgeCount;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAsesi;

  const TabItem({
    super.key,
    required this.label,
    this.badgeCount,
    required this.isSelected,
    required this.onTap,
    this.isAsesi = false,
  });

  @override
  Widget build(BuildContext context) {
    Color containerColor;
    Color textColor;
    Color badgeBgColor;
    Color badgeTextColor;

    if (isAsesi) {
      if (isSelected) {
        containerColor = const Color(0xFF6C8BB4); // Slate blue
        textColor = Colors.white;
        badgeBgColor = Colors.white;
        badgeTextColor = const Color(0xFF6C8BB4);
      } else {
        containerColor = const Color(0xFFD2E3F4); // Very light grey-blue
        textColor = const Color(0xFF5A7EAA);
        badgeBgColor = const Color(0xFF6C8BB4);
        badgeTextColor = Colors.white;
      }
    } else {
      containerColor = isSelected ? Colors.white : const Color(0xFF758FAD);
      textColor = isSelected ? Colors.black87 : Colors.white;
      badgeBgColor = Colors.red;
      badgeTextColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected && !isAsesi
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

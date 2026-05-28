import 'package:flutter/material.dart';

class JadwalTabBar extends StatefulWidget {
  final TabController controller;
  final int akanBerakhirCount;

  const JadwalTabBar({
    super.key,
    required this.controller,
    required this.akanBerakhirCount,
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
    return Row(
      children: [
        Expanded(
          child: TabItem(
            label: 'Akan Berakhir',
            badgeCount: widget.akanBerakhirCount,
            isSelected: widget.controller.index == 0,
            onTap: () => widget.controller.animateTo(0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TabItem(
            label: 'Berjalan',
            isSelected: widget.controller.index == 1,
            onTap: () => widget.controller.animateTo(1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TabItem(
            label: 'Selesai',
            isSelected: widget.controller.index == 2,
            onTap: () => widget.controller.animateTo(2),
          ),
        ),
      ],
    );
  }
}

class TabItem extends StatelessWidget {
  final String label;
  final int? badgeCount;
  final bool isSelected;
  final VoidCallback onTap;

  const TabItem({
    super.key,
    required this.label,
    this.badgeCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF758FAD),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
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
                  color: isSelected ? Colors.black87 : Colors.white,
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
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

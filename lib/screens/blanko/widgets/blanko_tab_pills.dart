import 'package:flutter/material.dart';

class BlankoTabPills extends StatelessWidget {
  final int selectedIndex;
  final int totalCount;
  final int pendingCount;
  final int terkirimCount;
  final ValueChanged<int> onTabChanged;

  const BlankoTabPills({
    super.key,
    required this.selectedIndex,
    required this.totalCount,
    required this.pendingCount,
    required this.terkirimCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTabPill(
              label: 'Semua',
              count: totalCount,
              isSelected: selectedIndex == 0,
              showBadge: totalCount > 0,
              badgeColor: selectedIndex == 0
                  ? const Color(0xFF5A7EAA)
                  : const Color(0xFF94A3B8),
              onTap: () => onTabChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabPill(
              label: 'Pending',
              count: pendingCount,
              isSelected: selectedIndex == 1,
              showBadge: pendingCount > 0,
              badgeColor: const Color(0xFFEF4444),
              onTap: () => onTabChanged(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabPill(
              label: 'Terkirim',
              count: terkirimCount,
              isSelected: selectedIndex == 2,
              showBadge: terkirimCount > 0,
              badgeColor: const Color(0xFF10B981),
              onTap: () => onTabChanged(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required int count,
    required bool isSelected,
    required bool showBadge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    final containerColor =
        isSelected ? const Color(0xFF6C8BB4) : const Color(0xFFD2E3F4);
    final textColor = isSelected ? Colors.white : const Color(0xFF5A7EAA);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showBadge && count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
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

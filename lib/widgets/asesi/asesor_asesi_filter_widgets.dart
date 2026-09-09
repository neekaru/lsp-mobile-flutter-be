import 'package:material_ui/material_ui.dart';

class AsesorAsesiTabButton extends StatelessWidget {
  final String label;
  final int badgeCount;
  final bool isActive;
  final Color activeColor;
  final Color activeBadgeBg;
  final Color activeBadgeText;
  final VoidCallback onTap;

  const AsesorAsesiTabButton({
    super.key,
    required this.label,
    required this.badgeCount,
    required this.isActive,
    required this.activeColor,
    required this.activeBadgeBg,
    required this.activeBadgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : const Color(0xFF64748B),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive ? activeBadgeBg : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isActive ? activeBadgeText : const Color(0xFF64748B),
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

class AsesorAsesiDateChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isCustom;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const AsesorAsesiDateChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isCustom = false,
    required this.isSelected,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (isCustom) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AsesorAsesiDateFilterMenuButton extends StatelessWidget {
  final String selectedDateFilter;
  final ValueChanged<String> onSelected;

  const AsesorAsesiDateFilterMenuButton({
    super.key,
    required this.selectedDateFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFiltered = selectedDateFilter != 'all';
    return PopupMenuButton<String>(
      tooltip: 'Filter Tanggal Jadwal Asesmen',
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'all',
          child: Row(
            children: [
              Icon(
                Icons.all_inclusive_rounded,
                size: 18,
                color: selectedDateFilter == 'all'
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Text(
                'Semua Tanggal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selectedDateFilter == 'all'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedDateFilter == 'all'
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'today',
          child: Row(
            children: [
              Icon(
                Icons.today_rounded,
                size: 18,
                color: selectedDateFilter == 'today'
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Text(
                'Hari Ini (Today)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selectedDateFilter == 'today'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedDateFilter == 'today'
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'yesterday',
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 18,
                color: selectedDateFilter == 'yesterday'
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Text(
                'Kemarin (Yesterday)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selectedDateFilter == 'yesterday'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedDateFilter == 'yesterday'
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'custom',
          child: Row(
            children: const [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
              SizedBox(width: 10),
              Text(
                'Pilih Tanggal...',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isFiltered ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltered ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: isFiltered ? Colors.white : const Color(0xFF64748B),
              size: 20,
            ),
            if (isFiltered)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

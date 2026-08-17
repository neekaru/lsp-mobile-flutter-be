import 'package:flutter/material.dart';

/// Switch tab "Asesor Aktif" / "Sebaran Skema".
class DistribusiTabBar extends StatelessWidget {
  final bool isAsesorAktifSelected;
  final ValueChanged<bool> onChanged;

  const DistribusiTabBar({
    super.key,
    required this.isAsesorAktifSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  decoration: BoxDecoration(
                    color: isAsesorAktifSelected
                        ? const Color(0xFF475569)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Asesor Aktif',
                    style: TextStyle(
                      color: isAsesorAktifSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  decoration: BoxDecoration(
                    color: !isAsesorAktifSelected
                        ? const Color(0xFF475569)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sebaran Skema',
                    style: TextStyle(
                      color: !isAsesorAktifSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

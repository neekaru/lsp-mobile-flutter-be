import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {'title': 'Data Pengajuan', 'icon': Icons.folder_open_rounded},
      {'title': 'Profil Peserta', 'icon': Icons.description_outlined},
      {'title': 'Dokumen Portofolio', 'icon': Icons.file_upload_outlined},
      {'title': 'Asesmen Mandiri', 'icon': Icons.help_outline_rounded},
    ];

    // Map internal 6 steps to the 4 indicators:
    // currentStep = 0 -> active index 0 (Data Pengajuan)
    // currentStep = 1, 2, or 3 -> active index 1 (Profil Peserta)
    // currentStep = 4 -> active index 2 (Dokumen Portofolio)
    // currentStep = 5 -> active index 3 (Asesmen Mandiri)
    int getIndicatorIndex() {
      if (currentStep == 0) return 0;
      if (currentStep == 1 || currentStep == 2 || currentStep == 3) return 1;
      if (currentStep == 4) return 2;
      return 3;
    }

    final int activeIndicatorIndex = getIndicatorIndex();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final isSelected = index == activeIndicatorIndex;
          final isCompleted = index < activeIndicatorIndex;

          Color getIconColor() {
            if (isSelected) return const Color(0xFF0F4C81);
            if (isCompleted) return const Color(0xFF2D9CDB);
            return const Color(0xFF64748B);
          }

          Color getCircleBg() {
            if (isSelected) return Colors.white;
            return const Color(0xFFE3F2FD);
          }

          Color getBorderColor() {
            if (isSelected) return const Color(0xFF0F4C81);
            return Colors.transparent;
          }

          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connecting lines
                if (index > 0)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Container(
                        height: 1.5,
                        color: isCompleted ? const Color(0xFF2D9CDB) : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                
                // Circle with label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: getCircleBg(),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: getBorderColor(),
                          width: isSelected ? 2.0 : 0.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0F4C81).withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle_rounded : steps[index]['icon'] as IconData,
                        color: getIconColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 68,
                      child: Text(
                        steps[index]['title'] as String,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF0F4C81) : const Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                if (index < steps.length - 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Container(
                        height: 1.5,
                        color: (index < activeIndicatorIndex) ? const Color(0xFF2D9CDB) : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

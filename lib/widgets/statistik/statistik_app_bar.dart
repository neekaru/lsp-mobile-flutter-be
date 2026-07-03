import 'package:flutter/material.dart';
import '../custom_app_bar.dart';

class StatistikAppBar extends StatelessWidget {
  final String title;
  final String currentView;
  final VoidCallback onBack;
  final ValueChanged<String> onSwitchView;

  const StatistikAppBar({
    super.key,
    required this.title,
    required this.currentView,
    required this.onBack,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      onBack: onBack,
      rightWidget: Theme(
        data: Theme.of(context).copyWith(
          dividerTheme: const DividerThemeData(color: Color(0xFFF1F5F9)),
        ),
        child: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: Colors.black,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 3,
          onSelected: (String value) {
            if (value == currentView) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anda sudah berada di halaman ini'),
                  duration: Duration(seconds: 1),
                ),
              );
            } else {
              onSwitchView(value);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'sertifikat',
              child: Row(
                children: [
                  Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF2C6C9C)),
                  SizedBox(width: 8),
                  Text(
                    'Skema Pemegang Sertifikat',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'distribusi',
              child: Row(
                children: [
                  Icon(Icons.map_rounded, size: 18, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    'Distribusi Asesor & Skema',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

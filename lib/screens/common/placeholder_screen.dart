import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

// Simple elegant fallback screen for other navigation tabs
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final VoidCallback? onBackToHome;

  const PlaceholderScreen({super.key, required this.title, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          // Custom App Bar with consistent style
          CustomAppBar(
            title: title,
            onBack: () {
              if (onBackToHome != null) {
                onBackToHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),

          // Body content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F1FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      color: Color(0xFF2C6C9C),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$title Sedang Dikembangkan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fitur ini akan segera hadir!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

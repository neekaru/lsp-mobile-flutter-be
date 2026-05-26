import 'package:flutter/material.dart';

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular Black Back Arrow Button
                GestureDetector(
                  onTap: () {
                    if (onBackToHome != null) {
                      onBackToHome!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                
                // Bold screen title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                
                // More options horizontal ellipsis
                const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
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

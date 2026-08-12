import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? rightWidget;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Circular Black Back Arrow Button
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
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
          
          // Bold screen title, mathematically centered
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Right Widget or default empty space
          SizedBox(
            width: 32,
            height: 32,
            child: Align(
              alignment: Alignment.centerRight,
              child: rightWidget ?? const SizedBox(width: 32),
            ),
          ),
        ],
      ),
    );
  }
}

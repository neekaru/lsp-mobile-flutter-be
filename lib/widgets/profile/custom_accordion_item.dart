import 'package:flutter/material.dart';

/// Item akordeon custom (judul + bullet points yang bisa dilipat).
class CustomAccordionItem extends StatefulWidget {
  final String title;
  final List<String> bulletPoints;

  const CustomAccordionItem({
    super.key,
    required this.title,
    required this.bulletPoints,
  });

  @override
  State<CustomAccordionItem> createState() => _CustomAccordionItemState();
}

class _CustomAccordionItemState extends State<CustomAccordionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Card
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x02000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right_rounded,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expanded Content Card
        if (_isExpanded) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x02000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.bulletPoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

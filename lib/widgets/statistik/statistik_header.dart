import 'package:flutter/material.dart';

class StatistikHeader extends StatelessWidget {
  final double statusBarHeight;

  const StatistikHeader({
    super.key,
    required this.statusBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180 + statusBarHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4FA8E8),
            Color(0xFF2C6C9C),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistik Sertifikasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sebaran Sertifikasi Nasional Real-time',
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              )
            ],
          ),
          const Spacer(),
          // Filter Pills Row
          Row(
            children: [
              _buildFilterPill('Tahun Ini', true),
              const SizedBox(width: 8),
              _buildFilterPill('Semua Sektor', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.white : Colors.white.withAlpha(64),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF2C6C9C) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isActive ? const Color(0xFF2C6C9C) : Colors.white,
            size: 14,
          ),
        ],
      ),
    );
  }
}

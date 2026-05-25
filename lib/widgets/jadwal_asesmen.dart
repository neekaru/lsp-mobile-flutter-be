import 'package:flutter/material.dart';

class JadwalAsesmen extends StatelessWidget {
  const JadwalAsesmen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Asesmen Mendekati Akhir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4FA8E8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of deadline item cards (3 items as shown in the image)
        const JadwalItemCard(),
        const SizedBox(height: 10),
        const JadwalItemCard(),
        const SizedBox(height: 10),
        const JadwalItemCard(),
      ],
    );
  }
}

class JadwalItemCard extends StatelessWidget {
  const JadwalItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // black with 0.03 opacity
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1FC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF2C6C9C),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Center Text
          const Expanded(
            child: Text(
              '5 Jadwal asesmen mendekati batas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Right Column: Date & Remaining Days
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                '23 Mei 2025',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '3 hari lagi',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFE53935), // Red warning text
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

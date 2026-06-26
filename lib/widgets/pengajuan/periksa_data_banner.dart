import 'package:flutter/material.dart';

class PeriksaDataBanner extends StatelessWidget {
  const PeriksaDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0DF), // cream background matching Gambar 1
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFAD7B0), // warm light orange border
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE28B36), // orange/brown icon
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Periksa Kembali Data Anda',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pastikan semua data Anda sudah benar sebelum mengonfirmasi pendaftaran untuk skema sertifikasi ini!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7E7E7E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

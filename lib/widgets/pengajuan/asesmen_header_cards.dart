import 'package:flutter/material.dart';

class AsesmenHeaderCards extends StatelessWidget {
  final VoidCallback? onBuktiTap;

  const AsesmenHeaderCards({
    super.key,
    this.onBuktiTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. FR-APL 02 ASESMEN MANDIRI Description Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FR-APL 02 ASESMEN MANDIRI',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.45,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text: 'Pastikan anda kompeten sesuai dengan elemen dan kuk yang ada pada setiap unit-unit kompetensi berikut ini. ',
                    ),
                    TextSpan(
                      text: 'K(Kompeten)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    TextSpan(
                      text: ' dan ',
                    ),
                    TextSpan(
                      text: 'BK(Belum Kompeten)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    TextSpan(
                      text: '. Pilih Bukti Kompetensi yang relevan dari file yang telah anda upload di tahap sebelumnya.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. BUKTI PORTOFOLIO / RELEVAN Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: onBuktiTap,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BUKTI PORTOFOLIO / RELEVAN',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Jika anda memiliki pengalaman bekerja sesuai dengan Skema Sertifikasi, Upload Salah Satu / Semua Dokumen di bawah ini!',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Color(0xFF378CE7),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

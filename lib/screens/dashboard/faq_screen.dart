import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  void _showAnswerBottomSheet(BuildContext context, String question, String answer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),
              const SizedBox(height: 8),
              Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Match Berita background
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar matching Berita style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                  const Text(
                    'Tanya Jawab (FAQ)',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
                ],
              ),
            ),
            
            // Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFaqItem(
                      context,
                      question: 'Apa itu Uji Kompetensi?',
                      answer: 'Uji kompetensi adalah proses penilaian baik teknis maupun non-teknis melalui pengumpulan bukti yang relevan untuk menentukan apakah seseorang kompeten atau belum kompeten pada skema sertifikasi tertentu.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      context,
                      question: 'Berapa lama biasanya uji sertifikasi?',
                      answer: 'Durasi uji sertifikasi bervariasi tergantung pada skema yang dipilih, umumnya berkisar antara 2 hingga 4 jam yang mencakup ujian tertulis, praktik/observasi langsung, dan wawancara dengan asesor.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      context,
                      question: 'Apa saja syarat dan ketentuan untuk mengikuti uji sertifikasi?',
                      answer: 'Syarat umum meliputi:\n\n1. Kartu Identitas (KTP/KTM).\n2. Curriculum Vitae (CV) terbaru.\n3. Ijazah terakhir atau surat keterangan kerja/kuliah.\n4. Bukti portofolio/karya yang relevan dengan skema sertifikasi yang dipilih.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      context,
                      question: 'Berapa biaya sertifikasi?',
                      answer: 'Biaya sertifikasi bergantung pada skema kompetensi yang Anda ajukan. Informasi lengkap mengenai biaya untuk setiap skema dapat dilihat secara transparan saat Anda memilih skema di menu Sertifikasi.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      context,
                      question: 'Bagaimana bila peserta tidak kompeten?',
                      answer: 'Bagi peserta yang dinyatakan "Belum Kompeten" (BK), dapat mengikuti asesmen ulang pada unit kompetensi yang belum tercapai setelah melakukan persiapan mandiri atau mengikuti pelatihan tambahan.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      context,
                      question: 'Sampai berapa lama biasanya sertifikat masih berlaku?',
                      answer: 'Sertifikat kompetensi yang diterbitkan oleh LSP Teknologi Digital berlaku selama 3 (tiga) tahun. Setelah masa berlaku habis, pemegang sertifikat dapat mengajukan sertifikasi ulang (perpanjangan).',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Clean white card to pop on grey background
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAnswerBottomSheet(context, question, answer),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF1E6FDB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

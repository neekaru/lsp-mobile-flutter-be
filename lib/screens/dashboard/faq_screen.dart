import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex = 0; // First item expanded by default as in the design image

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Apa itu Uji Kompetensi?',
      'answer': 'Uji kompetensi adalah proses pengukuran dan penilaian secara sistematis untuk memastikan apakah seseorang memiliki pengetahuan, keterampilan, dan sikap kerja yang sesuai dengan standar profesi atau kualifikasi yang telah ditetapkan. Melalui pengujian ini—yang biasanya melibatkan ujian teori, praktik, maupun wawancara oleh lembaga resmi—peserta yang dinyatakan kompeten akan mendapatkan sertifikat keahlian sebagai bukti valid atas profesionalisme mereka di dunia kerja.',
    },
    {
      'question': 'Berapa lama biasanya uji sertifikasi?',
      'answer': 'Durasi uji sertifikasi bervariasi tergantung pada skema yang dipilih, umumnya berkisar antara 2 hingga 4 jam yang mencakup ujian tertulis, praktik/observasi langsung, dan wawancara dengan asesor.',
    },
    {
      'question': 'Apa saja syarat dan ketentuan untuk mengikuti uji sertifikasi?',
      'answer': 'Syarat umum meliputi:\n\n1. Kartu Identitas (KTP/KTM).\n2. Curriculum Vitae (CV) terbaru.\n3. Ijazah terakhir atau surat keterangan kerja/kuliah.\n4. Bukti portofolio/karya yang relevan dengan skema sertifikasi yang dipilih.',
    },
    {
      'question': 'Berapa biaya sertifikasi?',
      'answer': 'Biaya sertifikasi bergantung pada skema kompetensi yang Anda ajukan. Informasi lengkap mengenai biaya untuk setiap skema dapat dilihat secara transparan saat Anda memilih skema di menu Sertifikasi.',
    },
    {
      'question': 'Bagaimana bila peserta tidak kompeten?',
      'answer': 'Bagi peserta yang dinyatakan "Belum Kompeten" (BK), dapat mengikuti asesmen ulang pada unit kompetensi yang belum tercapai setelah melakukan persiapan mandiri atau mengikuti pelatihan tambahan.',
    },
    {
      'question': 'Sampai berapa lama biasanya sertifikat masih berlaku?',
      'answer': 'Sertifikat kompetensi yang diterbitkan oleh LSP Teknologi Digital berlaku selama 3 (tiga) tahun. Setelah masa berlaku habis, pemegang sertifikat dapat mengajukan sertifikasi ulang (perpanjangan).',
    },
  ];

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
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _faqItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _faqItems[index];
                  final isExpanded = _expandedIndex == index;
                  
                  return _buildFaqItem(
                    index: index,
                    question: item['question']!,
                    answer: item['answer']!,
                    isExpanded: isExpanded,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
    required bool isExpanded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Box
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Light background card matching the design image
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                  color: const Color(0xFF1E6FDB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Answer Box (shown if expanded)
        if (isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Matching light background card
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

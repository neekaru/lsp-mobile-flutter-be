import 'package:flutter/material.dart';

class TesTertulisReviewGrid extends StatelessWidget {
  final Map<int, int> answers;
  final VoidCallback onBack;
  final ValueChanged<int> onJumpToQuestion;

  const TesTertulisReviewGrid({
    super.key,
    required this.answers,
    required this.onBack,
    required this.onJumpToQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildReviewGridAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab pill "Semua Soal"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Semua Soal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid and Legend card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Grid
                        Expanded(
                          flex: 3,
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 6,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: List.generate(30, (index) {
                              final int displayNum = index + 1;
                              final bool isAnswered = answers.containsKey(index);
                              return GestureDetector(
                                onTap: () => onJumpToQuestion(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isAnswered ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$displayNum',
                                    style: TextStyle(
                                      color: isAnswered ? const Color(0xFF15803D) : const Color(0xFFEF4444),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Legend
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem(const Color(0xFFDCFCE7), 'Sudah Terjawab'),
                                const SizedBox(height: 12),
                                _buildLegendItem(const Color(0xFFFEE2E2), 'Belum Terjawab'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Actions row below grid
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: onBack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD1D1D6),
                              foregroundColor: const Color(0xFF4E4E4E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Kembali',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: onBack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B9FD8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewGridAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
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
            'Periksa Jawaban',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const Icon(
            Icons.more_horiz_rounded,
            color: Colors.black,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

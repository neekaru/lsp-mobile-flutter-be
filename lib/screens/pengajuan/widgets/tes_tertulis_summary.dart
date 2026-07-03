import 'package:flutter/material.dart';
import '../../../widgets/custom_app_bar.dart';

class TesTertulisSummary extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final Map<int, int> answers;
  final int secondsRemaining;
  final VoidCallback onBackToQuiz;
  final VoidCallback onReviewGrid;
  final VoidCallback onSubmit;
  final ValueChanged<int> onJumpToQuestion;
  final String Function(int seconds) formatTime;

  const TesTertulisSummary({
    super.key,
    required this.questions,
    required this.answers,
    required this.secondsRemaining,
    required this.onBackToQuiz,
    required this.onReviewGrid,
    required this.onSubmit,
    required this.onJumpToQuestion,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final int totalQuestions = questions.length;
    final int answeredQuestions = answers.length;
    final int unansweredQuestions = totalQuestions - answeredQuestions;
    final String timeSpentStr = formatTime(3600 - secondsRemaining);

    // List of indices of unanswered questions
    final List<int> unansweredIndices = [];
    for (int i = 0; i < totalQuestions; i++) {
      if (!answers.containsKey(i)) {
        unansweredIndices.add(i);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildSummaryAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Green Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Ringkasan Jawaban',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF14532D),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Pastikan semua soal sudah Anda jawab dengan benar, sebelum Anda mengirimkan tes.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF15803D),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_rounded,
                            color: Color(0xFF22C55E),
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Summary Stats Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryStatRow('Total Soal', '$totalQuestions soal', isBoldValue: true),
                        const SizedBox(height: 12),
                        _buildSummaryStatRow('Sudah Dijawab', '$answeredQuestions soal', isBoldValue: true),
                        const SizedBox(height: 12),
                        _buildSummaryStatRow('Belum Dijawab', '$unansweredQuestions soal', isBoldValue: true),
                        const SizedBox(height: 12),
                        _buildSummaryStatRow('Total Waktu', timeSpentStr, isBoldValue: true, valueColor: const Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Unanswered Questions Card (if any)
                  if (unansweredIndices.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daftar Soal Belum Dijawab',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Silahkan periksa kembali soal nomor berikut sebelum mengirim test',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: unansweredIndices.map((index) {
                              final int displayNum = index + 1;
                              return GestureDetector(
                                onTap: () => onJumpToQuestion(index),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$displayNum',
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Orange Warning Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEEAD2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Periksa Kembali',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildOrangeBullet('1. Pastikan tidak ada soal yang terlewat'),
                        const SizedBox(height: 6),
                        _buildOrangeBullet('2. Jika sudah terkirim jawaban tidak dapat diubah'),
                        const SizedBox(height: 6),
                        _buildOrangeBullet('3. Jawaban Anda akan terkirim secara permanen'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSummaryBottomNav(),
        ],
      ),
    );
  }

  Widget _buildSummaryAppBar() {
    return CustomAppBar(
      title: 'Tes Tertulis',
      onBack: onBackToQuiz,
    );
  }

  Widget _buildSummaryStatRow(String label, String value, {bool isBoldValue = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildOrangeBullet(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF92400E),
        height: 1.45,
      ),
    );
  }

  Widget _buildSummaryBottomNav() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onReviewGrid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBEAFE),
                    foregroundColor: const Color(0xFF1E3A8A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Periksa Jawaban',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Kirim Tes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

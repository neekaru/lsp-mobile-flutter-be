import 'package:flutter/material.dart';

class StepEvaluasiKompetensi extends StatelessWidget {
  final List<String> questions;
  final Map<int, String> answers;
  final void Function(int index, String value) onAnswerChanged;

  const StepEvaluasiKompetensi({
    super.key,
    required this.questions,
    required this.answers,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evaluasi Kompetensi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Berikan penilaian kemampuan diri Anda pada kompetensi berikut.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                  Text(
                    '${index + 1}. ${questions[index]}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRadioOption(index, 'Ya, saya bisa', 'ya'),
                  const SizedBox(height: 4),
                  _buildRadioOption(index, 'Tidak,saya tidak bisa', 'tidak'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRadioOption(int questionIndex, String text, String value) {
    final bool isSelected = answers[questionIndex] == value;

    return GestureDetector(
      onTap: () => onAnswerChanged(questionIndex, value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3B82F6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

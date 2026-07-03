import 'package:flutter/material.dart';
import '../../../widgets/custom_app_bar.dart';

class TesTertulisQuiz extends StatelessWidget {
  final int currentPage;
  final List<Map<String, dynamic>> questions;
  final Map<int, int> answers;
  final int secondsRemaining;
  final ScrollController scrollController;
  final Function(int globalIndex, int optionIndex) onAnswerChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onExit;
  final String Function(int seconds) formatTime;

  const TesTertulisQuiz({
    super.key,
    required this.currentPage,
    required this.questions,
    required this.answers,
    required this.secondsRemaining,
    required this.scrollController,
    required this.onAnswerChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onExit,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildQuizAppBar(),
          _buildTimerHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildQuestionsList(),
            ),
          ),
          _buildQuizBottomNav(),
        ],
      ),
    );
  }

  Widget _buildQuizAppBar() {
    return CustomAppBar(
      title: 'Tes Tertulis',
      onBack: onExit,
    );
  }

  Widget _buildTimerHeader() {
    final int answeredOnThisPage = (currentPage + 1) * 3;
    final int displayCount = answeredOnThisPage > questions.length ? questions.length : answeredOnThisPage;
    final double progress = questions.isEmpty ? 0.0 : (displayCount / questions.length).clamp(0.0, 1.0);
    final bool timeWarning = secondsRemaining < 300;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal $displayCount / ${questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: timeWarning ? const Color(0xFFDC2626) : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatTime(secondsRemaining),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: timeWarning ? const Color(0xFFDC2626) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFDBEAFE),
              color: const Color(0xFF3B82F6),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    final int startIdx = currentPage * 3;

    return Column(
      children: List.generate(3, (index) {
        final int globalIndex = startIdx + index;
        if (globalIndex >= questions.length) return const SizedBox.shrink();

        final question = questions[globalIndex];
        return _buildQuestionItemCard(globalIndex, question);
      }),
    );
  }

  Widget _buildQuestionItemCard(int globalIndex, Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${globalIndex + 1}. ${question['category']}',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Text(
            question['question']!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionsList(globalIndex, question),
        ],
      ),
    );
  }

  Widget _buildOptionsList(int globalIndex, Map<String, dynamic> question) {
    final List<String> options = question['options'] as List<String>;
    final selectedOption = answers[globalIndex];

    return Column(
      children: List.generate(options.length, (index) {
        final bool isSelected = selectedOption == index;

        return GestureDetector(
          onTap: () => onAnswerChanged(globalIndex, index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF3B82F6),
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
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
                    options[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuizBottomNav() {
    final bool isLastPage = currentPage == (questions.isEmpty ? 0 : (questions.length - 1) ~/ 3);

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
                  onPressed: onPrevious,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1D1D6),
                    foregroundColor: const Color(0xFF4E4E4E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF4E4E4E)),
                      SizedBox(width: 6),
                      Text('Kembali', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastPage ? 'Selesai & Kirim' : 'Selanjutnya',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Icon(isLastPage ? Icons.send_rounded : Icons.arrow_forward_rounded, size: 16),
                    ],
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

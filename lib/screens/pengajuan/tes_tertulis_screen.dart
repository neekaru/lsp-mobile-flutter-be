import 'dart:async';
import 'package:flutter/material.dart';

class TesTertulisScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const TesTertulisScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<TesTertulisScreen> createState() => _TesTertulisScreenState();
}

class _TesTertulisScreenState extends State<TesTertulisScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _answers = {}; // question index -> option index

  // Countdown timer state
  late Timer _timer;
  int _secondsRemaining = 2700; // 45 minutes

  // Mock list of questions based on certification
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _initQuestions();
    _startTimer();
  }

  void _initQuestions() {
    _questions = [
      {
        'question': 'Manakah dari berikut ini yang merupakan tujuan utama dari digital marketing campaign?',
        'options': [
          'Meningkatkan biaya operasional perusahaan.',
          'Membangun awareness, traffic, dan konversi penjualan secara digital.',
          'Mengurangi jumlah tenaga kerja di bagian pemasaran tradisional.',
          'Menghapus website perusahaan yang sudah tidak terpakai.'
        ],
        'correct': 1
      },
      {
        'question': 'Dalam SEO, apa kepanjangan dari SERP?',
        'options': [
          'Search Engine Result Page',
          'Social Engagement Rate Program',
          'System Enterprise Resource Planning',
          'Site External Redirect Protocol'
        ],
        'correct': 0
      },
      {
        'question': 'Metric apa yang mengukur persentase pengunjung yang meninggalkan website setelah hanya membuka satu halaman saja?',
        'options': [
          'Conversion Rate',
          'Click-Through Rate (CTR)',
          'Bounce Rate',
          'Exit Rate'
        ],
        'correct': 2
      },
      {
        'question': 'Di bawah ini yang merupakan metode penargetan iklan berbayar (PPC) yang paling populer adalah...',
        'options': [
          'Google Ads',
          'FTP Server',
          'SMTP Protocol',
          'Offline Billboard'
        ],
        'correct': 0
      },
      {
        'question': 'Apa kegunaan utama dari Google Analytics dalam digital marketing?',
        'options': [
          'Mengedit gambar produk.',
          'Membuat konten video untuk promosi.',
          'Menganalisis performa website dan perilaku pengunjung.',
          'Mengirim email newsletter otomatis.'
        ],
        'correct': 2
      }
    ];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        _handleSubmitTest(autoSubmit: true);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleSubmitTest({bool autoSubmit = false}) {
    // Calculate Score
    int correctAnswersCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i]['correct']) {
        correctAnswersCount++;
      }
    }
    final double score = (correctAnswersCount / _questions.length) * 100;

    _timer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final passed = score >= 70; // 70 is minimum passing score
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: passed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: passed ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  passed ? 'Selamat! Anda Lulus' : 'Maaf, Anda Belum Lulus',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Skor Anda: ${score.toInt()}/100\n($correctAnswersCount dari ${_questions.length} benar)',
                  style: TextStyle(
                    color: passed ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  passed 
                      ? 'Nilai Anda memenuhi standar kelulusan tes tertulis. Silakan lanjut memilih Asesor Anda.' 
                      : 'Nilai Anda belum memenuhi standar kelulusan (70). Silakan ulangi tes atau hubungi admin.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss Dialog
                      Navigator.of(context).pop(); // Return from Written Test
                      Navigator.of(context).pop(); // Return to DetailSkemaScreen
                      
                      // Notify user
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ujian selesai! Silakan hubungi asesor untuk langkah berikutnya.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: passed ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      passed ? 'Lanjut Pilih Asesor' : 'Kembali ke Skema',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          _buildTimerHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionCard(currentQuestion),
                  const SizedBox(height: 20),
                  _buildOptionsList(currentQuestion),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showExitConfirmationDialog(),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tes Tertulis Sertifikasi',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildTimerHeader() {
    final double progress = (_currentQuestionIndex + 1) / _questions.length;
    final bool timeWarning = _secondsRemaining < 300; // Warning color if < 5 mins left

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${_currentQuestionIndex + 1} dari ${_questions.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: timeWarning ? const Color(0xFFDC2626) : const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: timeWarning ? const Color(0xFFDC2626) : const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            color: const Color(0xFF3B82F6),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'PILIHAN GANDA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            question['question']!,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(Map<String, dynamic> question) {
    final List<String> options = question['options'] as List<String>;
    final selectedOption = _answers[_currentQuestionIndex];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final bool isSelected = selectedOption == index;
        final String label = String.fromCharCode(65 + index); // A, B, C, D

        return GestureDetector(
          onTap: () {
            setState(() {
              _answers[_currentQuestionIndex] = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF334155),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

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
                child: OutlinedButton(
                  onPressed: _currentQuestionIndex == 0
                      ? null
                      : () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sebelumnya', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastQuestion) {
                      _showSubmitConfirmationDialog();
                    } else {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion ? const Color(0xFF22C55E) : const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isLastQuestion ? 'Selesai & Kirim' : 'Selanjutnya',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitConfirmationDialog() {
    final unansweredCount = _questions.length - _answers.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Selesaikan Ujian?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            unansweredCount > 0
                ? 'Ada $unansweredCount soal yang belum dijawab. Apakah Anda yakin ingin mengirim jawaban sekarang?'
                : 'Apakah Anda yakin ingin menyelesaikan ujian dan mengirim semua jawaban Anda?',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _handleSubmitTest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Keluar dari Ujian?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
          ),
          content: const Text(
            'Keluar dari halaman ini akan membatalkan sesi ujian Anda yang sedang berlangsung dan progres pengerjaan akan hilang.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali Mengerjakan', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.of(context).pop(); // Exit screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

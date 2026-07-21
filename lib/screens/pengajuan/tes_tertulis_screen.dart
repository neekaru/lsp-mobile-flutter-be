import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/asesi_service.dart';
import '../../services/sertifikat_service.dart';
import 'widgets/tes_tertulis_intro.dart';
import 'widgets/tes_tertulis_quiz.dart';
import 'widgets/tes_tertulis_summary.dart';
import 'widgets/tes_tertulis_review_grid.dart';
import 'widgets/tes_tertulis_submitted.dart';

enum TestViewState { intro, quiz, summary, reviewGrid, submitted }

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
  TestViewState _viewState = TestViewState.intro;
  int _currentPage = 0;
  final Map<int, int> _answers = {};

  Timer? _timer;
  int _secondsRemaining = 3600;
  int _durationSeconds = 3600;
  final ScrollController _scrollController = ScrollController();
  String _finalTimeSpent = '';

  bool _loading = true;
  String? _loadError;
  String _displayTitle = '';
  int _examId = 0;
  int? _asesiId;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    _loadSoal();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSoal() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final data = await SertifikatService.getUjianSoalBySkema(widget.skemaId);
      if (!mounted) return;
      if (data == null || data.soal.isEmpty) {
        setState(() {
          _loading = false;
          _loadError =
              'Soal tes tertulis belum tersedia untuk skema ini.';
        });
        return;
      }

      final mapped = data.soal.map((s) => s.toQuizMap()).toList();
      final durMin = data.durasiMenit > 0 ? data.durasiMenit : 60;
      final title = data.namaSkema.isNotEmpty ? data.namaSkema : widget.title;

      // Resolve asesi id for submit (optional — submit may still work later)
      int? asesiId;
      try {
        final status =
            await AsesiService.getSertifikasiStatus(widget.skemaId);
        final id = status?['sertifikasi_id'] ?? status?['id'] ?? status?['asesi_id'];
        if (id is int) {
          asesiId = id;
        } else if (id is num) {
          asesiId = id.toInt();
        } else if (id != null) {
          asesiId = int.tryParse(id.toString());
        }
      } catch (_) {}

      setState(() {
        _questions = mapped;
        _examId = data.examId;
        _displayTitle = title;
        _durationSeconds = durMin * 60;
        _secondsRemaining = _durationSeconds;
        _asesiId = asesiId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Gagal memuat soal. Coba lagi.';
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
        _handleSubmitTest(autoSubmit: true);
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSubmitTest({bool autoSubmit = false}) async {
    _timer?.cancel();
    _timer = null;

    int benar = 0;
    int salah = 0;
    final List<Map<String, dynamic>> jawaban = [];

    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final idSoal = q['id_soal'] as int? ?? 0;
      final letters = (q['option_letters'] as List?)?.cast<String>() ?? [];
      final correct = (q['correct_letter'] as String? ?? '').toUpperCase();
      final sel = _answers[i];
      String userLetter = '';
      if (sel != null && sel >= 0 && sel < letters.length) {
        userLetter = letters[sel];
      }
      if (userLetter.isNotEmpty &&
          correct.isNotEmpty &&
          userLetter.toUpperCase() == correct) {
        benar++;
      } else if (userLetter.isNotEmpty) {
        salah++;
      } else {
        salah++;
      }
      jawaban.add({
        'id_soal': idSoal,
        'jawaban_user': userLetter,
      });
    }

    if (_asesiId != null && _asesiId! > 0 && _examId > 0) {
      await SertifikatService.submitUjian(
        asesiId: _asesiId!,
        skemaId: widget.skemaId,
        examId: _examId,
        jawaban: jawaban,
        jawabanBenar: benar,
        jawabanSalah: salah,
      );
    }

    if (mounted) {
      setState(() {
        _finalTimeSpent = _formatTime(_durationSeconds - _secondsRemaining);
        _viewState = TestViewState.submitted;
      });
    }
  }

  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF5B9FD8)),
              const SizedBox(height: 16),
              Text(
                'Memuat soal ${_displayTitle.isNotEmpty ? _displayTitle : widget.title}…',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSoal,
                    child: const Text('Coba Lagi'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    switch (_viewState) {
      case TestViewState.intro:
        return TesTertulisIntro(
          title: _displayTitle,
          questionsCount: _questions.length,
          onStartTest: () {
            setState(() {
              _viewState = TestViewState.quiz;
            });
            _startTimer();
          },
          onBack: () => Navigator.pop(context),
        );
      case TestViewState.quiz:
        return TesTertulisQuiz(
          currentPage: _currentPage,
          questions: _questions,
          answers: _answers,
          secondsRemaining: _secondsRemaining,
          scrollController: _scrollController,
          onAnswerChanged: (globalIndex, optionIndex) {
            setState(() {
              _answers[globalIndex] = optionIndex;
            });
          },
          onPrevious: () {
            if (_currentPage > 0) {
              _changePage(_currentPage - 1);
            } else {
              _showExitConfirmationDialog();
            }
          },
          onNext: () {
            final bool isLastPage = _currentPage ==
                (_questions.isEmpty ? 0 : (_questions.length - 1) ~/ 3);
            if (isLastPage) {
              _timer?.cancel();
              _timer = null;
              setState(() {
                _viewState = TestViewState.summary;
              });
            } else {
              _changePage(_currentPage + 1);
            }
          },
          onExit: _showExitConfirmationDialog,
          formatTime: _formatTime,
        );
      case TestViewState.summary:
        return TesTertulisSummary(
          questions: _questions,
          answers: _answers,
          secondsRemaining: _secondsRemaining,
          onBackToQuiz: () {
            setState(() {
              _viewState = TestViewState.quiz;
            });
            _startTimer();
          },
          onReviewGrid: () {
            setState(() {
              _viewState = TestViewState.reviewGrid;
            });
          },
          onSubmit: _showSubmitConfirmationDialog,
          onJumpToQuestion: (index) {
            _changePage(index ~/ 3);
            setState(() {
              _viewState = TestViewState.quiz;
            });
            _startTimer();
          },
          formatTime: _formatTime,
        );
      case TestViewState.reviewGrid:
        return TesTertulisReviewGrid(
          answers: _answers,
          onBack: () {
            setState(() {
              _viewState = TestViewState.summary;
            });
          },
          onJumpToQuestion: (index) {
            _changePage(index ~/ 3);
            setState(() {
              _viewState = TestViewState.quiz;
            });
            _startTimer();
          },
        );
      case TestViewState.submitted:
        return TesTertulisSubmitted(
          title: _displayTitle,
          finalTimeSpent: _finalTimeSpent,
          onBackToHome: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
    }
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
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubmitTest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Kirim',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC2626),
            ),
          ),
          content: const Text(
            'Keluar dari halaman ini akan membatalkan sesi ujian Anda yang sedang berlangsung dan progres pengerjaan akan hilang.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Kembali Mengerjakan',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/tes_tertulis_intro.dart';
import 'widgets/tes_tertulis_quiz.dart';
import 'widgets/tes_tertulis_summary.dart';
import 'widgets/tes_tertulis_review_grid.dart';
import 'widgets/tes_tertulis_submitted.dart';

enum TestViewState {
  intro,
  quiz,
  summary,
  reviewGrid,
  submitted
}

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
  int _currentPage = 0; // Page 0 to 9 (3 questions per page)
  final Map<int, int> _answers = {}; // question index -> option index

  // Countdown timer state
  Timer? _timer;
  int _secondsRemaining = 3600; // 60 minutes
  final ScrollController _scrollController = ScrollController();
  String _finalTimeSpent = '';

  // Mock list of questions based on certification
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _initQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _initQuestions() {
    _questions = [
      // Page 1 (1-3)
      {
        'category': 'Riset Pasar & Tren',
        'question': 'Manakah dari pilihan berikut yang merupakan fungsi utama dari penggunaan Google Trends dalam tahap riset pasar digital?',
        'options': [
          'A. Menentukan Biaya iklan per klik secara akurat',
          'B. memantau popularitas kata kunci dan tren',
          'C. Mengubah tampilan visual website kompetitor',
          'D. Mengirimkan email promosi otomatis ke calon pelanggan.'
        ],
        'correct': 1
      },
      {
        'category': 'Media Sosial (Sosial Media Marketing)',
        'question': 'Mengapa penting bagi seorang Digital Marketer untuk menentukan Target Audience (Persona) sebelum membuat konten di media sosial?',
        'options': [
          'A. Agar konten yang dibuat relevan dan mampu menarik perhatian audiens yang tepat.',
          'B. Untuk memastikan akun media sosial mendapatkan centang biru secara instan.',
          'C. Supaya algoritma media sosial otomatis mendongkrak penjualan tanpa iklan.',
          'D. Mengurangi biaya kuota internet saat mengunggah video konten.'
        ],
        'correct': 0
      },
      {
        'category': 'Pengoptimalkan Mesin Pencari (SEO)',
        'question': 'Dalam strategi Search Engine Optimization (SEO)',
        'options': [
          'A. Membeli backlink berkualitas tinggi dari website luar negeri.',
          'B. Mengatur dekorasi ruang kerja tim digital marketing.',
          'C. Optimasi elemen internal website seperti struktur konten, judul halaman (Title Tag), dan penggunaan kata kunci.',
          'D. Membayar Google Ads agar website berada di posisi paling atas dalam waktu 1 jam.'
        ],
        'correct': 2
      },
      // Page 2 (4-6)
      {
        'category': 'Konten Marketing',
        'question': 'Apa jenis konten yang biasanya paling efektif untuk meningkatkan engagement rates di platform Instagram saat ini?',
        'options': [
          'A. Artikel teks panjang tanpa gambar.',
          'B. Foto resolusi rendah dari produk.',
          'C. Konten video pendek yang interaktif dan menghibur (Reels).',
          'D. Gambar hitam putih statis.'
        ],
        'correct': 2
      },
      {
        'category': 'Metrik & Analitik',
        'question': 'Apa yang dimaksud dengan Bounce Rate dalam laporan performa website?',
        'options': [
          'A. Persentase pengguna yang langsung meninggalkan website setelah membuka satu halaman saja.',
          'B. Jumlah rata-rata halaman yang dikunjungi dalam satu sesi.',
          'C. Kecepatan loading halaman dalam milidetik.',
          'D. Jumlah total klik yang didapatkan dari mesin pencari.'
        ],
        'correct': 0
      },
      {
        'category': 'Copywriting',
        'question': 'Dalam membuat headline iklan, formula AIDA sangat populer. Apakah kepanjangan dari AIDA?',
        'options': [
          'A. Action, Interest, Detail, Agreement',
          'B. Attention, Interest, Desire, Action',
          'C. Audience, Interaction, Development, Activity',
          'D. Analysis, Information, Delivery, Assessment'
        ],
        'correct': 1
      },
      // Page 3 (7-9)
      {
        'category': 'Iklan Berbayar (PPC)',
        'question': 'Metode pembayaran iklan digital berdasarkan setiap klik yang dilakukan oleh target konsumen disebut...',
        'options': [
          'A. Pay-Per-View (PPV)',
          'B. Pay-Per-Click (PPC)',
          'C. Cost-Per-Mille (CPM)',
          'D. Cost-Per-Action (CPA)'
        ],
        'correct': 1
      },
      {
        'category': 'Email Marketing',
        'question': 'Manakah dari praktik berikut yang paling penting untuk mencegah email newsletter masuk ke folder spam pelanggan?',
        'options': [
          'A. Mengirim email ke jutaan alamat acak.',
          'B. Menggunakan kata-kata clickbait agresif seperti "GRATIS UANG".',
          'C. Mendapatkan persetujuan (opt-in) dari penerima email.',
          'D. Tidak menyertakan link unsubscribe.'
        ],
        'correct': 2
      },
      {
        'category': 'Strategi Branding',
        'question': 'Unique Selling Proposition (USP) dalam strategi bisnis berfungsi untuk...',
        'options': [
          'A. Membandingkan harga produk dengan produk kompetitor secara langsung.',
          'B. Menentukan ciri khas unik yang membedakan produk Anda dari kompetitor.',
          'C. Menghitung total keuntungan bersih dalam sebulan.',
          'D. Memperluas area distribusi fisik produk.'
        ],
        'correct': 1
      },
      // Page 4 (10-12)
      {
        'category': 'E-Commerce',
        'question': 'Strategi menawarkan produk dengan harga lebih tinggi atau kualitas lebih baik kepada konsumen yang sedang membeli disebut...',
        'options': [
          'A. Cross-selling',
          'B. Up-selling',
          'C. Down-selling',
          'D. Under-selling'
        ],
        'correct': 1
      },
      {
        'category': 'Sosial Media Marketing',
        'question': 'Manakah dari berikut ini yang merupakan fungsi utama dari Call to Action (CTA)?',
        'options': [
          'A. Mempercantik visual gambar postingan.',
          'B. Mengajak audiens untuk melakukan tindakan tertentu seperti membeli atau mendaftar.',
          'C. Menambahkan jumlah tagar di deskripsi video.',
          'D. Menyembunyikan link sponsor.'
        ],
        'correct': 1
      },
      {
        'category': 'Riset Kata Kunci',
        'question': 'Istilah "Long-tail keywords" dalam SEO merujuk pada...',
        'options': [
          'A. Kata kunci pencarian yang sangat pendek dan bersifat umum.',
          'B. Kata kunci pencarian yang lebih panjang, spesifik, dan biasanya memiliki volume pencarian lebih rendah namun konversi lebih tinggi.',
          'C. Nama domain website yang sangat panjang.',
          'D. Deskripsi meta produk yang melebihi batas karakter.'
        ],
        'correct': 1
      },
      // Page 5 (13-15)
      {
        'category': 'Sosial Media Marketing',
        'question': 'Metode pemasaran menggunakan individu yang memiliki pengaruh besar di media sosial untuk mempromosikan produk disebut...',
        'options': [
          'A. Affiliate Marketing',
          'B. Influencer Marketing',
          'C. Telemarketing',
          'D. Guerilla Marketing'
        ],
        'correct': 1
      },
      {
        'category': 'Website & Landing Page',
        'question': 'Halaman web yang dirancang khusus untuk mengarahkan pengunjung setelah mengklik iklan dan fokus pada satu tujuan konversi disebut...',
        'options': [
          'A. Homepage',
          'B. Blog Page',
          'C. Landing Page',
          'D. Contact Page'
        ],
        'correct': 2
      },
      {
        'category': 'Hukum & Etika Digital',
        'question': 'Di Indonesia, undang-undang yang mengatur tentang transaksi elektronik dan penyebaran konten digital adalah...',
        'options': [
          'A. UU Hak Cipta',
          'B. UU ITE',
          'C. UU Perlindungan Konsumen',
          'D. UU Keterbukaan Informasi Publik'
        ],
        'correct': 1
      },
      // Page 6 (16-18)
      {
        'category': 'Analitik Web',
        'question': 'Metric "Conversion Rate" dihitung dengan cara...',
        'options': [
          'A. Membagi jumlah konversi dengan jumlah total pengunjung lalu dikali 100%.',
          'B. Membagi jumlah klik dengan total impresi iklan.',
          'C. Mengalikan jumlah pengunjung dengan harga rata-rata produk.',
          'D. Menjumlahkan seluruh transaksi dalam periode tertentu.'
        ],
        'correct': 0
      },
      {
        'category': 'SEO (Search Engine Optimization)',
        'question': 'Link dari website lain yang mengarah ke website Anda dan berfungsi meningkatkan reputasi domain Anda disebut...',
        'options': [
          'A. Internal Link',
          'B. Backlink / Inbound Link',
          'C. Broken Link',
          'D. Outbound Link'
        ],
        'correct': 1
      },
      {
        'category': 'Email Marketing',
        'question': 'Metode pengujian dua versi email (Versi A dan Versi B) untuk melihat mana yang memiliki performa lebih baik disebut...',
        'options': [
          'A. Double Opt-in Test',
          'B. A/B Testing / Split Testing',
          'C. Subject Line Verification',
          'D. Quality Assurance Test'
        ],
        'correct': 1
      },
      // Page 7 (19-21)
      {
        'category': 'Riset Tren',
        'question': 'Platform mana yang paling cocok digunakan untuk menganalisis topik yang sedang viral di X/Twitter?',
        'options': [
          'A. Google Analytics',
          'B. Trends24 / X Trends',
          'C. Adobe Photoshop',
          'D. Microsoft Excel'
        ],
        'correct': 1
      },
      {
        'category': 'Iklan Digital',
        'question': 'Apa yang dimaksud dengan "Remarketing" atau "Retargeting" dalam iklan digital?',
        'options': [
          'A. Mengganti nama merek produk dengan logo baru.',
          'B. Menampilkan iklan kembali kepada orang-orang yang sebelumnya pernah berinteraksi dengan website atau aplikasi Anda.',
          'C. Mengirim brosur fisik ke rumah konsumen yang lewat.',
          'D. Mengubah strategi pemasaran dari online menjadi offline.'
        ],
        'correct': 1
      },
      {
        'category': 'Content Marketing',
        'question': 'Manakah dari berikut ini yang merupakan contoh dari "User-Generated Content" (UGC)?',
        'options': [
          'A. Iklan video yang diproduksi oleh agensi profesional.',
          'B. Ulasan produk and foto unboxing yang diunggah oleh pelanggan asli.',
          'C. Postingan blog buatan tim marketing internal perusahaan.',
          'D. Brosur resmi spesifikasi teknis barang.'
        ],
        'correct': 1
      },
      // Page 8 (22-24)
      {
        'category': 'SEO (Search Engine Optimization)',
        'question': 'Apa fungsi utama dari file "robots.txt" pada sebuah website?',
        'options': [
          'A. Mempercepat loading halaman website.',
          'B. Memberikan instruksi kepada robot web crawler mengenai halaman mana yang boleh dan tidak boleh diindeks.',
          'C. Mencegah serangan hacker ke database.',
          'D. Menyimpan data login admin.'
        ],
        'correct': 1
      },
      {
        'category': 'Metrik Media Sosial',
        'question': 'Metrik "Reach" pada analytics media sosial mendeskripsikan...',
        'options': [
          'A. Jumlah total akun unik yang melihat konten Anda.',
          'B. Jumlah total klik ke profil akun Anda.',
          'C. Jumlah komentar dan suka pada postingan Anda.',
          'D. Berapa kali konten Anda dibagikan oleh audiens.'
        ],
        'correct': 0
      },
      {
        'category': 'Strategi Pemasaran',
        'question': 'Apa yang dimaksud dengan konsep "Funnel Marketing"?',
        'options': [
          'A. Alat penyaring data konsumen ilegal.',
          'B. Pemetaan perjalanan konsumen dari tahap sadar merek (awareness) hingga melakukan pembelian (action).',
          'C. Desain struktur organisasi tim marketing.',
          'D. Teknik penulisan konten email dengan cepat.'
        ],
        'correct': 1
      },
      // Page 9 (25-27)
      {
        'category': 'Iklan Berbayar',
        'question': 'Metrik "CTR" (Click-Through Rate) dihitung dengan rumus...',
        'options': [
          'A. (Total Klik / Total Impresi) x 100%',
          'B. (Total Impresi / Total Klik) x 100%',
          'C. Total Klik x Harga per Klik',
          'D. Total Biaya Iklan / Total Konversi'
        ],
        'correct': 0
      },
      {
        'category': 'Keamanan Website',
        'question': 'Protokol enkripsi keamanan data yang ditandai dengan ikon gembok dan awalan "https" di browser disebut...',
        'options': [
          'A. FTP',
          'B. SSL / TLS Certificate',
          'C. SMTP',
          'D. DNS Server'
        ],
        'correct': 1
      },
      {
        'category': 'Strategi Konten',
        'question': 'Pilar konten (Content Pillars) sangat berguna untuk...',
        'options': [
          'A. Mengurangi biaya hosting bulanan.',
          'B. Menentukan tema-tema utama pembahasan konten agar terstruktur dan konsisten.',
          'C. Memblokir komentar spam dari bot otomatis.',
          'D. Mendesain template logo perusahaan.'
        ],
        'correct': 1
      },
      // Page 10 (28-30)
      {
        'category': 'Analisis Kompetitor',
        'question': 'Melakukan analisis SWOT (Strengths, Weaknesses, Opportunities, Threats) bertujuan untuk...',
        'options': [
          'A. Menghapus produk gagal dari katalog.',
          'B. Memahami kelebihan, kelemahan diri, peluang pasar, serta tantangan dari kompetitor secara strategis.',
          'C. Mendaftarkan paten merk produk baru.',
          'D. Mengatur tata letak halaman produk e-commerce.'
        ],
        'correct': 1
      },
      {
        'category': 'Strategi Iklan',
        'question': 'Di dalam Google Ads, apa kegunaan dari "Negative Keywords"?',
        'options': [
          'A. Memblokir kompetitor agar tidak bisa melihat iklan kita.',
          'B. Mencegah iklan kita muncul untuk kata kunci pencarian yang tidak relevan dengan produk kita.',
          'C. Menurunkan nilai skor kualitas iklan.',
          'D. Menghapus iklan yang memiliki performa buruk secara otomatis.'
        ],
        'correct': 1
      },
      {
        'category': 'Digital Marketing',
        'question': 'Istilah "Omnichannel Marketing" berarti...',
        'options': [
          'A. Hanya menggunakan satu saluran promosi secara fokus.',
          'B. Mengintegrasikan berbagai saluran komunikasi dan penjualan secara mulus untuk memberikan pengalaman pelanggan yang konsisten.',
          'C. Menghentikan promosi digital dan beralih ke brosur fisik.',
          'D. Membeli domain website di lebih dari sepuluh negara.'
        ],
        'correct': 1
      }
    ];
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

  void _handleSubmitTest({bool autoSubmit = false}) {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _finalTimeSpent = _formatTime(3600 - _secondsRemaining);
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
    switch (_viewState) {
      case TestViewState.intro:
        return TesTertulisIntro(
          title: widget.title,
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
            final bool isLastPage = _currentPage == (_questions.isEmpty ? 0 : (_questions.length - 1) ~/ 3);
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
          title: widget.title,
          finalTimeSpent: _finalTimeSpent,
          onBackToHome: () {
            Navigator.pop(context); // Pops TesTertulisScreen
            Navigator.pop(context); // Pops HasilReviewPraAsesmenScreen / Dashboard
          },
        );
    }
  }

  // DIALOG CONFIRMATIONS
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

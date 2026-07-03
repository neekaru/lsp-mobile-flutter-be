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
  int _currentPage = 0; // Page 0 to 9 (3 questions per page)
  final Map<int, int> _answers = {}; // question index -> option index

  // Intro and Quiz start state
  bool _testStarted = false;

  // Countdown timer state
  Timer? _timer;
  int _secondsRemaining = 3600; // 60 minutes

  // Mock list of questions based on certification
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _initQuestions();
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
        'question': 'Dalam strategi Search Engine Optimization (SEO), apa yang dimaksud dengan komponen On-Page SEO?',
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _handleSubmitTest(autoSubmit: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

    _timer?.cancel();

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

    if (!_testStarted) {
      return _buildIntroScreen(statusBarHeight);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          _buildTimerHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildQuestionsList(),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildIntroScreen(double statusBarHeight) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                  'Tes Tertulis',
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
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blue Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tes Tertulis',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tahap terpenting untuk menguji kemampuan Anda sesuai Skema Sertifikasi',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF1E40AF),
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
                            Icons.assignment_rounded,
                            color: Color(0xFF3B82F6),
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informasi Tes Tertulis',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // White Info Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Skema Sertifikasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDD5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Belum Dikerjakan',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.assignment_outlined,
                          iconColor: const Color(0xFF3B82F6),
                          bgColor: const Color(0xFFDBEAFE),
                          title: 'Jumlah Soal',
                          subtitle: '${_questions.length} Soal',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoItem(
                          icon: Icons.workspace_premium_outlined,
                          iconColor: const Color(0xFFD97706),
                          bgColor: const Color(0xFFFEF3C7),
                          title: 'Nilai Kelulusan',
                          subtitle: '70 total nilai',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoItem(
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFDCFCE7),
                          title: 'Durasi Ujian',
                          subtitle: '60 Menit',
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
                              'Informasi Pengerjaan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint('1. Pastikan koneksi internet lancar'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('2. Kerjakan semua soal secara mandiri.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('3. Waktu akan berjalan setelah tes di mulai, sesuai dengan peraturan.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('4. Jawaban Anda akan tersimpan otomatis.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('5. Pastikan semua soal terjawab sebelum mengirim test atau waktu yang ditentukan habis.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _testStarted = true;
                            });
                            _startTimer();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9FD8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Mulai Test',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF92400E),
        height: 1.45,
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
                Icons.keyboard_arrow_left_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Text(
            'Tes Tertulis',
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

  Widget _buildTimerHeader() {
    final double progress = ((_currentPage + 1) * 3) / _questions.length;
    final bool timeWarning = _secondsRemaining < 300; // Warning if < 5 mins left

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${(_currentPage * 3) + 3} / ${_questions.length}',
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
                    _formatTime(_secondsRemaining),
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
    final int startIdx = _currentPage * 3;

    return Column(
      children: List.generate(3, (index) {
        final int globalIndex = startIdx + index;
        if (globalIndex >= _questions.length) return const SizedBox.shrink();

        final question = _questions[globalIndex];
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
    final selectedOption = _answers[globalIndex];

    return Column(
      children: List.generate(options.length, (index) {
        final bool isSelected = selectedOption == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _answers[globalIndex] = index;
            });
          },
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

  Widget _buildBottomNav() {
    final bool isLastPage = _currentPage == 9;

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
                  onPressed: () {
                    if (_currentPage > 0) {
                      setState(() {
                        _currentPage--;
                      });
                    } else {
                      _showExitConfirmationDialog();
                    }
                  },
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
                  onPressed: () {
                    if (isLastPage) {
                      _showSubmitConfirmationDialog();
                    } else {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  },
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

import 'package:flutter/material.dart';
import '../../widgets/bottom_menu_bar.dart';
import 'tes_tertulis_screen.dart';

class PraAsesmenScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const PraAsesmenScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<PraAsesmenScreen> createState() => _PraAsesmenScreenState();
}

class _PraAsesmenScreenState extends State<PraAsesmenScreen> {
  void _startWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PraAsesmenWizardScreen(
          skemaId: widget.skemaId,
          title: widget.title,
          kodeSkema: widget.kodeSkema,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarningBanner(),
                  const SizedBox(height: 24),
                  _buildMenuCard(
                    stepNum: "1",
                    title: "Informasi Skema",
                    subtitle: "Informasi detail skema yang telah Anda pilih",
                    badgeColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    icon: Icons.workspace_premium_rounded,
                    onTap: _startWizard,
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    stepNum: "2",
                    title: "Evaluasi Diri",
                    subtitle: "Nilai diri Anda dalam setiap kompetensi",
                    badgeColor: const Color(0xFFDCFCE7),
                    iconColor: const Color(0xFF16A34A),
                    icon: Icons.assignment_turned_in_rounded,
                    onTap: _startWizard,
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    stepNum: "3",
                    title: "Pernyataan Kesiapan",
                    subtitle: "Pernyataan dan Komitmen untuk mengikuti asessmen",
                    badgeColor: const Color(0xFFDBEAFE),
                    iconColor: const Color(0xFF2563EB),
                    icon: Icons.gpp_good_rounded,
                    onTap: _startWizard,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
      bottomNavigationBar: BottomMenuBar(
        selectedIndex: 2,
        onTap: (index) {
          Navigator.pop(context);
        },
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
            'Pra-Asessment',
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

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withValues(alpha: 0.5),
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Sebelum memulai asessmen, isi pra asessmen terlebih dahulu untuk Mengevaluasi kesiapan Anda',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String stepNum,
    required String title,
    required String subtitle,
    required Color badgeColor,
    required Color iconColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$stepNum. $title',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _startWizard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9FD8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Mulai Pra Asessmen',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PraAsesmenWizardScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const PraAsesmenWizardScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<PraAsesmenWizardScreen> createState() => _PraAsesmenWizardScreenState();
}

class _PraAsesmenWizardScreenState extends State<PraAsesmenWizardScreen> {
  int _currentStep = 1; // Step 1 to 4
  final Map<int, String> _answers = {}; // questionIndex -> 'ya' or 'tidak'

  // Step 3 controller/answers
  String _hasWorkExperience = 'ya'; // 'ya' or 'tidak'
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  // Step 4 agreements
  bool _agreement1 = false;
  bool _agreement2 = false;
  bool _agreement3 = false;
  bool _agreeTerms = false;

  final Map<String, List<Map<String, dynamic>>> _schemaUnits = {
    'Pemasaran Digital': [
      {'kode': 'M.70MKT00.010.2', 'judul': 'Mengolah Data Riset'},
      {'kode': 'M.70MKT00.013.1', 'judul': 'Melaksanakan Kegiatan Analisis di Media Sosial dan Media Bisnis Digital'},
      {'kode': 'G.46RIT00.055.1', 'judul': 'Melakukan Aktivitas Pemasaran Digital untuk Bisnis Ritel'},
      {'kode': 'M.70MKT00.012.1', 'judul': 'Menggunakan Media Sosial dan Aplikasi Daring(Online Tools)'},
      {'kode': 'M.70MKT00.014.1', 'judul': 'Mempersiapkan Konten Digital'},
    ],
    'Programmer (Web & Mobile Developer)': [
      {'kode': 'J.620100.001.01', 'judul': 'Mengimplementasikan Algoritma Pemrograman'},
      {'kode': 'J.620100.002.01', 'judul': 'Menggunakan Struktur Data'},
      {'kode': 'J.620100.003.01', 'judul': 'Menulis Kode dengan Prinsip Pemrograman Berorientasi Objek'},
      {'kode': 'J.620100.004.01', 'judul': 'Melakukan Debugging dan Pengujian Unit'},
    ],
  };

  List<Map<String, dynamic>> _getUnitKompetensi() {
    final String targetSkema = widget.title;
    if (_schemaUnits.containsKey(targetSkema)) {
      return _schemaUnits[targetSkema]!;
    }
    
    final normalizedTarget = targetSkema.toLowerCase();
    for (var key in _schemaUnits.keys) {
      final normalizedKey = key.toLowerCase();
      if (normalizedTarget == normalizedKey ||
          normalizedTarget.contains(normalizedKey) ||
          normalizedKey.contains(normalizedTarget)) {
        return _schemaUnits[key]!;
      }
    }

    return [
      {'kode': 'SKM.620100.001.01', 'judul': 'Mempersiapkan Lingkungan Kerja'},
      {'kode': 'SKM.620100.002.01', 'judul': 'Mengimplementasikan Fitur Utama'},
      {'kode': 'SKM.620100.003.01', 'judul': 'Melakukan Pengujian dan Dokumentasi'},
    ];
  }

  List<String> _getQuestions() {
    if (widget.title.toLowerCase().contains('pemasaran') || widget.title.toLowerCase().contains('marketing')) {
      return [
        'Mampukah anda melakukan riset pasar dan tren pemasaran digital',
        'Mampu membuat strategi pemasaran digital',
        'Mampu membuat konten pemasaran digital yang menarik dan efektif',
        'Mampu menjalankan kampanye pemasaran digital',
        'Mampu mengoperasikan tools pemasaran digital?(Meta Ads Manager, Google Ads, atau Tiktok Creative Center)',
      ];
    }
    
    final units = _getUnitKompetensi();
    return units.map((u) => 'Mampukah Anda melakukan kegiatan terkait unit "${u['judul']}" secara mandiri').toList();
  }

  @override
  void initState() {
    super.initState();
    final questions = _getQuestions();
    for (int i = 0; i < questions.length; i++) {
      _answers[i] = 'ya';
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      _showSuccessDialog();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedSuccessBadge(),
                const SizedBox(height: 24),
                const Text(
                  'Pra Asessment Telah Berhasil',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Terimakasih, Anda sudah berhasil mengirim Pra-Asessmen.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Dismiss Dialog
                      // Redirect to Hasil Review Pra-Asesmen Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HasilReviewPraAsesmenScreen(
                            skemaId: widget.skemaId,
                            title: widget.title,
                            kodeSkema: widget.kodeSkema,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9FD8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomActionButtons(),
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
            onTap: _prevStep,
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
            'Pra-Asessment',
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

  Widget _buildProgressBar() {
    final double progress = _currentStep / 4.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$_currentStep / 4',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Informasi Skema
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Skema',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Beirkut informasi skema yang Anda pilih',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.kodeSkema,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                _buildInfoRow('Tgl Asesmen', '20 Mei 2026'),
                const SizedBox(height: 12),
                _buildInfoRow('Tempat Uji Kompetensi', 'TUK Universitas LPP'),
                const SizedBox(height: 12),
                _buildInfoRow('Asessor', 'Belum Ditentukan'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: Evaluasi Kompetensi
  Widget _buildStep2() {
    final questions = _getQuestions();

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
    final bool isSelected = _answers[questionIndex] == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[questionIndex] = value;
        });
      },
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

  // STEP 3: Pengalaman Kerja
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengalaman Kerja',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Berikan informasi pengalaman kerja dalam bidang yang anda pilih, baik dalam bidang institusi/perusahaan.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        // Question Card
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
                '1. Apakah anda memiliki pengalaman kerja pada bidang yang anda pilih saat ini?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              _buildStep3RadioOption('Ya, saya punya', 'ya'),
              const SizedBox(height: 4),
              _buildStep3RadioOption('Tidak,saya tidak punya', 'tidak'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Experience details form fields
        _buildTextField('Nama Perusahaan/Instansi', 'Masukan nama lengkap', _companyController),
        const SizedBox(height: 16),
        _buildTextField('Posisi/Pekerjaan', 'Masukan jobdase atau posisi kerjaan', _positionController),
        const SizedBox(height: 16),
        _buildTextField('Lama Bekerja', 'Berapa lama bekerja', _durationController),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep3RadioOption(String text, String value) {
    final bool isSelected = _hasWorkExperience == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _hasWorkExperience = value;
        });
      },
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

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
        ),
      ],
    );
  }

  // STEP 4: Pernyataan Kesiapan & Persetujuan Asessi
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Peach warning/info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEEAD2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pastikan semua informasi sudah benar , Setelah dikirim,Anda tidak dapat lagi mengubah jawaban Anda.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Prenyataan Kesiapan & Persetujuan Asessi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bacalah pernyataan berikut dengan seksama sebelum mengirimkan Pra-Asessment',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _buildStatementCard(
          "Saya telah membaca dan memahami seluruh persyaratan dan peraturan asessmen yang berlaku.",
          _agreement1,
          (val) => setState(() => _agreement1 = val),
        ),
        _buildStatementCard(
          "Seluruh informasi yang telah saya berikan adalah benar dan dapat dipertanggung jawabkan.",
          _agreement2,
          (val) => setState(() => _agreement2 = val),
        ),
        _buildStatementCard(
          "Saya bersedia mengikuti asessmen sesuai jadwal dan ketentuan yang telah ditetapkan oleh pihak LSP.",
          _agreement3,
          (val) => setState(() => _agreement3 = val),
        ),
        const SizedBox(height: 12),
        // Square Checkbox Agreement at bottom
        CheckboxListTile(
          value: _agreeTerms,
          onChanged: (val) {
            setState(() {
              _agreeTerms = val ?? false;
            });
          },
          title: const Text(
            'Saya setuju dengan syarat dan ketentuan diatas',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildStatementCard(String text, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                child: value
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    final bool isStep3Valid = _currentStep != 3 || 
        (_hasWorkExperience == 'tidak' || 
         (_companyController.text.isNotEmpty && 
          _positionController.text.isNotEmpty && 
          _durationController.text.isNotEmpty));
          
    final bool isStep4Valid = _currentStep != 4 || 
        (_agreement1 && _agreement2 && _agreement3 && _agreeTerms);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _prevStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1D1D6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (isStep3Valid && isStep4Valid) ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 4 ? 'Kirim Jawaban' : 'Selanjutnya',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentStep == 4 ? Icons.send_rounded : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
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

class AnimatedSuccessBadge extends StatefulWidget {
  const AnimatedSuccessBadge({super.key});

  @override
  State<AnimatedSuccessBadge> createState() => _AnimatedSuccessBadgeState();
}

class _AnimatedSuccessBadgeState extends State<AnimatedSuccessBadge> with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _badgeController.forward().then((_) {
      _checkController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _badgeScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F4E9),
              shape: BoxShape.circle,
            ),
          ),
          // Inner circle
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
            child: ScaleTransition(
              scale: _checkScale,
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Decorative floating dots to match screenshot bubbles
          Positioned(
            top: 10,
            left: 10,
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
          ),
          Positioned(
            top: 30,
            left: 0,
            child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: 25,
            left: 5,
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
          ),
        ],
      ),
    );
  }
}

class HasilReviewPraAsesmenScreen extends StatelessWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const HasilReviewPraAsesmenScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    
    // Normalize name to Digital Marketing to match mock layout nicely
    final String displayTitle = title.toLowerCase().contains('pemasaran') || title.toLowerCase().contains('marketing')
        ? 'Digital Marketing'
        : title;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 20),
                  _buildDetailCard(displayTitle),
                  const SizedBox(height: 16),
                  _buildEmptyCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
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
            'Hasil Review Pra-Asessmen',
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

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF22C55E),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Status Review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14532D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Anda memenuhi persyaratan untuk mengikuti Tes Tertulis.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF166534),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String displayTitle) {
    return Container(
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Text(
                          'LPP Jogja',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 10,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Yogyakarta',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          _buildChecklistItem('Portofolio Lengkap'),
          const SizedBox(height: 12),
          _buildChecklistItem('Bukti Kompetensi Valid'),
          const SizedBox(height: 12),
          _buildChecklistItem('Pra Asesmen Disetujui'),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Color(0xFF16A34A),
              size: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TesTertulisScreen(
                    skemaId: skemaId,
                    title: title,
                    kodeSkema: kodeSkema,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9FD8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Mulai Tes Tertulis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class TugasTanggungJawabScreen extends StatefulWidget {
  const TugasTanggungJawabScreen({super.key});

  @override
  State<TugasTanggungJawabScreen> createState() => _TugasTanggungJawabScreenState();
}

class _TugasTanggungJawabScreenState extends State<TugasTanggungJawabScreen> {
  int _selectedTabIndex = 0; // 0 for Unsur Pengurus, 1 for Unsur Pengarah

  final List<Map<String, dynamic>> _pengurusData = [
    {
      'title': 'Direktur Eksekutif (PENGURUS HARIAN)',
      'points': [
        'Menetapkan sasaran mutu',
        'Melakukan tinjauan manajemen',
        'Pengelolaan sumberdaya',
        'Mengawasi pengelolaan keuangan di LSP',
        'Monitoring dan evaluasi kegiatan LSP Teknologi Digital',
        'Pengaturan kontrak.'
      ]
    },
    {
      'title': 'Bendahara',
      'points': [
        'Mengelola keuangan LSP',
        'Membuat laporan keuangan bulanan dan tahunan',
        'Mengelola sistem perpajakan LSP.'
      ]
    },
    {
      'title': 'Manajer Mutu',
      'points': [
        'Mengembangkan dan menerapkan sistem manajemen mutu, terhadap pedoman BNSP yang berlaku (PBNSP 201 dan 202) dan SNI ISO 17024 : 2012',
        'Memastikan dan memelihara secara konsisten penerapan sistem manajemen sesuai dengan standar dan pedoman yang diacu',
        'Melakukan audit internal dan memfasilitasi kaji ulang manajemen',
        'Melakukan dan menjaga penerapan standarisasi dalam pelaksanaan proses sertifikasi kompetensi.'
      ]
    },
    {
      'title': 'Manajer Sertifikasi',
      'points': [
        'Menyiapkan perangkat asesmen dan materi uji',
        'Sebagai koordinator pelaksanaan sertifikasi, termasuk pemeliharaan kompetensi dan sertifikasi ulang',
        'Melakukan surveilance kepada semua pemegang sertifikat',
        'Menetapkan persyaratan tempat uji (TUK)',
        'Sebagai koordinator dari asesor lisensi , asesor kompetensi, dan tenaga ahli',
        'Memfasilitasi hubungan dengan TUK dalam fungsi memelihara informasi sertifikasi kompetensi',
        'Mengecek kesiapan TUK sebelum pelaksanaan proses uji kompetensi.'
      ]
    },
    {
      'title': 'Manajer Pengelola LSP',
      'points': [
        'Mengkoordinasikan komunikasi dan supervisi antar bagian',
        'Manajer representative untuk pengembangan LSP'
      ]
    },
    {
      'title': 'Manajer Administrasi',
      'points': [
        'Memfasilitasi unsur-unsur LSP Teknologi Digital guna terselenggaranya program sertifikasi profesi (contoh : surat menyurat, kesiapan dokumen TUK)',
        'Memfalisitasi dan mengelola serta mengevaluasi sistem administrasi LSP Teknologi Digital',
        'Sebagai administrator pelaksanaan sistem sertifikasi dan tugas-tugas ketatausahaan organisasi LSP',
        'Membangun sistim informasi berbasis web dan aplikasi registrasi online',
        'Mempersiapkan laporan kegiatan LSP',
        'Melakukan rekrutmen asesor kompetensi serta pemeliharaan kompetensinya.'
      ]
    },
    {
      'title': 'Manajer IT',
      'points': [
        'Mengelola dan mengembangkan website',
        'Mengelola dan mengembangkan apps',
        'Integrasi sistem LSP dan BNSP',
        'Integrasi sistem LSP dengan Mitra'
      ]
    },
    {
      'title': 'Komite Teknis',
      'points': [
        'Mengembangkan dan mengevaluasi perangkat asesmen, metode uji kompetensi, materi uji kompetensi, dan bank soal.'
      ]
    },
    {
      'title': 'Asesor Lisensi',
      'points': [
        'Melaksanakan verifikasi calon TUK.'
      ]
    },
    {
      'title': 'Asesor Kompetensi',
      'points': [
        'Merencanakan, mengembangkan proses uji kompetensi',
        'Melaksanakan proses uji kompetensi',
        'Melakukan evaluasi atas proses uji kompetensi yang telah dilakukan',
        'Membuat laporan hasil uji kompetensi.'
      ]
    },
    {
      'title': 'Tenaga Ahli / Subject Specialyst',
      'points': [
        'Membantu asesor kompetensi melaksanakan Uji Kompetensi sesuai bidang teknis yang diujikan.'
      ]
    }
  ];

  final List<Map<String, dynamic>> _pengarahData = [
    {
      'title': 'Dewan Pengurus dan Ketidakberpihakan',
      'points': [
        'Menetapkan visi, misi dan tujuan LSP Teknologi Digital',
        'Memberikan arah dari program kerja LSP secara periodik',
        'Bertindak sebagai komunikator dan fasilitator dengan stake holder',
        'Memastikan sumberdaya tersertifikasi bisa matching dengan kebutuhan industri',
        'Memobilisasi sumberdaya dan mencarikan sponsor yang tidak mengikat',
        'Bertanggungjawab terhadap pengawasan ketidakberpihakan.'
      ]
    },
    {
      'title': 'Komite Skema',
      'points': [
        'Menyusun dan mengembangkan skema sertifikasi',
        'Kaji ulang skema sertifikasi , minimal satu kali setahun.'
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final activeData = _selectedTabIndex == 0 ? _pengurusData : _pengarahData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Tugas & Tanggung Jawab',
          ),
          
          // Tab Bar Container
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? const Color(0xFF708CAE)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'Unsur Pengurus',
                          style: TextStyle(
                            color: _selectedTabIndex == 0
                                ? Colors.white
                                : const Color(0xFF5A7EAA),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? const Color(0xFF708CAE)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'Unsur Pengarah',
                          style: TextStyle(
                            color: _selectedTabIndex == 1
                                ? Colors.white
                                : const Color(0xFF5A7EAA),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Accordion List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: activeData.length,
              itemBuilder: (context, index) {
                final item = activeData[index];
                return CustomAccordionItem(
                  title: item['title'] as String,
                  bulletPoints: List<String>.from(item['points'] as List),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAccordionItem extends StatefulWidget {
  final String title;
  final List<String> bulletPoints;

  const CustomAccordionItem({
    super.key,
    required this.title,
    required this.bulletPoints,
  });

  @override
  State<CustomAccordionItem> createState() => _CustomAccordionItemState();
}

class _CustomAccordionItemState extends State<CustomAccordionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Card
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x02000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right_rounded,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Expanded Content Card
        if (_isExpanded) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x02000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.bulletPoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

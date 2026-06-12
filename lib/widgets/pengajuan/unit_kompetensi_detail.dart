import 'package:flutter/material.dart';

class UnitKompetensiDetail extends StatefulWidget {
  final String unitKode;
  final String unitJudul;
  final String kukCount;
  final Map<String, String?> uploadedFileNames;
  final Map<String, bool?> kukAssessments; // maps KUK text to K/KB status (true = K, false = KB, null = unselected)
  final Map<String, String?> kukEvidence;   // maps KUK text to linked file name
  final Function(String kukText, bool? isKompeten) onAssessmentChanged;
  final Function(String kukText, String? fileName) onEvidenceChanged;
  final VoidCallback onKembali;
  final VoidCallback onSelesai;

  const UnitKompetensiDetail({
    super.key,
    required this.unitKode,
    required this.unitJudul,
    required this.kukCount,
    required this.uploadedFileNames,
    required this.kukAssessments,
    required this.kukEvidence,
    required this.onAssessmentChanged,
    required this.onEvidenceChanged,
    required this.onKembali,
    required this.onSelesai,
  });

  @override
  State<UnitKompetensiDetail> createState() => _UnitKompetensiDetailState();
}

class _UnitKompetensiDetailState extends State<UnitKompetensiDetail> {
  // Store expanded state of each element card
  final Map<int, bool> _expandedElements = {
    0: true, // Expand the first element by default
  };

  // Mock Elements and KUK list based on unit title
  List<Map<String, dynamic>> _getElementsForUnit() {
    if (widget.unitKode.contains('RIT')) {
      return [
        {
          'title': 'Melakukan riset pasar dan tren pemasaran digital',
          'kukCount': '4 KUK',
          'kuks': [
            'Melakukan Aktivitas Pemasaran Digital untuk Bisnis Ritel',
            'melakukan Riset pasar dari sumber-sumber terpercaya untuk menentukan kebutuhan pelanggan',
            'mengidentifikasi Tren perkembangan pemasaran digital dan manfaat penggunaannya bagi bisnis ritel',
            'menyesuaikan Hasil penelitian dengan kebijakan dan prosedur perusahaan',
          ]
        },
        {
          'title': 'Melakukan aktivitas pemasaran digital',
          'kukCount': '5 KUK',
          'kuks': [
            'Memilih platform media sosial yang sesuai dengan segmen bisnis ritel',
            'Membuat profil bisnis ritel di media sosial resmi',
            'Membuat konten penawaran produk ritel yang menarik',
            'Menanggapi komentar dan pesan dari pelanggan secara responsif',
            'Mengevaluasi insight postingan berkala',
          ]
        }
      ];
    } else if (widget.unitKode.contains('OPR')) {
      return [
        {
          'title': 'Mempersiapkan penggunaan perangkat komputer',
          'kukCount': '3 KUK',
          'kuks': [
            'Memeriksa kabel daya dan periferal komputer terpasang dengan benar',
            'Menyalakan tombol daya utama sesuai dengan SOP',
            'Melakukan login menggunakan user ID dan password yang sah',
          ]
        },
        {
          'title': 'Mengoperasikan sistem komputer',
          'kukCount': '5 KUK',
          'kuks': [
            'Membuka aplikasi perkantoran yang dibutuhkan',
            'Menyimpan file dokumen ke media penyimpanan lokal atau cloud',
            'Menggunakan fitur pencarian file pada direktori',
            'Melakukan pencetakan dokumen ke printer aktif',
            'Mematikan komputer (shutdown) sesuai prosedur keselamatan',
          ]
        }
      ];
    } else {
      // Default fallback elements
      return [
        {
          'title': 'Mengidentifikasi kebutuhan analisis kompetensi',
          'kukCount': '3 KUK',
          'kuks': [
            'Mempelajari dokumen panduan standar operasional skema',
            'Mengumpulkan bukti-bukti mandiri secara sistematis',
            'Menyesuaikan bukti dengan kriteria unjuk kerja',
          ]
        },
        {
          'title': 'Melaksanakan asesmen mandiri secara mandiri',
          'kukCount': '3 KUK',
          'kuks': [
            'Mengisi form FR-APL 02 dengan jujur dan teliti',
            'Menyertakan dokumen bukti pendukung portofolio relevan',
            'Menandatangani pernyataan mandiri komitmen',
          ]
        }
      ];
    }
  }

  void _showEvidencePicker(BuildContext context, String kukText) {
    // Get list of uploaded documents in Step 3
    final availableFiles = widget.uploadedFileNames.values.whereType<String>().toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Pilih Bukti Portofolio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          content: availableFiles.isEmpty
              ? const Text(
                  'Belum ada file bukti yang diupload di tahap sebelumnya. Silakan kembali ke tahap Dokumen Portofolio.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableFiles.length,
                    itemBuilder: (context, index) {
                      final fileName = availableFiles[index];
                      final isSelected = widget.kukEvidence[kukText] == fileName;

                      return ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF5350)),
                        title: Text(
                          fileName,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF378CE7))
                            : null,
                        onTap: () {
                          widget.onEvidenceChanged(kukText, fileName);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            if (widget.kukEvidence[kukText] != null)
              TextButton(
                onPressed: () {
                  widget.onEvidenceChanged(kukText, null); // Clear evidence
                  Navigator.pop(context);
                },
                child: const Text('Hapus Bukti', style: TextStyle(color: Colors.red)),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final elements = _getElementsForUnit();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Unit Card Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.unitKode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF378CE7)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.unitJudul,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.kukCount,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List of elements
        ...elements.asMap().entries.map((entry) {
          final index = entry.key;
          final el = entry.value;
          final isExpanded = _expandedElements[index] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Element Title row
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedElements[index] = !isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + index)}.', // A, B, C...
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                el['title'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                el['kukCount'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Layout headers if expanded
                        if (isExpanded) ...[
                          const Text('K', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(width: 20),
                          const Text('KB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(width: 8),
                        ] else ...[
                          const Icon(Icons.keyboard_arrow_right, color: Color(0xFF378CE7)),
                        ],
                      ],
                    ),
                  ),
                ),

                // KUK details if expanded
                if (isExpanded) ...[
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  ...List.generate((el['kuks'] as List).length, (kukIndex) {
                    final kukText = el['kuks'][kukIndex] as String;
                    final bool? isK = widget.kukAssessments[kukText];
                    final linkedEvidence = widget.kukEvidence[kukText];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  kukText,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF334155),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Radio choices
                              Row(
                                children: [
                                  // K
                                  GestureDetector(
                                    onTap: () => widget.onAssessmentChanged(kukText, true),
                                    child: Icon(
                                      isK == true ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: const Color(0xFF378CE7),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // KB
                                  GestureDetector(
                                    onTap: () => widget.onAssessmentChanged(kukText, false),
                                    child: Icon(
                                      isK == false ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: const Color(0xFF378CE7),
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Pilih Bukti Button / Linked evidence tag
                          Row(
                            children: [
                              SizedBox(
                                height: 28,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showEvidencePicker(context, kukText),
                                  icon: const Icon(Icons.attach_file, size: 12),
                                  label: Text(
                                    linkedEvidence != null ? 'Bukti Terpilih' : 'Pilih Bukti',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: linkedEvidence != null ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                                    foregroundColor: linkedEvidence != null ? const Color(0xFF2E7D32) : const Color(0xFF475569),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              if (linkedEvidence != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    linkedEvidence,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

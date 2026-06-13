// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../widgets/pengajuan/step_indicator.dart';
import '../../widgets/pengajuan/evidence_picker_sheet.dart';
import '../../utils/asesmen_mandiri_data.dart';

class AsesmenMandiriUjiScreen extends StatefulWidget {
  final String selectedSkema;
  final List<Map<String, dynamic>> unitKompetensi;
  final Map<String, String?> uploadedFileNames;
  final Map<String, bool?> kukAssessments; // nullable bool to support unselected state
  final Map<String, String?> kukEvidence;
  final Function(String kukText, bool? isKompeten) onAssessmentChanged;
  final Function(String kukText, String? fileName) onEvidenceChanged;

  const AsesmenMandiriUjiScreen({
    super.key,
    required this.selectedSkema,
    required this.unitKompetensi,
    required this.uploadedFileNames,
    required this.kukAssessments,
    required this.kukEvidence,
    required this.onAssessmentChanged,
    required this.onEvidenceChanged,
  });

  @override
  State<AsesmenMandiriUjiScreen> createState() => _AsesmenMandiriUjiScreenState();
}

class _AsesmenMandiriUjiScreenState extends State<AsesmenMandiriUjiScreen> {
  int? _activeUnitIndex;

  // Local state for tracking uploads in this screen session
  late List<String> _localUploadedFiles;

  @override
  void initState() {
    super.initState();
    // Gather all existing files that are uploaded
    _localUploadedFiles = widget.uploadedFileNames.values
        .whereType<String>()
        .toList();
    if (_localUploadedFiles.isEmpty) {
      // Seed some default mock files so list isn't empty
      _localUploadedFiles = [
        'Bukti_Pelatihan_12042026.PDF',
        'Sertifikat_Digital_Marketing_2025.PDF',
        'Portofolio_Campaign_Ritel.PDF',
      ];
    }
  }

  void _showEvidencePickerSheet(BuildContext context, String kukText) async {
    final selectedFile = await EvidencePickerSheet.show(
      context,
      kukText: kukText,
      initialEvidence: widget.kukEvidence[kukText],
      uploadedFiles: _localUploadedFiles,
      onFileUploaded: (newFileName) {
        setState(() {
          _localUploadedFiles.insert(0, newFileName);
        });
      },
    );
    if (selectedFile != null) {
      widget.onEvidenceChanged(kukText, selectedFile);
      setState(() {});
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Semua Elemen Kompetensi atau KUK harus Kompeten',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
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
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          // Hide StepIndicator if in detail view
          if (_activeUnitIndex == null)
            const StepIndicator(currentStep: 5), // Step 5 shows Asesmen Mandiri active
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: _activeUnitIndex == null ? _buildUnitList() : _buildUnitDetail(),
              ),
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
            onTap: () {
              if (_activeUnitIndex != null) {
                setState(() {
                  _activeUnitIndex = null;
                });
              } else {
                Navigator.pop(context);
              }
            },
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
          Text(
            _activeUnitIndex != null ? 'Detail Uji Kompetensi' : 'Asesmen Mandiri',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
        ],
      ),
    );
  }

  Widget _buildUnitList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Skema Title header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              'Skema ${widget.selectedSkema}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // List of unit cards
        ...List.generate(widget.unitKompetensi.length, (index) {
          final unit = widget.unitKompetensi[index];
          final kode = unit['kode'] as String? ?? '';
          final judul = unit['judul'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeUnitIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontSize: 12.5,
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
                            kode,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AsesmenMandiriData.getKukCount(kode),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: Color(0xFF378CE7),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // "Lihat Semua Unit Kompetensi" card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      color: Color(0xFF378CE7),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lihat Semua Unit Kompetensi',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F4C81),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.unitKompetensi.length} Unit',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Color(0xFF378CE7),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitDetail() {
    final unit = widget.unitKompetensi[_activeUnitIndex!];
    final String kode = unit['kode'] as String? ?? '';
    final String judul = unit['judul'] as String? ?? '';
    final elements = AsesmenMandiriData.getElementsForUnit(kode);

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
                    kode,
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
                judul,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AsesmenMandiriData.getKukCount(kode),
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
          final elIndex = entry.key;
          final el = entry.value;

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
                // Element Header Row with K & KB labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        '${String.fromCharCode(65 + elIndex)}.', // A, B...
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
                                  color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              el['kukCount'] as String,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'K',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 28),
                      const Text(
                        'KB',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 1),

                // KUK items
                ...List.generate((el['kuks'] as List).length, (kukIndex) {
                  final kukText = el['kuks'][kukIndex] as String;
                  // Get KUK assessment from widget state (nullable)
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
                                  color: Color(0xFF475569),
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // K / KB Radio options
                            Row(
                              children: [
                                // K Radio Button
                                GestureDetector(
                                  onTap: () {
                                    widget.onAssessmentChanged(kukText, true);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    isK == true ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                    color: const Color(0xFF378CE7),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 22),
                                // KB Radio Button
                                GestureDetector(
                                  onTap: () {
                                    widget.onAssessmentChanged(kukText, false);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    isK == false ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                    color: const Color(0xFF378CE7),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Pilih Bukti Button / Linked Evidence
                        Row(
                          children: [
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () => _showEvidencePickerSheet(context, kukText),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  foregroundColor: const Color(0xFF475569),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(color: Colors.grey[200]!),
                                  ),
                                ),
                                child: Text(
                                  linkedEvidence != null ? 'Bukti Terpilih' : 'Pilih Bukti',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            if (linkedEvidence != null) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        linkedEvidence,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActionButtons() {
    if (_activeUnitIndex != null) {
      // Buttons in detail page: Kembali, Selesai dan Kirim
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _activeUnitIndex = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: const Color(0xFFE2E8F0),
                      side: BorderSide.none,
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
                          SizedBox(width: 6),
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
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate if all KUKs in the current unit are marked Kompeten (K)
                      final unit = widget.unitKompetensi[_activeUnitIndex!];
                      final elements = AsesmenMandiriData.getElementsForUnit(unit['kode'] as String);
                      bool allSelectedK = true;

                      for (var el in elements) {
                        for (var kuk in el['kuks']) {
                          final assessment = widget.kukAssessments[kuk];
                          if (assessment != true) {
                            allSelectedK = false;
                            break;
                          }
                        }
                        if (!allSelectedK) break;
                      }

                      if (!allSelectedK) {
                        _showErrorDialog();
                      } else {
                        // All KUKs are Kompeten, go back to unit list
                        setState(() {
                          _activeUnitIndex = null;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
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
                          Text(
                            'Selesai dan Kirim',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 18),
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

    // Buttons in list page: Kembali, Selanjutnya
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    backgroundColor: const Color(0xFFE2E8F0),
                    side: BorderSide.none,
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
                        SizedBox(width: 6),
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
          ],
        ),
      ),
    );
  }
}

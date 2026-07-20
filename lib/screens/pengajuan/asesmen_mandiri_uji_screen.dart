// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/pengajuan/step_indicator.dart';
import '../../widgets/pengajuan/evidence_picker_sheet.dart';

class AsesmenMandiriUjiScreen extends StatefulWidget {
  final String selectedSkema;
  /// Each: kode, judul, kuk_count, elemen: [{id_elemen, text}]
  final List<Map<String, dynamic>> unitKompetensi;
  final Map<String, String?> uploadedFileNames;
  /// key = id_elemen as String
  final Map<String, bool?> kukAssessments;
  final Map<String, String?> kukEvidence;
  final Function(String elemenKey, bool? isKompeten) onAssessmentChanged;
  final Function(String elemenKey, String? fileName) onEvidenceChanged;

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
  State<AsesmenMandiriUjiScreen> createState() =>
      _AsesmenMandiriUjiScreenState();
}

class _AsesmenMandiriUjiScreenState extends State<AsesmenMandiriUjiScreen> {
  int? _activeUnitIndex;
  late List<String> _localUploadedFiles;

  @override
  void initState() {
    super.initState();
    _localUploadedFiles =
        widget.uploadedFileNames.values.whereType<String>().toList();
  }

  void _showEvidencePickerSheet(BuildContext context, String elemenKey) async {
    final selectedFile = await EvidencePickerSheet.show(
      context,
      kukText: elemenKey,
      initialEvidence: widget.kukEvidence[elemenKey],
      uploadedFiles: _localUploadedFiles,
      onFileUploaded: (newFileName) {
        setState(() {
          _localUploadedFiles.insert(0, newFileName);
        });
      },
    );
    if (selectedFile != null) {
      widget.onEvidenceChanged(elemenKey, selectedFile);
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B), size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Lengkapi Penilaian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semua item KUK pada unit ini harus dinilai Kompeten (K) sebelum lanjut.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mengerti'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupsOf(Map<String, dynamic> unit) {
    final el = unit['elemen'];
    if (el is List) {
      return el.map((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{};
      }).toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> _itemsOfGroup(Map<String, dynamic> group) {
    final raw = group['items'];
    if (raw is List) {
      return raw.map((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{};
      }).toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> _allItemsOf(Map<String, dynamic> unit) {
    final out = <Map<String, dynamic>>[];
    for (final g in _groupsOf(unit)) {
      out.addAll(_itemsOfGroup(g));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: top + 8),
          CustomAppBar(
            title: _activeUnitIndex != null
                ? 'Detail Uji Kompetensi'
                : 'Asesmen Mandiri',
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: StepIndicator(currentStep: 5),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _activeUnitIndex == null
                  ? _buildUnitList()
                  : _buildUnitDetail(),
            ),
          ),
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUnitList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (widget.unitKompetensi.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Unit kompetensi belum dimuat. Pilih skema dulu.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          )
        else
          ...List.generate(widget.unitKompetensi.length, (index) {
            final unit = widget.unitKompetensi[index];
            final kode = unit['kode'] as String? ?? '';
            final judul = unit['judul'] as String? ?? '';
            final kukLabel = unit['kuk_count'] as String? ??
                '${_elemenOf(unit).length} item';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: InkWell(
                onTap: () => setState(() => _activeUnitIndex = index),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              kukLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right_rounded,
                          color: Color(0xFF378CE7), size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildUnitDetail() {
    final unit = widget.unitKompetensi[_activeUnitIndex!];
    final String kode = unit['kode'] as String? ?? '';
    final String judul = unit['judul'] as String? ?? '';
    final groups = _groupsOf(unit);
    final allItems = _allItemsOf(unit);
    final kukLabel =
        unit['kuk_count'] as String? ?? '${allItems.length} item';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF378CE7)),
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
                kukLabel,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Belum ada elemen/KUK untuk unit ini.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          )
        else
          ...groups.asMap().entries.map((entry) {
            final gIdx = entry.key;
            final group = entry.value;
            final title = group['title'] as String? ?? 'Elemen';
            final items = _itemsOfGroup(group);
            final countLabel =
                group['kuk_count'] as String? ?? '${items.length} item';

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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + gIdx)}.',
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
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                countLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text('K',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B))),
                        const SizedBox(width: 28),
                        const Text('KB',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B))),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  ...items.map((item) {
                    final itemKey = item['key']?.toString() ?? '';
                    final text = item['text'] as String? ?? '';
                    final bool? isK = widget.kukAssessments[itemKey];
                    final linkedEvidence = widget.kukEvidence[itemKey];

                    return RepaintBoundary(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Color(0xFFF1F5F9))),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF475569),
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        widget.onAssessmentChanged(
                                            itemKey, true);
                                        setState(() {});
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(11),
                                        child: Icon(
                                          isK == true
                                              ? Icons
                                                  .radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: const Color(0xFF378CE7),
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        widget.onAssessmentChanged(
                                            itemKey, false);
                                        setState(() {});
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(11),
                                        child: Icon(
                                          isK == false
                                              ? Icons
                                                  .radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: const Color(0xFF378CE7),
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () => _showEvidencePickerSheet(
                                        context, itemKey),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      foregroundColor: const Color(0xFF475569),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      linkedEvidence != null
                                          ? 'Bukti Terpilih'
                                          : 'Pilih Bukti',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                if (linkedEvidence != null) ...[
                                  const SizedBox(width: 12),
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
                              ],
                            ),
                          ],
                        ),
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
                    onPressed: () => setState(() => _activeUnitIndex = null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: const Color(0xFFE2E8F0),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Kembali',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
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
                      final items =
                          _allItemsOf(widget.unitKompetensi[_activeUnitIndex!]);
                      final allK = items.every((item) {
                        final key = item['key']?.toString() ?? '';
                        return widget.kukAssessments[key] == true;
                      });
                      if (!allK) {
                        _showErrorDialog();
                      } else {
                        setState(() => _activeUnitIndex = null);
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Selesai dan Kirim',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Kembali',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
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
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378CE7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Selesai & Kirim',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(width: 6),
                      Icon(Icons.check_rounded, size: 18),
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

import 'package:flutter/material.dart';

class UnitKompetensiDetail extends StatefulWidget {
  final String unitKode;
  final String unitJudul;
  final String kukCount;
  /// Nested: [{id_elemen, title, kuk_count, items: [{key, id_elemen, id_kuk, text}]}]
  final List<Map<String, dynamic>> elemenGroups;
  final Map<String, String?> uploadedFileNames;
  /// key = assessable key (k:{id_kuk} | e:{id_elemen})
  final Map<String, bool?> kukAssessments;
  final Map<String, String?> kukEvidence;
  final Function(String itemKey, bool? isKompeten) onAssessmentChanged;
  final Function(String itemKey, String? fileName) onEvidenceChanged;
  final VoidCallback onKembali;
  final VoidCallback onSelesai;

  const UnitKompetensiDetail({
    super.key,
    required this.unitKode,
    required this.unitJudul,
    required this.kukCount,
    required this.elemenGroups,
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
  final Map<int, bool> _expanded = {0: true};

  List<Map<String, dynamic>> _itemsOf(Map<String, dynamic> group) {
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

  void _showEvidencePicker(BuildContext context, String itemKey) {
    final availableFiles =
        widget.uploadedFileNames.values.whereType<String>().toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Pilih Bukti Portofolio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
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
                      final isSelected =
                          widget.kukEvidence[itemKey] == fileName;

                      return ListTile(
                        leading: const Icon(Icons.picture_as_pdf,
                            color: Color(0xFFEF5350)),
                        title: Text(
                          fileName,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF378CE7))
                            : null,
                        onTap: () {
                          widget.onEvidenceChanged(itemKey, fileName);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
            if (widget.kukEvidence[itemKey] != null)
              TextButton(
                onPressed: () {
                  widget.onEvidenceChanged(itemKey, null);
                  Navigator.pop(context);
                },
                child: const Text('Hapus Bukti',
                    style: TextStyle(color: Colors.red)),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.elemenGroups;

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
                    widget.unitKode,
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
            final isExpanded = _expanded[gIdx] ?? false;
            final title = group['title'] as String? ?? 'Elemen';
            final items = _itemsOf(group);
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
                  InkWell(
                    onTap: () =>
                        setState(() => _expanded[gIdx] = !isExpanded),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
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
                          if (isExpanded) ...[
                            const Text('K',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569))),
                            const SizedBox(width: 20),
                            const Text('KB',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569))),
                            const SizedBox(width: 8),
                          ] else
                            const Icon(Icons.keyboard_arrow_right,
                                color: Color(0xFF378CE7)),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded) ...[
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
                                bottom:
                                    BorderSide(color: Color(0xFFF1F5F9))),
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
                                        color: Color(0xFF334155),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => widget
                                            .onAssessmentChanged(itemKey, true),
                                        child: Padding(
                                          padding: const EdgeInsets.all(11),
                                          child: Icon(
                                            isK == true
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: const Color(0xFF378CE7),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => widget
                                            .onAssessmentChanged(
                                                itemKey, false),
                                        child: Padding(
                                          padding: const EdgeInsets.all(11),
                                          child: Icon(
                                            isK == false
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: const Color(0xFF378CE7),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showEvidencePicker(
                                          context, itemKey),
                                      icon: const Icon(Icons.attach_file,
                                          size: 12),
                                      label: Text(
                                        linkedEvidence != null
                                            ? 'Bukti Terpilih'
                                            : 'Pilih Bukti',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: linkedEvidence != null
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFF1F5F9),
                                        foregroundColor: linkedEvidence != null
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFF475569),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
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

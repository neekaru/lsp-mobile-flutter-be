// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

/// One selectable evidence row. [id] is unique even when [name] collides.
class _EvidenceItem {
  final String id;
  final String name;

  const _EvidenceItem({required this.id, required this.name});
}

class EvidencePickerSheet extends StatefulWidget {
  final String kukText;
  final String? initialEvidence;
  final List<String> initialUploadedFiles;
  final Function(String fileName) onFileUploaded;

  const EvidencePickerSheet({
    super.key,
    required this.kukText,
    required this.initialEvidence,
    required this.initialUploadedFiles,
    required this.onFileUploaded,
  });

  static Future<String?> show(
    BuildContext context, {
    required String kukText,
    required String? initialEvidence,
    required List<String> uploadedFiles,
    required Function(String fileName) onFileUploaded,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EvidencePickerSheet(
          kukText: kukText,
          initialEvidence: initialEvidence,
          initialUploadedFiles: uploadedFiles,
          onFileUploaded: onFileUploaded,
        );
      },
    );
  }

  @override
  State<EvidencePickerSheet> createState() => _EvidencePickerSheetState();
}

class _EvidencePickerSheetState extends State<EvidencePickerSheet> {
  late List<_EvidenceItem> _items;
  /// Unique id of the selected row — never the display name alone.
  String? _selectedId;
  int _idSeq = 0;

  String _nextId(String name) {
    _idSeq++;
    return 'ev_${_idSeq}_${name.hashCode}_${DateTime.now().microsecondsSinceEpoch}';
  }

  List<_EvidenceItem> _toItems(List<String> names) {
    return names.map((n) => _EvidenceItem(id: _nextId(n), name: n)).toList();
  }

  @override
  void initState() {
    super.initState();
    _items = _toItems(widget.initialUploadedFiles);
    // Restore selection by first matching name (unique id still one row only)
    final initial = widget.initialEvidence;
    if (initial != null && initial.isNotEmpty) {
      final match = _items.where((e) => e.name == initial);
      if (match.isNotEmpty) {
        _selectedId = match.first.id;
      }
    }
  }

  void _selectId(String? id) {
    setState(() => _selectedId = id);
  }

  String? get _selectedName {
    if (_selectedId == null) return null;
    for (final e in _items) {
      if (e.id == _selectedId) return e.name;
    }
    return null;
  }

  void _addNewFile() {
    final newFileName =
        'Bukti_Uji_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.PDF';
    final item = _EvidenceItem(id: _nextId(newFileName), name: newFileName);
    setState(() {
      _items.insert(0, item);
      // Select only this new row — even if another file shares the same name
      _selectedId = item.id;
    });
    widget.onFileUploaded(newFileName);
  }

  Widget _buildFileRow(_EvidenceItem item, {required bool isPortfolio}) {
    final selected = _selectedId == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? const Color(0xFF378CE7) : const Color(0xFFE2E8F0),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _selectId(item.id),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isPortfolio
                    ? Icons.description_outlined
                    : Icons.picture_as_pdf_outlined,
                color: const Color(0xFF2563EB),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isPortfolio) ...[
                    const SizedBox(height: 2),
                    const Text(
                      'PDF / Image',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ],
              ),
            ),
            Radio<String>(
              value: item.id,
              groupValue: _selectedId,
              activeColor: const Color(0xFF378CE7),
              onChanged: _selectId,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const TabBar(
              labelColor: Color(0xFF1E293B),
              unselectedLabelColor: Color(0xFF64748B),
              indicatorColor: Color(0xFF378CE7),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(text: 'Upload Baru'),
                Tab(text: 'Pilih dari Portofolio'),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Upload Baru
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                color: Color(0xFF2563EB),
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Upload Bukti Uji Kompetensi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Upload Bukti yang relevan untuk KUK.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 36,
                                width: 110,
                                child: ElevatedButton(
                                  onPressed: _addNewFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF378CE7),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Pilih File',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Format: PDF, PNG, JPG · Maks 2MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Belum ada file. Upload dulu di atas.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _items.length,
                            itemBuilder: (context, fIdx) {
                              return _buildFileRow(
                                _items[fIdx],
                                isPortfolio: false,
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // Tab 2: Pilih dari Portofolio
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _items.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'Tidak ada berkas di portofolio.',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _items.length,
                            itemBuilder: (context, fIdx) {
                              return _buildFileRow(
                                _items[fIdx],
                                isPortfolio: true,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedId == null
                      ? null
                      : () => Navigator.pop(context, _selectedName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378CE7),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Simpan Bukti',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

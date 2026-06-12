// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

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
  late List<String> _localUploadedFiles;
  String? _selectedFile;

  @override
  void initState() {
    super.initState();
    _localUploadedFiles = List.from(widget.initialUploadedFiles);
    _selectedFile = widget.initialEvidence;
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
            // Pull indicator
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            // Tabs Header
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
                        // Dashed container for upload
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              style: BorderStyle.solid,
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
                                  onPressed: () {
                                    // Mock selecting a new file
                                    final newFileName = 'Bukti_Uji_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.PDF';
                                    setState(() {
                                      _localUploadedFiles.insert(0, newFileName);
                                    });
                                    widget.onFileUploaded(newFileName);
                                    setState(() {
                                      _selectedFile = newFileName;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF378CE7),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text('Pilih File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Format restriction info
                        Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Format : PDF, JPG, PNG, Maksimal 2MB',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // File list with radio selection
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _localUploadedFiles.length,
                          itemBuilder: (context, fIdx) {
                            final fileName = _localUploadedFiles[fIdx];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF2563EB), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: Color(0xFF1E293B),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'PDF . 1.2 MB',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<String>(
                                    value: fileName,
                                    groupValue: _selectedFile,
                                    activeColor: const Color(0xFF378CE7),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedFile = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab 2: Pilih dari Portofolio
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _localUploadedFiles.isEmpty
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
                            itemCount: _localUploadedFiles.length,
                            itemBuilder: (context, fIdx) {
                              final fileName = _localUploadedFiles[fIdx];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.description_outlined, color: Color(0xFF378CE7), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        fileName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: Color(0xFF1E293B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Radio<String>(
                                      value: fileName,
                                      groupValue: _selectedFile,
                                      activeColor: const Color(0xFF378CE7),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedFile = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            
            // Simpan Bukti Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedFile);
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

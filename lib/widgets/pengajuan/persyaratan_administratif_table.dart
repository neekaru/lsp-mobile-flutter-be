import 'package:flutter/material.dart';

class PersyaratanAdministratifTable extends StatefulWidget {
  final Map<String, bool> uploadedDocs;
  final Map<String, String?> uploadedFileNames;
  final Function(String docName, bool isUploaded, String? fileName) onUploadChanged;

  const PersyaratanAdministratifTable({
    super.key,
    required this.uploadedDocs,
    required this.uploadedFileNames,
    required this.onUploadChanged,
  });

  @override
  State<PersyaratanAdministratifTable> createState() => _PersyaratanAdministratifTableState();
}

class _PersyaratanAdministratifTableState extends State<PersyaratanAdministratifTable> {
  final List<String> _items = [
    'Pasfoto*',
    'Identitas pribadi (KTP/KartuPelajar)*',
  ];

  void _showUploadBottomSheet(BuildContext context, String docName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Unggah $docName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih sumber dokumen Anda:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _simulateUpload(docName);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFF3B82F6),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Kamera',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _simulateUpload(docName);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                color: Color(0xFF22C55E),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Galeri Foto',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _simulateUpload(docName);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF5FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder_open_rounded,
                                color: Color(0xFFA855F7),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pilih Dokumen',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulateUpload(String docName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      final cleanName = docName
          .replaceAll('*', '')
          .replaceAll(';', '')
          .replaceAll('(', '_')
          .replaceAll(')', '_')
          .replaceAll('/', '_')
          .replaceAll(' ', '_')
          .toLowerCase();
      final extension = docName.contains('Pasfoto') ? 'png' : 'jpg';
      final fileName = '${cleanName}_uploaded.$extension';

      widget.onUploadChanged(docName, true, fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERSYARATAN ADMINISTRATIF',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(36), // No
            1: FlexColumnWidth(), // Persyaratan
            2: FixedColumnWidth(150), // Upload Dokumen
          },
          border: TableBorder.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Table Header
            const TableRow(
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA),
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    child: Text(
                      'Persyaratan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    child: Text(
                      'Upload Dokumen',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            // Table Rows
            ...List.generate(_items.length, (index) {
              final docName = _items[index];
              final isUploaded = widget.uploadedDocs[docName] ?? false;
              final fileName = widget.uploadedFileNames[docName];

              return TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                      child: Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF334155),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF334155),
                            height: 1.35,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(
                              text: docName.endsWith('*')
                                  ? docName.substring(0, docName.length - 1)
                                  : docName,
                            ),
                            if (docName.endsWith('*'))
                              const TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isUploaded
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        widget.onUploadChanged(docName, false, null);
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.delete_forever_rounded,
                                              color: Colors.red,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showUploadBottomSheet(context, docName),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Upload',
                                              style: TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Icon(
                                              Icons.cloud_upload_rounded,
                                              color: Color(0xFF3B82F6),
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 6),
                          Text(
                            isUploaded ? (fileName ?? 'file_uploaded.jpg') : 'Tidak ada file',
                            style: TextStyle(
                              fontSize: 10,
                              color: isUploaded ? const Color(0xFF22C55E) : const Color(0xFF64748B),
                              fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          if (!isUploaded) ...[
                            const SizedBox(height: 1),
                            const Text(
                              '*format JPG/jpeg/png',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}

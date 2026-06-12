import 'package:flutter/material.dart';

class DokumenPortofolioForm extends StatefulWidget {
  final String selectedSkema;
  final List<String> portfolioItems;
  final Map<String, bool> uploadedDocs;
  final Map<String, String?> uploadedFileNames;
  final Function(String docName, bool isUploaded, String? fileName) onUploadChanged;

  const DokumenPortofolioForm({
    super.key,
    required this.selectedSkema,
    required this.portfolioItems,
    required this.uploadedDocs,
    required this.uploadedFileNames,
    required this.onUploadChanged,
  });

  @override
  State<DokumenPortofolioForm> createState() => _DokumenPortofolioFormState();
}

class _DokumenPortofolioFormState extends State<DokumenPortofolioForm> {
  // Map index/key to icon
  IconData _getIconForDoc(String docName) {
    final lower = docName.toLowerCase();
    if (lower.contains('kerja') || lower.contains('pengalaman')) {
      return Icons.description_outlined;
    } else if (lower.contains('video') || lower.contains('testimoni')) {
      return Icons.play_circle_outline_rounded;
    } else if (lower.contains('cv') || lower.contains('riwayat')) {
      return Icons.contact_page_outlined;
    } else if (lower.contains('laporan') || lower.contains('produk')) {
      return Icons.folder_open_outlined;
    } else if (lower.contains('konten') || lower.contains('promosi') || lower.contains('poster')) {
      return Icons.image_outlined;
    } else if (lower.contains('insight') || lower.contains('analisis') || lower.contains('kampanye')) {
      return Icons.analytics_outlined;
    } else if (lower.contains('interaksi') || lower.contains('pelanggan') || lower.contains('chat')) {
      return Icons.chat_bubble_outline_rounded;
    }
    return Icons.insert_drive_file_outlined;
  }

  void _showUploadBottomSheet(BuildContext context, String docName) {
    String? localSelectedFile = widget.uploadedFileNames[docName];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Upload Portofolio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 24),

                  // Doc details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconForDoc(docName),
                            color: const Color(0xFF378CE7),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                docName,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upload dokumen pembuktian ${docName.toLowerCase()} yang relevan.',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upload box area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: localSelectedFile != null
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Image.network(
                                    'https://cdn-icons-png.flaticon.com/512/337/337946.png', // PDF Icon url
                                    width: 36,
                                    height: 36,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: Colors.red,
                                      size: 36,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localSelectedFile!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          '1.24 MB',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      setModalState(() {
                                        localSelectedFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 64,
                                  color: Color(0xFF378CE7),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tidak ada file terpilih',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 38,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setModalState(() {
                                        // Generate simulated filename
                                        final safeName = docName.replaceAll(' ', '_');
                                        localSelectedFile = '$safeName.PDF';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF54B4D3),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                    ),
                                    child: const Text(
                                      'Pilih File',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info label
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Format : PDF, JPG, PNG. Maksimal 2MB',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Examples checkmark section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Contoh Dokumen :',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...['Portofolio hasil Kerja', 'Sertifikat Pelatihan', 'Hasil Proyek', 'Dokumen Pendukung Lainnya'].map((example) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              example,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                            ),
                            const Icon(
                              Icons.check_box_outlined,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Bottom sheet Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                backgroundColor: const Color(0xFFE2E8F0),
                                foregroundColor: const Color(0xFF64748B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: localSelectedFile == null
                                  ? null
                                  : () {
                                      widget.onUploadChanged(docName, true, localSelectedFile);
                                      Navigator.pop(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF378CE7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Upload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top orange info banner box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0), // orange light background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Upload bukti portofolio sesuai dengan persyaratan skema sertifikasi yang diikuti.',
                  style: TextStyle(
                    color: Colors.orange[850],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section Title Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Text(
            'Jenis Portofolio',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),

        // Portofolio List Items
        ...widget.portfolioItems.map((item) {
          final isUploaded = widget.uploadedDocs[item] ?? false;
          final fileName = widget.uploadedFileNames[item];

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
                left: BorderSide(color: Color(0xFFE2E8F0)),
                right: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: InkWell(
              onTap: () => _showUploadBottomSheet(context, item),
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
                      child: Icon(
                        _getIconForDoc(item),
                        color: const Color(0xFF378CE7),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (isUploaded && fileName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'PDF . 1,2 MB', // Or mock size
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Color(0xFF378CE7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Add document button
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // Custom document add mock trigger
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
              'Tambah Dokumen Lainnya',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

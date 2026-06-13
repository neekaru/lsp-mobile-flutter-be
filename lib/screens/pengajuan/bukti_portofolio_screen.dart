import 'package:flutter/material.dart';

class BuktiPortofolioScreen extends StatefulWidget {
  final String selectedSkema;
  final Map<String, bool> uploadedDocs;
  final Map<String, String?> uploadedFileNames;
  final Function(String docName, bool isUploaded, String? fileName) onUploadChanged;

  const BuktiPortofolioScreen({
    super.key,
    required this.selectedSkema,
    required this.uploadedDocs,
    required this.uploadedFileNames,
    required this.onUploadChanged,
  });

  @override
  State<BuktiPortofolioScreen> createState() => _BuktiPortofolioScreenState();
}

class _BuktiPortofolioScreenState extends State<BuktiPortofolioScreen> {
  List<String> _getPortfolioItems() {
    final skema = widget.selectedSkema.toLowerCase();
    if (skema.contains('programmer')) {
      return [
        'Surat Pengalaman kerja',
        'CV dengan spesialisasi Programmer',
        'Kode Sumber Aplikasi (GitHub/GitLab)',
        'Dokumentasi API / Arsitektur Sistem',
        'Laporan Hasil Pengujian Aplikasi',
      ];
    } else if (skema.contains('cloud')) {
      return [
        'Surat Pengalaman kerja',
        'CV dengan spesialisasi Cloud Admin',
        'Arsitektur Topologi Cloud',
        'Dokumentasi Konfigurasi Server/Instance',
        'Laporan Pengukuran Beban & Biaya',
      ];
    } else {
      return [
        'Surat Pengalaman kerja',
        'Testimoni dalam bentuk Video dari Pengguna Jasa Digital Marketing',
        'CV dengan spesialisasi Digital Marketing',
        'Laporan Produk & Pasar',
        'Konten Promosi (Poster, Video, Caption)',
        'Insight Kampanye',
        'Interaksi Pelanggan (Chat & Komentar)',
      ];
    }
  }

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
                            size: 24,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ekstensi file: pdf, png, jpg, jpeg (Max. 2MB)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // File upload box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF8FAFC),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: localSelectedFile == null
                          ? Column(
                              children: [
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFF378CE7),
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Pilih dokumen portofolio Anda',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Klik Browse untuk memilih file',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                /*******************************************************************************
                                 * Browse Button: Mock File Picker
                                 *******************************************************************************/
                                SizedBox(
                                  width: 120,
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Mock file selection
                                      setModalState(() {
                                        localSelectedFile = '${docName.split(" ").first.replaceAll(RegExp(r'[^a-zA-Z]'), "")}_bukti.pdf';
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF378CE7)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      foregroundColor: const Color(0xFF378CE7),
                                    ),
                                    child: const Text(
                                      'Browse',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Color(0xFF2E7D32),
                                  size: 28,
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
                                        '1.2 MB',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setModalState(() {
                                      localSelectedFile = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bottom buttons
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
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                foregroundColor: const Color(0xFF64748B),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (localSelectedFile != null) {
                                  widget.onUploadChanged(docName, true, localSelectedFile);
                                  setState(() {});
                                } else {
                                  widget.onUploadChanged(docName, false, null);
                                  setState(() {});
                                }
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
                              child: const Text(
                                'Simpan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Keyboard spacing for sheet
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
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
    final items = _getPortfolioItems();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bukti Portofolio / Relevan',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Orange Light info banner box
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
                              color: Colors.orange[800],
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

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
                  ...items.map((item) {
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
                                      const Text(
                                        'PDF . 1,2 MB',
                                        style: TextStyle(
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
                ],
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }
}

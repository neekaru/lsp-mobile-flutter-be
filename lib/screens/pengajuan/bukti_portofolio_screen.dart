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

class PortfolioItem {
  final String key;
  final String label;
  final bool isRequired;
  final String? hint;
  final bool isLink;

  PortfolioItem({
    required this.key,
    required this.label,
    required this.isRequired,
    this.hint,
    this.isLink = false,
  });
}

class PortfolioSection {
  final String title;
  final List<PortfolioItem> items;

  PortfolioSection({required this.title, required this.items});
}

class _BuktiPortofolioScreenState extends State<BuktiPortofolioScreen> {
  late List<PortfolioSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = [
      PortfolioSection(
        title: 'a. Dokumen Identitas & Administrasi',
        items: [
          PortfolioItem(
            key: 'Identitas Pribadi (KTP/Kartu Pelajar)',
            label: 'Kartu Tanda Penduduk (KTP)',
            isRequired: true,
            hint: 'Format JPG/PNG/PDF. Pastikan foto terlihat jelas',
          ),
          PortfolioItem(
            key: 'Pasfoto',
            label: 'Pas Foto Terbaru 4x6',
            isRequired: true,
            hint: 'Format JPG/PNG. Pastikan foto terlihat jelas',
          ),
        ],
      ),
      PortfolioSection(
        title: 'b. Dokumen Pendidikan/Pekerjaan',
        items: [
          PortfolioItem(
            key: 'Ijazah Terakhir / SMA / Sederajat',
            label: 'Ijasah Terakhir/Transkip',
            isRequired: true,
            hint: 'Format JPG/PNG/PDF. Pastikan foto terlihat jelas',
          ),
          PortfolioItem(
            key: 'Surat Keterangan Pengalaman Kerja',
            label: 'Surat Keterangan Kerja',
            isRequired: true,
            hint: 'Format JPG/PNG. Pastikan foto terlihat jelas',
          ),
        ],
      ),
      PortfolioSection(
        title: 'c. Bukti Kompetensi Teknis (Hasil Karya)',
        items: [
          PortfolioItem(
            key: 'Link Portofolio / GitHub',
            label: 'Link Portofolio/GitHub',
            isRequired: true,
            isLink: true,
          ),
          PortfolioItem(
            key: 'Sertifikat Pelatihan Berbasis Kompetensi',
            label: 'Sertifikat Pelatihan Relevan',
            isRequired: false,
          ),
        ],
      ),
    ];
  }

  void _simulateUpload(BuildContext context, String docKey) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        'Unggah $docKey',
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
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
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
                          _processUpload(docKey);
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
                          _processUpload(docKey);
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
                          _processUpload(docKey);
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

  void _processUpload(String docKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mengunggah dokumen...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      final cleanName = docKey
          .replaceAll('*', '')
          .replaceAll('(', '_')
          .replaceAll(')', '_')
          .replaceAll('/', '_')
          .replaceAll(' ', '_')
          .toLowerCase();
      final extension = docKey.contains('Pasfoto') ? 'png' : 'pdf';
      final fileName = '${cleanName}_bukti.$extension';

      widget.onUploadChanged(docKey, true, fileName);
      setState(() {});
    });
  }

  void _showLinkBottomSheet(BuildContext context, String docKey) {
    final controller = TextEditingController(
      text: widget.uploadedFileNames[docKey] ?? '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Simpan Tautan Portofolio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukkan tautan GitHub atau URL portofolio karya Anda:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Tautan Portofolio / GitHub',
                  hintText: 'https://github.com/username/project',
                  prefixIcon: const Icon(Icons.link, color: Color(0xFF378CE7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF378CE7), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final val = controller.text.trim();
                        if (val.isNotEmpty) {
                          widget.onUploadChanged(docKey, true, val);
                        } else {
                          widget.onUploadChanged(docKey, false, null);
                        }
                        Navigator.pop(context);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF378CE7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(PortfolioItem item) {
    final isUploaded = widget.uploadedDocs[item.key] ?? false;
    final fileName = widget.uploadedFileNames[item.key];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Label with Asterisk if required
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontFamily: 'Inter',
              ),
              children: [
                TextSpan(text: item.label),
                if (item.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status & Icon Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.isLink ? Icons.language : Icons.description_outlined,
                  color: const Color(0xFF378CE7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Status : ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUploaded
                              ? (item.isLink ? const Color(0xFFE0F2FE) : const Color(0xFFDCFCE7))
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isUploaded
                              ? (item.isLink ? 'Tautan Disimpan' : 'Sudah Diunggah')
                              : 'Belum Diunggah',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isUploaded
                                ? (item.isLink ? const Color(0xFF0369A1) : const Color(0xFF15803D))
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Upload/Action Area
          if (!isUploaded) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => item.isLink
                    ? _showLinkBottomSheet(context, item.key)
                    : _simulateUpload(context, item.key),
                icon: Icon(
                  item.isLink ? Icons.link_rounded : Icons.cloud_upload_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  item.isLink ? 'Simpan Tautan' : 'Unggah Dokumen',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF378CE7),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(
                    item.isLink ? Icons.link_rounded : Icons.insert_drive_file_rounded,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () {
                      widget.onUploadChanged(item.key, false, null);
                      setState(() {});
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () => item.isLink
                    ? _showLinkBottomSheet(context, item.key)
                    : _simulateUpload(context, item.key),
                icon: Icon(item.isLink ? Icons.edit_rounded : Icons.sync_rounded, size: 16),
                label: Text(
                  item.isLink ? 'Ubah Tautan' : 'Ubah Dokumen',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF378CE7),
                  side: const BorderSide(color: Color(0xFF378CE7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          // Hint Text if present
          if (item.hint != null) ...[
            const SizedBox(height: 10),
            Text(
              item.hint!,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Schema Title
            Text(
              widget.selectedSkema,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            // Warning Alert Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Semua dokumen dibawah ini akan digunakan sebagai bukti kompetensi saat anda mendaftar uji sertifikasi. Pastikan data Anda valid!',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sections
            ..._sections.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...section.items.map((item) => _buildItemCard(item)),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0x0D000000),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF378CE7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

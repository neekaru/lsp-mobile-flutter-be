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
  late Map<String, String> _verificationStatuses;
  late Map<String, String> _rejectionComments;

  @override
  void initState() {
    super.initState();
    
    // Initialize verification statuses matching the mockup design
    _verificationStatuses = {
      'Identitas Pribadi (KTP/Kartu Pelajar)': 'Terverifikasi',
      'Pasfoto': 'Ditolak',
      'Ijazah Terakhir / SMA / Sederajat': 'Menunggu Verifikasi',
      'Surat Keterangan Pengalaman Kerja': 'Belum Diunggah',
      'Link Portofolio / GitHub': 'Terverifikasi',
      'Sertifikat Pelatihan Berbasis Kompetensi': 'Terverifikasi',
    };

    _rejectionComments = {
      'Pasfoto': 'Foto buram & latar harus merah',
    };

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

  void _simulateUpload(BuildContext context, String docKey, String docLabel) {
    String? localFileName;
    bool isPicking = false;

    // Get specific description for each item
    String description = '';
    if (docKey.contains('KTP') || docKey.contains('Identitas')) {
      description = 'Upload Kartu Tanda Penduduk (KTP) Anda untuk verifikasi identitas diri.';
    } else if (docKey.contains('Pasfoto') || docKey.contains('Foto')) {
      description = 'Upload pas foto terbaru berwarna dengan latar belakang merah.';
    } else if (docKey.contains('Ijazah') || docKey.contains('Ijasah')) {
      description = 'Upload ijasah terakhir atau transkip nilai Anda untuk membuktikan riwayat pendidikan.';
    } else if (docKey.contains('Kerja')) {
      description = 'Upload surat keterangan kerja dari perusahaan untuk membuktikan pengalaman kerja.';
    } else {
      description = 'Upload sertifikat pelatihan berbasis kompetensi di bidang digital marketing.';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 8,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal drag handle indicator
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  const Text(
                    'Upload Portofolio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 20),

                  // Header Row with Document Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF378CE7),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              docLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // File Uploader Area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Upload icon
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF378CE7),
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        
                        // Text file name or status
                        Text(
                          localFileName ?? 'Tidak ada file terpilih',
                          style: TextStyle(
                            fontSize: 13,
                            color: localFileName != null ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                            fontWeight: localFileName != null ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Pilih File button
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                isPicking = true;
                              });
                              // Simulate file selection
                              Future.delayed(const Duration(milliseconds: 600), () {
                                if (!context.mounted) return;
                                final cleanName = docKey
                                    .replaceAll('*', '')
                                    .replaceAll('(', '_')
                                    .replaceAll(')', '_')
                                    .replaceAll('/', '_')
                                    .replaceAll(' ', '_')
                                    .toLowerCase();
                                final extension = docKey.contains('Pasfoto') ? 'JPG' : 'PDF';
                                setModalState(() {
                                  localFileName = '${cleanName}_bukti.$extension';
                                  isPicking = false;
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5AADEF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: isPicking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Pilih File',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Format Info line
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFED8936),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Format : PDF, JPG, PNG. Maksimal 2MB',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Batal / Upload)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCBD5E1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: localFileName == null
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _processUpload(docKey, localFileName!);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF378CE7),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF93C5FD),
                              disabledForegroundColor: Colors.white.withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Upload',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _processUpload(String docKey, String fileName) {
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

      widget.onUploadChanged(docKey, true, fileName);
      setState(() {
        _verificationStatuses[docKey] = 'Menunggu Verifikasi';
        _rejectionComments.remove(docKey);
      });
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
                          setState(() {
                            _verificationStatuses[docKey] = 'Terverifikasi';
                            _rejectionComments.remove(docKey);
                          });
                        } else {
                          widget.onUploadChanged(docKey, false, null);
                          setState(() {
                            _verificationStatuses[docKey] = 'Belum Diunggah';
                          });
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

    // Determine status text
    String statusText = 'Belum Diunggah';
    if (isUploaded) {
      statusText = _verificationStatuses[item.key] ?? 'Menunggu Verifikasi';
    }

    // Determine badge colors based on status
    Color badgeBgColor;
    Color badgeTextColor;
    switch (statusText) {
      case 'Terverifikasi':
        badgeBgColor = const Color(0xFFC6F6D5);
        badgeTextColor = const Color(0xFF22543D);
        break;
      case 'Ditolak':
        badgeBgColor = const Color(0xFFFED7D7);
        badgeTextColor = const Color(0xFF9B2C2C);
        break;
      case 'Menunggu Verifikasi':
        badgeBgColor = const Color(0xFFFEEBC8);
        badgeTextColor = const Color(0xFF7B341E);
        break;
      case 'Belum Diunggah':
      default:
        badgeBgColor = const Color(0xFFEDF2F7);
        badgeTextColor = const Color(0xFF4A5568);
        break;
    }

    // Check rejection comment
    String? rejectionComment;
    if (statusText == 'Ditolak') {
      rejectionComment = _rejectionComments[item.key];
    }

    // Determine button colors and labels
    final bool isUnuploaded = statusText == 'Belum Diunggah';
    final Color buttonBgColor = isUnuploaded ? const Color(0xFFE2E8F0) : const Color(0xFF378CE7);
    final Color buttonTextColor = isUnuploaded ? const Color(0xFF64748B) : Colors.white;

    String buttonLabel = item.isLink ? 'Simpan Tautan' : 'Unggah Dokumen';
    if (!isUnuploaded) {
      if (item.isLink) {
        buttonLabel = 'Edit Tautan';
      } else if (statusText == 'Ditolak') {
        buttonLabel = 'Unggah Ulang';
      }
    }

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
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status & Icon Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Row(
                      children: [
                        const Text(
                          'Status :   ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Rejection Comment
                    if (rejectionComment != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '($rejectionComment)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    // File name
                    if (fileName != null && !isUnuploaded) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'File     :   ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Expanded(
                            child: item.isLink
                                ? Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1976D2),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Upload/Action Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => item.isLink
                  ? _showLinkBottomSheet(context, item.key)
                  : _simulateUpload(context, item.key, item.label),
              icon: Icon(
                item.isLink
                    ? (isUnuploaded ? Icons.link_rounded : Icons.edit_rounded)
                    : Icons.cloud_upload_outlined,
                color: buttonTextColor,
                size: 18,
              ),
              label: Text(
                buttonLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: buttonTextColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Hint Text if present
          if (item.hint != null && isUnuploaded) ...[
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

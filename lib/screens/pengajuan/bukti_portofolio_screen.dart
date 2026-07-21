import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class PortfolioItem {
  final String key;
  final String label;
  final bool isRequired;
  final String? hint;
  final bool isLink;
  final String? status;
  final String? comment;

  PortfolioItem({
    required this.key,
    required this.label,
    required this.isRequired,
    this.hint,
    this.isLink = false,
    this.status,
    this.comment,
  });
}

class PortfolioSection {
  final String title;
  final List<PortfolioItem> items;

  PortfolioSection({required this.title, required this.items});
}

class BuktiPortofolioScreen extends StatefulWidget {
  final String selectedSkema;
  final Map<String, bool> uploadedDocs;
  final Map<String, String?> uploadedFileNames;
  final Map<String, String?> uploadedFilePaths;
  /// API docs: key, label, is_required, status, file_name, comment, section?
  final List<Map<String, dynamic>> documents;
  final void Function(
    String key,
    bool isUploaded,
    String? fileName,
    String? filePath,
  ) onUploadChanged;

  const BuktiPortofolioScreen({
    super.key,
    required this.selectedSkema,
    required this.uploadedDocs,
    required this.uploadedFileNames,
    required this.uploadedFilePaths,
    required this.documents,
    required this.onUploadChanged,
  });

  @override
  State<BuktiPortofolioScreen> createState() => _BuktiPortofolioScreenState();
}

class _BuktiPortofolioScreenState extends State<BuktiPortofolioScreen> {
  late List<PortfolioSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _buildSections();
  }

  @override
  void didUpdateWidget(covariant BuktiPortofolioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documents != widget.documents) {
      _sections = _buildSections();
    }
  }

  /// a = identitas/admin · b = pendidikan/kerja · c = karya/kompetensi
  String _sectionCode(Map<String, dynamic> d, String key, String label) {
    final raw = d['section']?.toString().toLowerCase().trim() ?? '';
    if (raw == 'a' || raw == 'administratif' || raw == 'admin') return 'a';
    if (raw == 'b' || raw == 'pendidikan' || raw == 'pekerjaan') return 'b';
    if (raw == 'c' || raw == 'karya' || raw == 'kompetensi') return 'c';

    final jenis = d['jenis_bukti']?.toString().toLowerCase().trim() ?? '';
    if (jenis == 'a' ||
        jenis == 'admin' ||
        jenis == 'administratif' ||
        jenis == 'identitas') {
      return 'a';
    }
    if (jenis == 'c' ||
        jenis == 'bukti_pelatihan' ||
        jenis == 'pelatihan' ||
        jenis == 'karya' ||
        jenis == 'kompetensi' ||
        jenis == 'portofolio') {
      return 'c';
    }
    if (jenis == 'b' ||
        jenis == 'pendidikan' ||
        jenis == 'bukti_bekerja' ||
        jenis == 'bukti_pekerja' ||
        jenis == 'pekerjaan' ||
        jenis == 'kerja') {
      return 'b';
    }

    final t = '${key.toLowerCase()} ${label.toLowerCase()}';
    bool has(List<String> xs) => xs.any(t.contains);

    if (has([
      'ktp',
      'identitas',
      'pasfoto',
      'pas-foto',
      'pas foto',
      'kartu pelajar',
      'kartu-pelajar',
      'foto 4x6',
      '4x6',
    ])) {
      return 'a';
    }
    if (has([
      'github',
      'link',
      'url',
      'tautan',
      'portofolio',
      'karya',
      'sertifikat',
      'pelatihan',
      'kompetensi teknis',
    ])) {
      return 'c';
    }
    if (has([
      'ijazah',
      'ijasah',
      'transkip',
      'transkrip',
      'pendidikan',
      'kerja',
      'pekerjaan',
      'pengalaman',
      'sk ',
      'surat keterangan',
    ])) {
      return 'b';
    }
    if (raw == 'dasar') return 'b';
    return 'b';
  }

  List<PortfolioSection> _buildSections() {
    final a = <PortfolioItem>[];
    final b = <PortfolioItem>[];
    final c = <PortfolioItem>[];

    for (final d in widget.documents) {
      final key = d['key']?.toString() ?? '';
      final label = d['label']?.toString() ?? key;
      if (key.isEmpty && label.isEmpty) continue;
      final status = d['status']?.toString();
      final comment = d['comment']?.toString();
      final isReq = d['is_required'] == true || d['is_required'] == 1;
      final lower = '$key $label'.toLowerCase();
      final isLink = lower.contains('github') ||
          lower.contains('link') ||
          lower.contains('url') ||
          lower.contains('tautan');
      final item = PortfolioItem(
        key: key.isEmpty ? label : key,
        label: label,
        isRequired: isReq,
        status: status,
        comment: comment,
        isLink: isLink,
        hint: isLink
            ? 'Format tautan GitHub / URL portofolio'
            : 'Format JPG/PNG/PDF. Pastikan foto terlihat jelas',
      );
      final code = _sectionCode(d, key, label);
      if (code == 'a') {
        a.add(item);
      } else if (code == 'c') {
        c.add(item);
      } else {
        b.add(item);
      }
    }

    return [
      PortfolioSection(
        title: 'a. Dokumen Identitas & Administrasi',
        items: a,
      ),
      PortfolioSection(
        title: 'b. Dokumen Pendidikan/Pekerjaan',
        items: b,
      ),
      PortfolioSection(
        title: 'c. Bukti Kompetensi Teknis (Hasil Karya)',
        items: c,
      ),
    ];
  }

  String _uploadDescription(String docKey, String docLabel) {
    final t = '$docKey $docLabel';
    if (t.contains('KTP') || t.contains('Identitas')) {
      return 'Upload Kartu Tanda Penduduk (KTP) Anda untuk verifikasi identitas diri.';
    }
    if (t.contains('Pasfoto') ||
        t.contains('pasfoto') ||
        t.contains('Foto') ||
        t.contains('4x6')) {
      return 'Upload pas foto terbaru berwarna dengan latar belakang merah.';
    }
    if (t.contains('Ijazah') || t.contains('Ijasah') || t.contains('Transk')) {
      return 'Upload ijasah terakhir atau transkip nilai Anda untuk membuktikan riwayat pendidikan.';
    }
    if (t.contains('Kerja') || t.contains('kerja') || t.contains('Pengalaman')) {
      return 'Upload surat keterangan kerja dari perusahaan untuk membuktikan pengalaman kerja.';
    }
    return 'Upload dokumen persyaratan skema untuk bukti kompetensi.';
  }

  Future<void> _pickRealFile(
    StateSetter setModalState,
    void Function(String name, String path) onPicked,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final path = file.path;
      if (path == null || path.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Path file tidak tersedia. Coba pilih ulang.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      if (file.size > 2 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran berkas melebihi batas 2MB'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      onPicked(file.name, path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal pilih file: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _simulateUpload(BuildContext context, String docKey, String docLabel) {
    String? localFileName;
    String? localFilePath;
    bool isPicking = false;
    final description = _uploadDescription(docKey, docLabel);

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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF378CE7),
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localFileName ?? 'Tidak ada file terpilih',
                          style: TextStyle(
                            fontSize: 13,
                            color: localFileName != null
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF64748B),
                            fontWeight: localFileName != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: isPicking
                                ? null
                                : () async {
                                    setModalState(() => isPicking = true);
                                    await _pickRealFile(setModalState,
                                        (name, path) {
                                      setModalState(() {
                                        localFileName = name;
                                        localFilePath = path;
                                        isPicking = false;
                                      });
                                    });
                                    if (localFileName == null) {
                                      setModalState(() => isPicking = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5AADEF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: isPicking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Pilih File',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFED8936),
                        size: 16,
                      ),
                      SizedBox(width: 8),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: localFileName == null ||
                                    localFilePath == null
                                ? null
                                : () {
                                    final name = localFileName!;
                                    final path = localFilePath!;
                                    Navigator.pop(context);
                                    _processUpload(docKey, name, path);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF378CE7),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF93C5FD),
                              disabledForegroundColor: Colors.white60,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Upload',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
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

  void _processUpload(String docKey, String fileName, String filePath) {
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
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

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.pop(context);
      widget.onUploadChanged(docKey, true, fileName, filePath);
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
                  prefixIcon:
                      const Icon(Icons.link, color: Color(0xFF378CE7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF378CE7), width: 1.5),
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
                      child: const Text('Batal',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final val = controller.text.trim();
                        if (val.isNotEmpty) {
                          widget.onUploadChanged(docKey, true, val, null);
                        } else {
                          widget.onUploadChanged(docKey, false, null, null);
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
                      child: const Text('Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

  String _statusOf(PortfolioItem item) {
    if (widget.uploadedDocs[item.key] == true) {
      return item.status?.isNotEmpty == true
          ? item.status!
          : 'Menunggu Verifikasi';
    }
    if (item.status != null && item.status!.isNotEmpty) {
      return item.status!;
    }
    return 'Belum Diunggah';
  }

  Widget _buildItemCard(PortfolioItem item) {
    final isUploaded = widget.uploadedDocs[item.key] ?? false;
    final fileName = widget.uploadedFileNames[item.key];

    String statusText = _statusOf(item);

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

    String? rejectionComment;
    if (statusText == 'Ditolak') {
      rejectionComment = item.comment;
    }

    final bool isUnuploaded = statusText == 'Belum Diunggah' && !isUploaded;
    final Color buttonBgColor =
        isUnuploaded ? const Color(0xFFE2E8F0) : const Color(0xFF378CE7);
    final Color buttonTextColor =
        isUnuploaded ? const Color(0xFF64748B) : Colors.white;

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
                    style:
                        TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
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
                    if (rejectionComment != null &&
                        rejectionComment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '($rejectionComment)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (fileName != null &&
                        fileName.isNotEmpty &&
                        !isUnuploaded) ...[
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
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final visibleSections =
        _sections.where((s) => s.items.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Bukti Portofolio / Relevan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedSkema,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 32,
                        ),
                        SizedBox(width: 14),
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
                  if (visibleSections.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Daftar dokumen portofolio kosong. Pastikan skema punya persyaratan, atau daftar dulu agar status server bisa dimuat.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    )
                  else
                    ...visibleSections.map((section) {
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
                          ...section.items.map(_buildItemCard),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, -4),
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

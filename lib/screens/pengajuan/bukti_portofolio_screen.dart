import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/pengajuan/bukti_portofolio_widgets.dart';

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

  void _simulateUpload(BuildContext context, String docKey, String docLabel) {
    final description = _uploadDescription(docKey, docLabel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => PortfolioUploadSheet(
        docKey: docKey,
        docLabel: docLabel,
        description: description,
        onUploaded: _processUpload,
      ),
    );
  }

  void _showLinkBottomSheet(BuildContext context, String docKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => PortfolioLinkSheet(
        docKey: docKey,
        initialText: widget.uploadedFileNames[docKey] ?? '',
        onSaved: (key, isUploaded, value) {
          widget.onUploadChanged(key, isUploaded, value, null);
          setState(() {});
        },
      ),
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

    return PortfolioItemCard(
      label: item.label,
      isRequired: item.isRequired,
      isLink: item.isLink,
      hint: item.hint,
      comment: item.comment,
      isUploaded: isUploaded,
      fileName: fileName,
      statusText: _statusOf(item),
      onUploadTap: () => _simulateUpload(context, item.key, item.label),
      onLinkTap: () => _showLinkBottomSheet(context, item.key),
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

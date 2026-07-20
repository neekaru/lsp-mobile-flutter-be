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
  /// API docs: key, label, is_required, status, file_name, comment
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

  List<PortfolioSection> _buildSections() {
    if (widget.documents.isEmpty) {
      return [
        PortfolioSection(
          title: 'Dokumen Persyaratan',
          items: const [],
        ),
      ];
    }

    final items = widget.documents.map((d) {
      final key = d['key']?.toString() ?? '';
      final label = d['label']?.toString() ?? key;
      final status = d['status']?.toString();
      final comment = d['comment']?.toString();
      final isReq = d['is_required'] == true || d['is_required'] == 1;
      final lower = label.toLowerCase();
      final isLink = lower.contains('github') ||
          lower.contains('link') ||
          lower.contains('url') ||
          lower.contains('tautan');
      return PortfolioItem(
        key: key,
        label: label,
        isRequired: isReq,
        status: status,
        comment: comment,
        isLink: isLink,
        hint: isLink
            ? 'Tautan portofolio / GitHub'
            : 'Format PDF/PNG/JPG, maks. 2MB',
      );
    }).toList();

    return [
      PortfolioSection(
        title: 'Dokumen Portofolio',
        items: items,
      ),
    ];
  }

  Future<void> _pickFile(String key, String label) async {
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
      widget.onUploadChanged(key, true, file.name, path);
      setState(() {});
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

  void _showLinkSheet(String key) {
    final controller = TextEditingController(
      text: widget.uploadedFileNames[key] ?? '',
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
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final val = controller.text.trim();
                    if (val.isNotEmpty) {
                      widget.onUploadChanged(key, true, val, null);
                    } else {
                      widget.onUploadChanged(key, false, null, null);
                    }
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Simpan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
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

  Color _badgeBg(String status) {
    switch (status) {
      case 'Terverifikasi':
        return const Color(0xFFC6F6D5);
      case 'Ditolak':
        return const Color(0xFFFED7D7);
      case 'Menunggu Verifikasi':
        return const Color(0xFFFEEBC8);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  Color _badgeFg(String status) {
    switch (status) {
      case 'Terverifikasi':
        return const Color(0xFF22543D);
      case 'Ditolak':
        return const Color(0xFF9B2C2C);
      case 'Menunggu Verifikasi':
        return const Color(0xFF9C4221);
      default:
        return const Color(0xFF475569);
    }
  }

  Widget _buildItemCard(PortfolioItem item) {
    final isUploaded = widget.uploadedDocs[item.key] ?? false;
    final fileName = widget.uploadedFileNames[item.key] ??
        (item.status != null && item.status != 'Belum Diunggah'
            ? null
            : null);
    final displayName = widget.uploadedFileNames[item.key];
    final statusText = _statusOf(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.isRequired ? '${item.label} *' : item.label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeBg(statusText),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: _badgeFg(statusText),
                  ),
                ),
              ),
            ],
          ),
          if (item.hint != null) ...[
            const SizedBox(height: 6),
            Text(
              item.hint!,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            ),
          ],
          if (item.comment != null && item.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Catatan: ${item.comment}',
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF9B2C2C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (displayName != null && displayName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  item.isLink ? Icons.link : Icons.insert_drive_file,
                  size: 16,
                  color: const Color(0xFF378CE7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF378CE7),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () {
                if (item.isLink) {
                  _showLinkSheet(item.key);
                } else {
                  _pickFile(item.key, item.label);
                }
              },
              icon: Icon(
                isUploaded ? Icons.refresh : Icons.upload_file,
                size: 18,
              ),
              label: Text(
                isUploaded ? 'Ganti Berkas' : 'Unggah Berkas',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: top + 8),
          const CustomAppBar(title: 'Bukti Portofolio'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Skema ${widget.selectedSkema}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_sections.every((s) => s.items.isEmpty))
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Daftar dokumen portofolio kosong. Pastikan skema punya persyaratan, atau daftar dulu agar status server bisa dimuat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  )
                else
                  ..._sections.expand((section) {
                    return [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 4),
                        child: Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F4C81),
                          ),
                        ),
                      ),
                      ...section.items.map(_buildItemCard),
                    ];
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Hasil pemilihan file dari [FileUploadSheet].
class PickedFileResult {
  final String name;
  final String path;

  const PickedFileResult({required this.name, required this.path});
}

/// Bottom sheet untuk memilih file upload (Surat Tugas / Lampiran Pendukung).
///
/// User memilih file lalu menekan "Upload" — sheet ditutup dan hasil
/// dikembalikan lewat [showFileUploadSheet]. Proses upload ke API dilakukan
/// oleh pemanggil (screen) setelah sheet ditutup.
class FileUploadSheet extends StatefulWidget {
  final String title;
  final String descriptionLabel;
  final String descriptionText;
  final List<String> allowedExtensions;
  final String formatInfo;
  final String? initialFileName;

  const FileUploadSheet({
    super.key,
    required this.title,
    required this.descriptionLabel,
    required this.descriptionText,
    required this.allowedExtensions,
    required this.formatInfo,
    this.initialFileName,
  });

  @override
  State<FileUploadSheet> createState() => _FileUploadSheetState();
}

class _FileUploadSheetState extends State<FileUploadSheet> {
  String? _tempFileName;
  String? _tempFilePath;
  String? _tempFileSize;

  @override
  void initState() {
    super.initState();
    _tempFileName = widget.initialFileName;
  }

  Future<void> _pickFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
      );
      if (files.isEmpty) return;
      final file = files.first;
      if (file.path == null || file.path!.isEmpty) return;
      setState(() {
        _tempFileName = file.name;
        _tempFilePath = file.path;
        final double kb = file.size / 1024;
        final double mb = kb / 1024;
        _tempFileSize = mb >= 1
            ? '${mb.toStringAsFixed(1)} MB'
            : '${kb.toStringAsFixed(1)} KB';
      });
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void _confirm() {
    final name = _tempFileName;
    final path = _tempFilePath;
    if (name == null || path == null) return;
    Navigator.of(context).pop(
      PickedFileResult(name: name, path: path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.descriptionLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.descriptionText,
                      style: const TextStyle(
                        fontSize: 11,
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 72,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _tempFileName ?? 'Tidak ada file terpilih',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          _tempFileName != null ? FontWeight.bold : FontWeight.normal,
                      color: _tempFileName != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (_tempFileName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _tempFileSize ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF54A0EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _tempFileName == null ? 'Pilih File' : 'Ganti File',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFF59E0B),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.formatInfo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_tempFileName != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFileName = null;
                      _tempFilePath = null;
                      _tempFileSize = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E8F0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _tempFilePath == null ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF54A0EB),
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Membuka [FileUploadSheet] dan menunggu hasil pemilihan file.
Future<PickedFileResult?> showFileUploadSheet(
  BuildContext context, {
  required String title,
  required String descriptionLabel,
  required String descriptionText,
  required List<String> allowedExtensions,
  required String formatInfo,
  String? initialFileName,
}) {
  return showModalBottomSheet<PickedFileResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FileUploadSheet(
      title: title,
      descriptionLabel: descriptionLabel,
      descriptionText: descriptionText,
      allowedExtensions: allowedExtensions,
      formatInfo: formatInfo,
      initialFileName: initialFileName,
    ),
  );
}

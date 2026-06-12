import 'package:flutter/material.dart';

class DokumenPortofolioForm extends StatelessWidget {
  final Map<String, bool> uploadedDocs;
  final Function(String docName) onToggleUpload;

  const DokumenPortofolioForm({
    super.key,
    required this.uploadedDocs,
    required this.onToggleUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DOKUMEN PERSYARATAN',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Unggah seluruh dokumen pendukung portofolio sebagai bukti persyaratan kompetensi skema yang Anda pilih.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        ...uploadedDocs.keys.map((docName) {
          final isUploaded = uploadedDocs[docName]!;

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isUploaded ? const Color(0xFF27AE60) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                  color: isUploaded ? const Color(0xFF27AE60) : const Color(0xFF0F4C81),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docName,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUploaded ? 'Dokumen terunggah (PDF/JPG)' : 'Format PDF/JPG, maks 2MB',
                        style: TextStyle(
                          color: isUploaded ? const Color(0xFF27AE60) : const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onToggleUpload(docName),
                  style: TextButton.styleFrom(
                    foregroundColor: isUploaded ? const Color(0xFFEF5350) : const Color(0xFF0F4C81),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    isUploaded ? 'Hapus' : 'Unggah',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

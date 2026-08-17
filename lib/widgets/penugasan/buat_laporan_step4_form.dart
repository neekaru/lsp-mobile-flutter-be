// ============================================================================
// Step 4 BuatLaporanScreen — catatan & lampiran pendukung.
//
// Diekstrak dari buat_laporan_steps.dart agar tiap step menjadi modul
// tersendiri. Semua state tetap dimiliki oleh screen; widget ini hanya
// menerima data + callback.
// ============================================================================

import 'package:flutter/material.dart';

class BuatLaporanStep4Form extends StatelessWidget {
  final TextEditingController notesController;
  final bool isUploadingAttachment;
  final List<String> attachments;
  final VoidCallback onPickLampiran;
  final ValueChanged<int> onRemoveAttachment;

  const BuatLaporanStep4Form({
    super.key,
    required this.notesController,
    required this.isUploadingAttachment,
    required this.attachments,
    required this.onPickLampiran,
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan :',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: notesController,
          maxLines: 7,
          decoration: InputDecoration(
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1E293B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Lampiran Pendukung(Opsional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),

        isUploadingAttachment
            ? const SizedBox(
                height: 40,
                width: 40,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : InkWell(
                onTap: onPickLampiran,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Berkas Lampiran',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...attachments.asMap().entries.map((entry) {
            final idx = entry.key;
            final file = entry.value;
            final displayName = file.contains('/')
                ? file.split('/').last
                : file;
            final isPdf = displayName.toLowerCase().endsWith('.pdf');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isPdf ? Icons.picture_as_pdf : Icons.image,
                          color: isPdf
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onRemoveAttachment(idx),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

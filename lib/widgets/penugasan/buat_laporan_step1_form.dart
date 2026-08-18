// ============================================================================
// Step 1 BuatLaporanScreen — identitas, skema, tanggal, surat tugas, link.
//
// Diekstrak dari buat_laporan_steps.dart agar tiap step menjadi modul
// tersendiri. Semua state tetap dimiliki oleh screen; widget ini hanya
// menerima data + callback.
// ============================================================================

import 'package:material_ui/material_ui.dart';

class BuatLaporanStep1Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController linkController;
  final String selectedSkema;
  final String selectedDate;
  final String? uploadedFileName;
  final VoidCallback onSelectSkema;
  final VoidCallback onPickSuratTugas;
  final ValueChanged<DateTime> onDatePicked;
  final ValueChanged<String> onLinkChanged;

  const BuatLaporanStep1Form({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.linkController,
    required this.selectedSkema,
    required this.selectedDate,
    required this.uploadedFileName,
    required this.onSelectSkema,
    required this.onPickSuratTugas,
    required this.onDatePicked,
    required this.onLinkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nama Lengkap',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Masukan nama lengkap anda',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lengkap tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          const Text(
            'Skema Sertifikasi (TUK)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onSelectSkema,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedSkema,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              SizedBox(width: 6),
              Text(
                'Tanggal Pelaksanaan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                onDatePicked(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate.isEmpty ? 'Pilih tanggal' : selectedDate,
                    style: TextStyle(
                      color: selectedDate.isEmpty
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Unggah Surat Tugas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickSuratTugas,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    uploadedFileName ?? 'Pilih Surat Tugas',
                    style: TextStyle(
                      color: uploadedFileName != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Surat tugas harus PDF minimal 2 mb.',
            style: TextStyle(
              color: Color(0xFF0D9488),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Link Dokumentasi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: linkController,
            onChanged: onLinkChanged,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Unggah link dokumentasi',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          if (linkController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membuka ${linkController.text}...'),
                      ),
                    );
                  },
                  child: Text(
                    '🔗 ${linkController.text}',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          const Text(
            'Bukti dokumentasi berupa link video/foto.',
            style: TextStyle(
              color: Color(0xFF0D9488),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

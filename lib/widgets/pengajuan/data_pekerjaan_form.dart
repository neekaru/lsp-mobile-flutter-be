import 'package:flutter/material.dart';
import 'form_fields.dart';

class DataPekerjaanForm extends StatelessWidget {
  final String? selectedPekerjaan;
  final TextEditingController namaPerusahaanController;
  final TextEditingController jabatanController;
  final TextEditingController alamatPerusahaanController;
  final TextEditingController kodeposPerusahaanController;
  final TextEditingController telpPerusahaanController;
  final TextEditingController emailPerusahaanController;
  final ValueChanged<String?> onPekerjaanChanged;

  const DataPekerjaanForm({
    super.key,
    required this.selectedPekerjaan,
    required this.namaPerusahaanController,
    required this.jabatanController,
    required this.alamatPerusahaanController,
    required this.kodeposPerusahaanController,
    required this.telpPerusahaanController,
    required this.emailPerusahaanController,
    required this.onPekerjaanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FR.APL.01 FORMULIR PERMOHONAN SERTIFIKASI KOMPETENSI',
          style: TextStyle(
            color: Color(0xFF0F4C81),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Bagian 1 : Rincian Data Pemohon Sertifikasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pada bagian ini, cantumkan data pekerjaan sekarang.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Section badge header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD4E6F1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'b. Data Pekerjaan Sekarang',
            style: TextStyle(
              color: Color(0xFF1B4F72),
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Pekerjaan Dropdown
        const CustomFieldLabel(label: 'Pekerjaan'),
        CustomDropdownSelector(
          hint: 'Pilih',
          value: selectedPekerjaan,
          items: const ['Mahasiswa/Pelajar', 'Karyawan Swasta', 'PNS / ASN', 'Wiraswasta / Freelance', 'Belum/Tidak Bekerja'],
          onChanged: onPekerjaanChanged,
        ),
        const SizedBox(height: 20),

        // Nama Perusahaan
        const CustomFieldLabel(label: 'Nama Perusahaan'),
        CustomTextInput(
          controller: namaPerusahaanController,
          hint: 'Organisasi/ Tempat bekerja/ Institusi Terkait/ Freelance/-(bila tidak ada)',
        ),
        const SizedBox(height: 20),

        // Jabatan
        const CustomFieldLabel(label: 'Jabatan'),
        CustomTextInput(
          controller: jabatanController,
          hint: 'Jabatan diperusahaan',
        ),
        const SizedBox(height: 20),

        // Alamat Lembaga / Perusahaan
        const CustomFieldLabel(label: 'Alamat Lembaga / Perusahaan'),
        CustomTextInput(
          controller: alamatPerusahaanController,
          hint: 'Alamat lengkap instansi/perusahaan',
          maxLines: 2,
        ),
        const SizedBox(height: 10),
        CustomTextInput(
          controller: kodeposPerusahaanController,
          hint: 'Masukan kode pos perusahaan',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),

        // No. Telp/Email Perusahaan
        const CustomFieldLabel(label: 'No. Telp/Email Perusahaan'),
        CustomTextInput(
          controller: telpPerusahaanController,
          hint: 'Masukan no telpon perusahaan',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        CustomTextInput(
          controller: emailPerusahaanController,
          hint: 'Masukan email perusahaan',
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'form_fields.dart';
import '../../models/master_models.dart';

class DataPekerjaanForm extends StatelessWidget {
  final int? selectedPekerjaanId;
  final List<MasterPekerjaan> listPekerjaan;
  final bool isLoadingPekerjaan;
  final TextEditingController namaPerusahaanController;
  final TextEditingController jabatanController;
  final TextEditingController alamatPerusahaanController;
  final TextEditingController kodeposPerusahaanController;
  final TextEditingController telpPerusahaanController;
  final TextEditingController emailPerusahaanController;
  final ValueChanged<int?> onPekerjaanChanged;

  const DataPekerjaanForm({
    super.key,
    required this.selectedPekerjaanId,
    required this.listPekerjaan,
    required this.isLoadingPekerjaan,
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
        const CustomFieldLabel(label: 'Pekerjaan'),
        SearchableModalSelectorGeneric<int>(
          title: 'Pekerjaan',
          hint: 'Pilih',
          value: selectedPekerjaanId,
          items: List<DropdownItemData<int>>.generate(
            listPekerjaan.length,
            (i) => DropdownItemData<int>(
              value: listPekerjaan[i].id,
              label: listPekerjaan[i].displayName,
            ),
          ),
          isLoading: isLoadingPekerjaan,
          onChanged: onPekerjaanChanged,
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Nama Perusahaan'),
        CustomTextInput(
          controller: namaPerusahaanController,
          hint:
              'Organisasi/ Tempat bekerja/ Institusi Terkait/ Freelance/-(bila tidak ada)',
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Jabatan'),
        CustomTextInput(
          controller: jabatanController,
          hint: 'Jabatan diperusahaan',
          inputFormatters: [LengthLimitingTextInputFormatter(25)],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Alamat Lembaga / Perusahaan'),
        CustomTextInput(
          controller: alamatPerusahaanController,
          hint: 'Alamat lengkap instansi/perusahaan',
          maxLines: 2,
          inputFormatters: [LengthLimitingTextInputFormatter(255)],
        ),
        const SizedBox(height: 10),
        CustomTextInput(
          controller: kodeposPerusahaanController,
          hint: 'Masukan kode pos perusahaan',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'No. Telp/Email Perusahaan'),
        CustomTextInput(
          controller: telpPerusahaanController,
          hint: 'Masukan no telpon perusahaan',
          keyboardType: TextInputType.phone,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
        ),
        const SizedBox(height: 10),
        CustomTextInput(
          controller: emailPerusahaanController,
          hint: 'Masukan email perusahaan',
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [LengthLimitingTextInputFormatter(19)],
        ),
      ],
    );
  }
}

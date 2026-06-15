import 'package:flutter/material.dart';
import 'form_fields.dart';
import '../../models/master_models.dart';

class DataPengajuanForm extends StatelessWidget {
  final int? selectedSkema;
  final int? selectedJadwal;
  final TextEditingController sumberAnggaranController;
  final TextEditingController pemberiAnggaranController;
  final ValueChanged<int?> onSkemaChanged;
  final ValueChanged<int?> onJadwalChanged;

  final List<MasterSkema> listSkema;
  final List<MasterJadwal> listJadwal;
  final bool isLoadingSkema;
  final bool isLoadingJadwal;

  const DataPengajuanForm({
    super.key,
    required this.selectedSkema,
    required this.selectedJadwal,
    required this.sumberAnggaranController,
    required this.pemberiAnggaranController,
    required this.onSkemaChanged,
    required this.onJadwalChanged,
    required this.listSkema,
    required this.listJadwal,
    required this.isLoadingSkema,
    required this.isLoadingJadwal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DATA PENGAJUAN',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pada bagian ini, Pilih skema Sertifikasi yang akan di ambil. Pilih jadwal sesuai Tempat Uji Kompetensi',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Dropdown Skema
        const CustomFieldLabel(label: 'Skema'),
        CustomKeyValueDropdownSelectorGeneric<int>(
          hint: 'Pilih skema',
          value: selectedSkema,
          items: listSkema
              .map((item) => DropdownItemData<int>(
                    value: item.id,
                    label: '${item.kodeSkema} - ${item.namaSkema}',
                  ))
              .toList(),
          isLoading: isLoadingSkema,
          onChanged: onSkemaChanged,
        ),
        const SizedBox(height: 20),

        // Dropdown Jadwal Uji Kompetensi
        const CustomFieldLabel(label: 'Jadwal Uji Kompetensi'),
        CustomKeyValueDropdownSelectorGeneric<int>(
          hint: 'Jadwal uji kompetensi',
          value: selectedJadwal,
          items: listJadwal
              .map((item) => DropdownItemData<int>(
                    value: item.id,
                    label: '${item.jadwal} (${item.tuk})',
                  ))
              .toList(),
          isLoading: isLoadingJadwal,
          onChanged: onJadwalChanged,
        ),
        const SizedBox(height: 6),
        const Text(
          'Perhatikan nama jadwal, Pilih jadwal berdasarkan skema dan tempat uji coba',
          style: TextStyle(
            color: Color(0xFF27AE60),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        // Sumber Anggaran
        const CustomFieldLabel(label: 'Sumber Anggaran'),
        CustomTextInput(
          controller: sumberAnggaranController,
          hint: 'Masukan sumber anggaran',
        ),
        const SizedBox(height: 20),

        // Pemberi Anggaran
        const CustomFieldLabel(label: 'Pemberi Anggaran'),
        CustomTextInput(
          controller: pemberiAnggaranController,
          hint: 'Masukan pemberi anggaran',
        ),
      ],
    );
  }
}

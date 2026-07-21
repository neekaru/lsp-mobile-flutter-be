import 'package:flutter/material.dart';
import 'form_fields.dart';
import '../../models/master_models.dart';

class DataPengajuanForm extends StatelessWidget {
  final int? selectedSkema;
  final int? selectedJadwal;
  final int? selectedSumberAnggaran;
  final int? selectedPemberiAnggaran;
  final ValueChanged<int?> onSkemaChanged;
  final ValueChanged<int?> onJadwalChanged;
  final ValueChanged<int?> onSumberAnggaranChanged;
  final ValueChanged<int?> onPemberiAnggaranChanged;

  final List<MasterSkema> listSkema;
  final List<MasterJadwal> listJadwal;
  final List<MasterSumberAnggaran> listSumberAnggaran;
  final List<MasterPemberiAnggaran> listPemberiAnggaran;
  final bool isLoadingSkema;
  final bool isLoadingJadwal;
  final bool isLoadingSumberAnggaran;
  final bool isLoadingPemberiAnggaran;

  const DataPengajuanForm({
    super.key,
    required this.selectedSkema,
    required this.selectedJadwal,
    required this.selectedSumberAnggaran,
    required this.selectedPemberiAnggaran,
    required this.onSkemaChanged,
    required this.onJadwalChanged,
    required this.onSumberAnggaranChanged,
    required this.onPemberiAnggaranChanged,
    required this.listSkema,
    required this.listJadwal,
    required this.listSumberAnggaran,
    required this.listPemberiAnggaran,
    required this.isLoadingSkema,
    required this.isLoadingJadwal,
    required this.isLoadingSumberAnggaran,
    required this.isLoadingPemberiAnggaran,
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
        SearchableModalSelectorGeneric<int>(
          title: 'Skema',
          hint: 'Pilih skema',
          value: selectedSkema,
          items: List<DropdownItemData<int>>.generate(
            listSkema.length,
            (i) => DropdownItemData<int>(
              value: listSkema[i].id,
              label: '${listSkema[i].kodeSkema} - ${listSkema[i].namaSkema}',
            ),
          ),
          isLoading: isLoadingSkema,
          onChanged: onSkemaChanged,
        ),
        const SizedBox(height: 20),

        // Dropdown Jadwal Uji Kompetensi (disabled jika skema null)
        const CustomFieldLabel(label: 'Jadwal Uji Kompetensi'),
        SearchableModalSelectorGeneric<int>(
          title: 'Jadwal Uji Kompetensi',
          hint: selectedSkema == null
              ? 'Pilih skema terlebih dahulu'
              : 'Pilih jadwal',
          value: selectedSkema == null ? null : selectedJadwal,
          items: selectedSkema == null
              ? const <DropdownItemData<int>>[]
              : List<DropdownItemData<int>>.generate(
                  listJadwal.length,
                  (i) => DropdownItemData<int>(
                    value: listJadwal[i].id,
                    label: listJadwal[i].displayName,
                  ),
                ),
          isLoading: selectedSkema == null ? false : isLoadingJadwal,
          onChanged: selectedSkema == null ? (_) {} : onJadwalChanged,
          enabled: selectedSkema != null,
        ),
        const SizedBox(height: 6),
        Text(
          selectedSkema == null
              ? 'Pilih skema lain yang belum terisi untuk membuka jadwal uji kompetensi.'
              : 'Perhatikan nama jadwal, Pilih jadwal berdasarkan skema dan tempat uji coba',
          style: TextStyle(
            color: selectedSkema == null
                ? const Color(0xFFEF4444)
                : const Color(0xFF27AE60),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        // Dropdown Sumber Anggaran (disabled jika skema null)
        const CustomFieldLabel(label: 'Sumber Anggaran'),
        SearchableModalSelectorGeneric<int>(
          title: 'Sumber Anggaran',
          hint: selectedSkema == null
              ? 'Pilih skema terlebih dahulu'
              : 'Pilih sumber anggaran',
          value: selectedSkema == null ? null : selectedSumberAnggaran,
          items: selectedSkema == null
              ? const <DropdownItemData<int>>[]
              : List<DropdownItemData<int>>.generate(
                  listSumberAnggaran.length,
                  (i) => DropdownItemData<int>(
                    value: listSumberAnggaran[i].id,
                    label: listSumberAnggaran[i].displayName,
                  ),
                ),
          isLoading: selectedSkema == null ? false : isLoadingSumberAnggaran,
          onChanged: selectedSkema == null ? (_) {} : onSumberAnggaranChanged,
          enabled: selectedSkema != null,
        ),
        const SizedBox(height: 20),

        // Dropdown Pemberi Anggaran (filtered by sumber via cross-id)
        const CustomFieldLabel(label: 'Pemberi Anggaran'),
        SearchableModalSelectorGeneric<int>(
          title: 'Pemberi Anggaran',
          hint: selectedSkema == null
              ? 'Pilih skema terlebih dahulu'
              : selectedSumberAnggaran == null
                  ? 'Pilih sumber anggaran terlebih dahulu'
                  : 'Pilih pemberi anggaran',
          value: (selectedSkema == null || selectedSumberAnggaran == null)
              ? null
              : selectedPemberiAnggaran,
          items: (selectedSkema == null || selectedSumberAnggaran == null)
              ? const <DropdownItemData<int>>[]
              : List<DropdownItemData<int>>.generate(
                  listPemberiAnggaran.length,
                  (i) => DropdownItemData<int>(
                    value: listPemberiAnggaran[i].id,
                    label: listPemberiAnggaran[i].displayName,
                  ),
                ),
          isLoading: (selectedSkema == null || selectedSumberAnggaran == null)
              ? false
              : isLoadingPemberiAnggaran,
          onChanged: (selectedSkema == null || selectedSumberAnggaran == null)
              ? (_) {}
              : onPemberiAnggaranChanged,
          enabled: selectedSkema != null && selectedSumberAnggaran != null,
        ),
      ],
    );
  }
}

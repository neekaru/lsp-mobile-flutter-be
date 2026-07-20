// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'form_fields.dart';
import '../../models/master_models.dart';

class DataPribadiForm extends StatelessWidget {
  final TextEditingController nikController;
  final TextEditingController namaLengkapController;
  final String jenisKelamin;
  final TextEditingController tempatLahirController;
  final TextEditingController tanggalLahirController;
  final TextEditingController alamatDomisiliController;
  final String? selectedProvinsi;
  final String? selectedKota;
  final String? selectedKecamatan;
  final TextEditingController noTelpController;
  final TextEditingController emailController;
  final int? selectedPendidikanId;
  final TextEditingController namaSekolahController;
  final TextEditingController jurusanController;

  final List<MasterItem> listProvinsi;
  final List<MasterItem> listKabupaten;
  final List<MasterItem> listKecamatan;
  final List<MasterPendidikan> listPendidikan;
  final bool isLoadingProvinsi;
  final bool isLoadingKabupaten;
  final bool isLoadingKecamatan;
  final bool isLoadingPendidikan;

  final ValueChanged<String?> onJenisKelaminChanged;
  final ValueChanged<String?> onProvinsiChanged;
  final ValueChanged<String?> onKotaChanged;
  final ValueChanged<String?> onKecamatanChanged;
  final ValueChanged<int?> onPendidikanChanged;
  final VoidCallback onTanggalLahirTap;

  const DataPribadiForm({
    super.key,
    required this.nikController,
    required this.namaLengkapController,
    required this.jenisKelamin,
    required this.tempatLahirController,
    required this.tanggalLahirController,
    required this.alamatDomisiliController,
    required this.selectedProvinsi,
    required this.selectedKota,
    required this.selectedKecamatan,
    required this.noTelpController,
    required this.emailController,
    required this.selectedPendidikanId,
    required this.namaSekolahController,
    required this.jurusanController,
    required this.listProvinsi,
    required this.listKabupaten,
    required this.listKecamatan,
    required this.listPendidikan,
    required this.isLoadingProvinsi,
    required this.isLoadingKabupaten,
    required this.isLoadingKecamatan,
    required this.isLoadingPendidikan,
    required this.onJenisKelaminChanged,
    required this.onProvinsiChanged,
    required this.onKotaChanged,
    required this.onKecamatanChanged,
    required this.onPendidikanChanged,
    required this.onTanggalLahirTap,
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
          'Pada bagian ini, cantumkan data pribadi, data pendidikan formal anda pada saat ini.',
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
            'a. Data Pribadi',
            style: TextStyle(
              color: Color(0xFF1B4F72),
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const CustomFieldLabel(label: 'NIK'),
        CustomTextInput(
          controller: nikController,
          hint: 'Masukan 16 digit nomor induk kependudukan',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Nama Lengkap'),
        CustomTextInput(
          controller: namaLengkapController,
          hint: 'Masukan nama lengkap',
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
        ),
        const SizedBox(height: 4),
        const Text(
          'Nama yang diinput akan tertera di sertifikat (Jika Kompeten)',
          style: TextStyle(
            color: Color(0xFF27AE60),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Jenis Kelamin'),
        Row(
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'Laki-Laki',
                  groupValue: jenisKelamin,
                  activeColor: const Color(0xFF0F4C81),
                  onChanged: onJenisKelaminChanged,
                ),
                const Text('Laki-Laki',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(width: 32),
            Row(
              children: [
                Radio<String>(
                  value: 'Perempuan',
                  groupValue: jenisKelamin,
                  activeColor: const Color(0xFF0F4C81),
                  onChanged: onJenisKelaminChanged,
                ),
                const Text('Perempuan',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Tempat & Tanggal Lahir'),
        CustomTextInput(
          controller: tempatLahirController,
          hint: 'Masukan tempat lahir',
          inputFormatters: [LengthLimitingTextInputFormatter(25)],
        ),
        const SizedBox(height: 10),
        CustomTextInput(
          controller: tanggalLahirController,
          hint: 'YYYY-MM-DD',
          suffixIcon: const Icon(Icons.calendar_today_rounded,
              color: Color(0xFF0F4C81), size: 20),
          readOnly: true,
          onTap: onTanggalLahirTap,
        ),
        const SizedBox(height: 4),
        const Text(
          'Format Tahun-Bulan-Tanggal (YYYY-MM-DD)',
          style: TextStyle(
            color: Color(0xFF27AE60),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Alamat Domisili / Sesuai KTP'),
        CustomTextInput(
          controller: alamatDomisiliController,
          hint: 'Alamat lengkap sesuai domisili atau KTP',
          maxLines: 3,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Provinsi/Kota/Kecamatan'),
        CustomKeyValueDropdownSelector(
          hint: '--Pilih Provinsi--',
          value: selectedProvinsi,
          items: listProvinsi,
          isLoading: isLoadingProvinsi,
          onChanged: onProvinsiChanged,
        ),
        const SizedBox(height: 10),
        CustomKeyValueDropdownSelector(
          hint: '--Pilih Kota/Kabupaten--',
          value: selectedKota,
          items: listKabupaten,
          isLoading: isLoadingKabupaten,
          onChanged: onKotaChanged,
        ),
        const SizedBox(height: 10),
        CustomKeyValueDropdownSelector(
          hint: '--Pilih Kecamatan--',
          value: selectedKecamatan,
          items: listKecamatan,
          isLoading: isLoadingKecamatan,
          onChanged: onKecamatanChanged,
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'No.Telp/Email/ No Whatsapp Aktif'),
        CustomTextInput(
          controller: noTelpController,
          hint: 'Masukan No.Whatsapp',
          keyboardType: TextInputType.phone,
          inputFormatters: [LengthLimitingTextInputFormatter(20)],
        ),
        const SizedBox(height: 10),
        CustomTextInput(
          controller: emailController,
          hint: 'Masukan email',
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Pendidikan Terakhir'),
        SearchableModalSelectorGeneric<int>(
          title: 'Pendidikan Terakhir',
          hint: 'Pilih pendidikan',
          value: selectedPendidikanId,
          items: List<DropdownItemData<int>>.generate(
            listPendidikan.length,
            (i) => DropdownItemData<int>(
              value: listPendidikan[i].id,
              label: listPendidikan[i].displayName,
            ),
          ),
          isLoading: isLoadingPendidikan,
          onChanged: onPendidikanChanged,
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Nama Sekolah/Perguruan Tinggi'),
        CustomTextInput(
          controller: namaSekolahController,
          hint: 'Nama sekolah dan perguruan tinggi',
          inputFormatters: [LengthLimitingTextInputFormatter(255)],
        ),
        const SizedBox(height: 20),
        const CustomFieldLabel(label: 'Jurusan / Program Studi'),
        CustomTextInput(
          controller: jurusanController,
          hint: 'Nama jurusan atau program studi',
          inputFormatters: [LengthLimitingTextInputFormatter(25)],
        ),
      ],
    );
  }
}

// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';

import 'biodata_form_fields.dart';

// ============================================================================
// Konten accordion step 4 biodata peserta (APL 01).
//
// Diekstrak dari step4_biodata_peserta.dart agar file step tetap ringkas.
// Semua widget murni menerima nilai + callback dari pemanggil (state screen).
// ============================================================================

/// Banner hijau "Biodata Peserta / APL 01" di atas form.
class Step4TopBanner extends StatelessWidget {
  const Step4TopBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const Center(
        child: Text(
          'Biodata Peserta / APL 01',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }
}

/// Konten accordion "Data Peserta".
class DataPesertaBiodataSection extends StatelessWidget {
  final String skemaSertifikasi;
  final VoidCallback onSelectSkema;

  final TextEditingController idController;
  final TextEditingController nikController;
  final TextEditingController namaLengkapController;
  final String jenisKelamin;
  final VoidCallback onSelectJenisKelamin;
  final TextEditingController tempatLahirController;
  final TextEditingController tanggalLahirController;
  final VoidCallback onSelectTanggalLahir;
  final TextEditingController alamatController;
  final String provinsi;
  final VoidCallback onSelectProvinsi;
  final String kabupaten;
  final VoidCallback onSelectKabupaten;
  final String kecamatan;
  final VoidCallback onSelectKecamatan;
  final TextEditingController kontakController;
  final VoidCallback onOpenWhatsApp;
  final TextEditingController emailController;
  final VoidCallback onLihatKtp;

  const DataPesertaBiodataSection({
    super.key,
    required this.skemaSertifikasi,
    required this.onSelectSkema,
    required this.idController,
    required this.nikController,
    required this.namaLengkapController,
    required this.jenisKelamin,
    required this.onSelectJenisKelamin,
    required this.tempatLahirController,
    required this.tanggalLahirController,
    required this.onSelectTanggalLahir,
    required this.alamatController,
    required this.provinsi,
    required this.onSelectProvinsi,
    required this.kabupaten,
    required this.onSelectKabupaten,
    required this.kecamatan,
    required this.onSelectKecamatan,
    required this.kontakController,
    required this.onOpenWhatsApp,
    required this.emailController,
    required this.onLihatKtp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BiodataSelectField(
          label: 'Skema Sertifikasi',
          value: skemaSertifikasi,
          hint: 'Pilih Skema Sertifikasi',
          onTap: onSelectSkema,
        ),
        BiodataInputField(
          label: 'ID',
          controller: idController,
          hint: 'Masukkan ID',
        ),
        BiodataInputField(
          label: 'NIK',
          controller: nikController,
          hint: 'Masukkan NIK',
          rightAction: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onLihatKtp,
            child: const Text(
              'Lihat KTP',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ),
        BiodataInputField(
          label: 'Nama Lengkap',
          controller: namaLengkapController,
          hint: 'Masukkan Nama Lengkap',
        ),
        BiodataSelectField(
          label: 'Jenis Kelamin',
          value: jenisKelamin,
          hint: 'Pilih Jenis Kelamin',
          onTap: onSelectJenisKelamin,
        ),
        BiodataInputField(
          label: 'Tempat Lahir',
          controller: tempatLahirController,
          hint: 'Masukkan Tempat Lahir',
        ),
        BiodataDatePickerField(
          label: 'Tanggal Lahir',
          controller: tanggalLahirController,
          hint: 'dd/mm/yyyy',
          onTap: onSelectTanggalLahir,
        ),
        BiodataInputField(
          label: 'Alamat',
          controller: alamatController,
          hint: 'Masukkan Alamat',
          maxLines: 2,
        ),
        BiodataSelectField(
          label: 'Provinsi',
          value: provinsi,
          hint: 'Pilih Provinsi',
          onTap: onSelectProvinsi,
        ),
        BiodataSelectField(
          label: 'Kabupaten/Kota',
          value: kabupaten,
          hint: 'Pilih Kabupaten/Kota',
          onTap: onSelectKabupaten,
        ),
        BiodataSelectField(
          label: 'Kecamatan',
          value: kecamatan,
          hint: 'Pilih Kecamatan',
          onTap: onSelectKecamatan,
        ),
        BiodataPhoneField(
          label: 'No.Kontak',
          controller: kontakController,
          hint: 'Masukkan No.Kontak',
          onTap: onOpenWhatsApp,
        ),
        BiodataInputField(
          label: 'Email',
          controller: emailController,
          hint: 'Masukkan Email',
          keyboardType: TextInputType.emailAddress,
          isLast: true,
        ),
      ],
    );
  }
}

/// Konten accordion "Data Pendidikan".
class DataPendidikanBiodataSection extends StatelessWidget {
  final String pendidikanTerakhir;
  final VoidCallback onSelectPendidikan;
  final TextEditingController namaSekolahController;
  final TextEditingController jurusanController;

  const DataPendidikanBiodataSection({
    super.key,
    required this.pendidikanTerakhir,
    required this.onSelectPendidikan,
    required this.namaSekolahController,
    required this.jurusanController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BiodataSelectField(
          label: 'Pendidikan Terakhir',
          value: pendidikanTerakhir,
          hint: 'Pilih Pendidikan',
          onTap: onSelectPendidikan,
        ),
        BiodataInputField(
          label: 'Nama Sekolah/Perguruan Tinggi',
          controller: namaSekolahController,
          hint: 'Masukkan Nama Sekolah',
        ),
        BiodataInputField(
          label: 'Jurusan/Program Studi',
          controller: jurusanController,
          hint: 'Masukkan Jurusan',
          isLast: true,
        ),
      ],
    );
  }
}

/// Konten accordion "Data Pekerjaan".
class DataPekerjaanBiodataSection extends StatelessWidget {
  final String pekerjaan;
  final VoidCallback onSelectPekerjaan;
  final TextEditingController perusahaanController;
  final TextEditingController jabatanController;
  final TextEditingController alamatPerusahaanController;
  final TextEditingController noKontakPerusahaanController;
  final VoidCallback onOpenWhatsAppPerusahaan;
  final String tuk;
  final VoidCallback onSelectTUK;
  final String asesorValue;
  final VoidCallback onSelectAsesor;
  final String perangkatValue;
  final VoidCallback onSelectPerangkat;

  const DataPekerjaanBiodataSection({
    super.key,
    required this.pekerjaan,
    required this.onSelectPekerjaan,
    required this.perusahaanController,
    required this.jabatanController,
    required this.alamatPerusahaanController,
    required this.noKontakPerusahaanController,
    required this.onOpenWhatsAppPerusahaan,
    required this.tuk,
    required this.onSelectTUK,
    required this.asesorValue,
    required this.onSelectAsesor,
    required this.perangkatValue,
    required this.onSelectPerangkat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BiodataSelectField(
          label: 'Pekerjaan',
          value: pekerjaan,
          hint: 'Pilih Pekerjaan',
          onTap: onSelectPekerjaan,
        ),
        BiodataInputField(
          label: 'Perusahaan',
          controller: perusahaanController,
          hint: 'Masukkan Nama Perusahaan',
        ),
        BiodataInputField(
          label: 'Jabatan',
          controller: jabatanController,
          hint: 'Masukkan Jabatan',
        ),
        BiodataInputField(
          label: 'Alamat Organisasi/Perusahaan',
          controller: alamatPerusahaanController,
          hint: 'Masukkan Alamat Perusahaan',
          maxLines: 2,
        ),
        BiodataPhoneField(
          label: 'No.Kontak Perusahaan',
          controller: noKontakPerusahaanController,
          hint: 'Masukkan No.Kontak',
          onTap: onOpenWhatsAppPerusahaan,
        ),
        BiodataSelectField(
          label: 'TUK',
          value: tuk,
          hint: 'Pilih TUK',
          onTap: onSelectTUK,
        ),
        BiodataSelectField(
          label: 'Pra Asessmen Checked',
          value: asesorValue,
          hint: 'Pilih Asesor',
          onTap: onSelectAsesor,
        ),
        BiodataSelectField(
          label: 'Perangkat Asesmen',
          value: perangkatValue,
          hint: 'Pilih Perangkat',
          onTap: onSelectPerangkat,
          isLast: true,
        ),
      ],
    );
  }
}

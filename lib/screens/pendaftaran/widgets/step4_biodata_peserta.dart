import 'package:flutter/material.dart';

class Step4BiodataPeserta extends StatefulWidget {
  const Step4BiodataPeserta({super.key});

  @override
  State<Step4BiodataPeserta> createState() => _Step4BiodataPesertaState();
}

class _Step4BiodataPesertaState extends State<Step4BiodataPeserta> {
  // Section 1 Controllers & State: Biodata Peserta / APL 01
  final String _skemaSertifikasi = 'Digital Marketing';
  late TextEditingController _idController;
  late TextEditingController _nikController;
  late TextEditingController _namaLengkapController;
  final String _jenisKelamin = 'Laki-Laki';
  final String _tempatLahir = 'Tenggarong';
  late TextEditingController _tanggalLahirController;
  late TextEditingController _alamatController;
  final String _provinsi = 'Banten';
  final String _kabupaten = 'Kota Tenggarong';
  final String _kecamatan = 'Kencana';
  late TextEditingController _kontakController;
  late TextEditingController _emailController;

  // Section 2 Controllers & State: Data Pendidikan
  final String _pendidikanTerakhir = 'SMA/SMK/Sederajat';
  late TextEditingController _namaSekolahController;
  late TextEditingController _jurusanController;

  // Section 3 Controllers & State: Data Pekerjaan
  final String _pekerjaan = 'Pelajar/Mahasiswa';
  late TextEditingController _perusahaanController;
  late TextEditingController _jabatanController;
  late TextEditingController _alamatPerusahaanController;
  late TextEditingController _noKontakPerusahaanController;
  final String _tuk = 'UPP Semarang';
  final String _praAsesmenChecked = 'Utama';
  final String _perangkatAsesmen = '9';

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: '168456');
    _nikController = TextEditingController(text: '68250705588');
    _namaLengkapController = TextEditingController(text: 'Aldi Taher');
    _tanggalLahirController = TextEditingController(text: '01/01/1990');
    _alamatController = TextEditingController(text: 'Jl. Bahagia, Perum Suci');
    _kontakController = TextEditingController(text: '085654017778');
    _emailController = TextEditingController(text: 'alditaher88@gmail.com');

    _namaSekolahController = TextEditingController(text: 'SMK 5 Semarang');
    _jurusanController = TextEditingController(text: 'Jurusan Multimedia');

    _perusahaanController = TextEditingController(text: 'SMK 5 Semarang');
    _jabatanController = TextEditingController(text: '-');
    _alamatPerusahaanController = TextEditingController(text: 'Jl. Kramatwatu, Tenggarong');
    _noKontakPerusahaanController = TextEditingController(text: '-');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nikController.dispose();
    _namaLengkapController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _kontakController.dispose();
    _emailController.dispose();
    _namaSekolahController.dispose();
    _jurusanController.dispose();
    _perusahaanController.dispose();
    _jabatanController.dispose();
    _alamatPerusahaanController.dispose();
    _noKontakPerusahaanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year;
      setState(() {
        _tanggalLahirController.text = '$day/$month/$year';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====================================================================
        // SECTION 1: BIODATA PESERTA / APL 01
        // ====================================================================
        _buildSectionBanner('Biodata Peserta / APL 01'),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildSelectField(
                label: 'Skema Sertifikasi',
                value: _skemaSertifikasi,
                onTap: () {},
              ),
              _buildInputField(
                label: 'ID',
                controller: _idController,
              ),
              _buildInputField(
                label: 'NIK',
                controller: _nikController,
                rightAction: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka dokumen KTP...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
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
              _buildInputField(
                label: 'Nama Lengkap',
                controller: _namaLengkapController,
              ),
              _buildSelectField(
                label: 'Jenis Kelamin',
                value: _jenisKelamin,
                onTap: () {},
              ),
              _buildSelectField(
                label: 'Tempat Lahir',
                value: _tempatLahir,
                onTap: () {},
              ),
              _buildDatePickerField(
                label: 'Tanggal Lahir',
                controller: _tanggalLahirController,
                onTap: () => _selectDate(context),
              ),
              _buildInputField(
                label: 'Alamat',
                controller: _alamatController,
                maxLines: 2,
              ),
              _buildSelectField(
                label: 'Provinsi',
                value: _provinsi,
                onTap: () {},
              ),
              _buildSelectField(
                label: 'Kabupaten/Kota',
                value: _kabupaten,
                onTap: () {},
              ),
              _buildSelectField(
                label: 'Kecamatan',
                value: _kecamatan,
                onTap: () {},
              ),
              _buildInputField(
                label: 'Kontak',
                controller: _kontakController,
                rightAction: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menghubungkan ke WhatsApp...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'Kirim WA',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ),
              _buildInputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ====================================================================
        // SECTION 2: DATA PENDIDIKAN
        // ====================================================================
        _buildSectionBanner('Data Pendidikan'),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildSelectField(
                label: 'Pendidikan\nTerakhir',
                value: _pendidikanTerakhir,
                onTap: () {},
              ),
              _buildInputField(
                label: 'Nama Sekolah /\nPerguruan Tinggi',
                controller: _namaSekolahController,
              ),
              _buildInputField(
                label: 'Jurusan/Program\nStudi',
                controller: _jurusanController,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ====================================================================
        // SECTION 3: DATA PEKERJAAN
        // ====================================================================
        _buildSectionBanner('Data Pekerjaan'),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildSelectField(
                label: 'Pekerjaan',
                value: _pekerjaan,
                onTap: () {},
              ),
              _buildInputField(
                label: 'Perusahaan',
                controller: _perusahaanController,
              ),
              _buildInputField(
                label: 'Jabatan',
                controller: _jabatanController,
              ),
              _buildInputField(
                label: 'Alamat\nOrganisasi/\nPerusahaan',
                controller: _alamatPerusahaanController,
                maxLines: 2,
              ),
              _buildInputField(
                label: 'No. Kontak\nPerusahaan',
                controller: _noKontakPerusahaanController,
              ),
              _buildSelectField(
                label: 'TUK',
                value: _tuk,
                onTap: () {},
              ),
              _buildSelectField(
                label: 'Pra Asesmen\nChecked',
                value: _praAsesmenChecked,
                onTap: () {},
              ),
              _buildSelectField(
                label: 'Perangkat\nAsesmen',
                value: _perangkatAsesmen,
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Section Banner Title Helper
  Widget _buildSectionBanner(String title) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }

  // Input Field Helper
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    Widget? rightAction,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                if (rightAction != null) ...[
                  const SizedBox(width: 4),
                  rightAction,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Select/Dropdown Field Helper
  Widget _buildSelectField({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DatePicker Field Helper
  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

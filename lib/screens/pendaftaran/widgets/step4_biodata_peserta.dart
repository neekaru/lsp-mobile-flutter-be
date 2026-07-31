// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../services/permohonan_service.dart';

class Step4BiodataPeserta extends StatefulWidget {
  final int? permohonanId;

  const Step4BiodataPeserta({
    super.key,
    this.permohonanId,
  });

  @override
  State<Step4BiodataPeserta> createState() => _Step4BiodataPesertaState();
}

class _Step4BiodataPesertaState extends State<Step4BiodataPeserta> {
  // Accordion Expand / Collapse States
  bool _isDataPesertaExpanded = true;
  bool _isDataPendidikanExpanded = false;
  bool _isDataPekerjaanExpanded = false;

  // Section 1 Controllers & State: Data Peserta
  String _skemaSertifikasi = '';
  late TextEditingController _idController;
  late TextEditingController _nikController;
  late TextEditingController _namaLengkapController;
  String _jenisKelamin = '';
  String _tempatLahir = '';
  late TextEditingController _tanggalLahirController;
  late TextEditingController _alamatController;
  String _provinsi = '';
  String _kabupaten = '';
  String _kecamatan = '';
  late TextEditingController _kontakController;
  late TextEditingController _emailController;

  // Section 2 Controllers & State: Data Pendidikan
  String _pendidikanTerakhir = '';
  late TextEditingController _namaSekolahController;
  late TextEditingController _jurusanController;

  // Section 3 Controllers & State: Data Pekerjaan
  String _pekerjaan = '';
  late TextEditingController _perusahaanController;
  late TextEditingController _jabatanController;
  late TextEditingController _alamatPerusahaanController;
  late TextEditingController _noKontakPerusahaanController;
  String _tuk = '';
  String _praAsesmenChecked = '';
  String _perangkatAsesmen = '';

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _nikController = TextEditingController();
    _namaLengkapController = TextEditingController();
    _tanggalLahirController = TextEditingController();
    _alamatController = TextEditingController();
    _kontakController = TextEditingController();
    _emailController = TextEditingController();

    _namaSekolahController = TextEditingController();
    _jurusanController = TextEditingController();

    _perusahaanController = TextEditingController();
    _jabatanController = TextEditingController();
    _alamatPerusahaanController = TextEditingController();
    _noKontakPerusahaanController = TextEditingController();

    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.permohonanId == null) return;
    final realData = await PermohonanService.getStep4Data(widget.permohonanId!);
    if (!mounted) return;
    if (realData != null) {
      setState(() {
        if (realData['id_peserta'] != null) _idController.text = realData['id_peserta']!;
        if (realData['nik'] != null) _nikController.text = realData['nik']!;
        if (realData['nama_pemohon'] != null) _namaLengkapController.text = realData['nama_pemohon']!;
        if (realData['skema_sertifikasi'] != null) _skemaSertifikasi = realData['skema_sertifikasi']!;
        if (realData['jenis_kelamin'] != null) _jenisKelamin = realData['jenis_kelamin']!;
        if (realData['tempat_lahir'] != null) _tempatLahir = realData['tempat_lahir']!;
        if (realData['tanggal_lahir'] != null) _tanggalLahirController.text = realData['tanggal_lahir']!;
        if (realData['alamat'] != null) _alamatController.text = realData['alamat']!;
        if (realData['provinsi'] != null) _provinsi = realData['provinsi']!;
        if (realData['kabupaten'] != null) _kabupaten = realData['kabupaten']!;
        if (realData['kecamatan'] != null) _kecamatan = realData['kecamatan']!;
        if (realData['kontak'] != null) _kontakController.text = realData['kontak']!;
        if (realData['email'] != null) _emailController.text = realData['email']!;

        if (realData['pendidikan_terakhir'] != null) _pendidikanTerakhir = realData['pendidikan_terakhir']!;
        if (realData['nama_sekolah'] != null) _namaSekolahController.text = realData['nama_sekolah']!;
        if (realData['jurusan'] != null) _jurusanController.text = realData['jurusan']!;

        if (realData['pekerjaan'] != null) _pekerjaan = realData['pekerjaan']!;
        if (realData['perusahaan'] != null) _perusahaanController.text = realData['perusahaan']!;
        if (realData['jabatan'] != null) _jabatanController.text = realData['jabatan']!;
        if (realData['alamat_perusahaan'] != null) _alamatPerusahaanController.text = realData['alamat_perusahaan']!;
        if (realData['no_kontak_perusahaan'] != null) _noKontakPerusahaanController.text = realData['no_kontak_perusahaan']!;
        if (realData['tuk'] != null) _tuk = realData['tuk']!;
        if (realData['pra_asesmen_checked'] != null) _praAsesmenChecked = realData['pra_asesmen_checked']!;
        if (realData['perangkat_asesmen'] != null) _perangkatAsesmen = realData['perangkat_asesmen']!;
      });
    }
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
      initialDate: DateTime.now(),
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
        _buildTopBanner(),
        const SizedBox(height: 12),
        _buildAccordionCard(
          icon: Icons.person_rounded,
          iconBgColor: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF3B82F6),
          title: 'Data Peserta',
          isExpanded: _isDataPesertaExpanded,
          onTapHeader: () {
            setState(() {
              _isDataPesertaExpanded = !_isDataPesertaExpanded;
            });
          },
          content: _buildDataPesertaContent(),
        ),
        const SizedBox(height: 12),
        _buildAccordionCard(
          icon: Icons.school_rounded,
          iconBgColor: const Color(0xFFD1FAE5),
          iconColor: const Color(0xFF10B981),
          title: 'Data Pendidikan',
          isExpanded: _isDataPendidikanExpanded,
          onTapHeader: () {
            setState(() {
              _isDataPendidikanExpanded = !_isDataPendidikanExpanded;
            });
          },
          content: _buildDataPendidikanContent(),
        ),
        const SizedBox(height: 12),
        _buildAccordionCard(
          icon: Icons.work_rounded,
          iconBgColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFF59E0B),
          title: 'Data Pekerjaan',
          isExpanded: _isDataPekerjaanExpanded,
          onTapHeader: () {
            setState(() {
              _isDataPekerjaanExpanded = !_isDataPekerjaanExpanded;
            });
          },
          content: _buildDataPekerjaanContent(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTopBanner() {
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

  Widget _buildAccordionCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required bool isExpanded,
    required VoidCallback onTapHeader,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTapHeader,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.chevron_right_rounded,
                    color: const Color(0xFF0F172A),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: content,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataPesertaContent() {
    return Column(
      children: [
        _buildSelectField(
          label: 'Skema Sertifikasi',
          value: _skemaSertifikasi,
          hint: 'Pilih Skema Sertifikasi',
          onTap: () {},
        ),
        _buildInputField(
          label: 'ID',
          controller: _idController,
          hint: 'Masukkan ID',
        ),
        _buildInputField(
          label: 'NIK',
          controller: _nikController,
          hint: 'Masukkan NIK',
          rightAction: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
          hint: 'Masukkan Nama Lengkap',
        ),
        _buildSelectField(
          label: 'Jenis Kelamin',
          value: _jenisKelamin,
          hint: 'Pilih Jenis Kelamin',
          onTap: () {},
        ),
        _buildSelectField(
          label: 'Tempat Lahir',
          value: _tempatLahir,
          hint: 'Pilih Tempat Lahir',
          onTap: () {},
        ),
        _buildDatePickerField(
          label: 'Tanggal Lahir',
          controller: _tanggalLahirController,
          hint: 'dd/mm/yyyy',
          onTap: () => _selectDate(context),
        ),
        _buildInputField(
          label: 'Alamat',
          controller: _alamatController,
          hint: 'Masukkan Alamat',
          maxLines: 2,
        ),
        _buildSelectField(
          label: 'Provinsi',
          value: _provinsi,
          hint: 'Pilih Provinsi',
          onTap: () {},
        ),
        _buildSelectField(
          label: 'Kabupaten/Kota',
          value: _kabupaten,
          hint: 'Pilih Kabupaten/Kota',
          onTap: () {},
        ),
        _buildSelectField(
          label: 'Kecamatan',
          value: _kecamatan,
          hint: 'Pilih Kecamatan',
          onTap: () {},
        ),
        _buildInputField(
          label: 'No.Kontak',
          controller: _kontakController,
          hint: 'Masukkan No.Kontak',
        ),
        _buildInputField(
          label: 'Email',
          controller: _emailController,
          hint: 'Masukkan Email',
          keyboardType: TextInputType.emailAddress,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildDataPendidikanContent() {
    return Column(
      children: [
        _buildSelectField(
          label: 'Pendidikan Terakhir',
          value: _pendidikanTerakhir,
          hint: 'Pilih Pendidikan',
          onTap: () {},
        ),
        _buildInputField(
          label: 'Nama Sekolah/Perguruan Tinggi',
          controller: _namaSekolahController,
          hint: 'Masukkan Nama Sekolah',
        ),
        _buildInputField(
          label: 'Jurusan/Program Studi',
          controller: _jurusanController,
          hint: 'Masukkan Jurusan',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildDataPekerjaanContent() {
    return Column(
      children: [
        _buildSelectField(
          label: 'Pekerjaan',
          value: _pekerjaan,
          hint: 'Pilih Pekerjaan',
          onTap: () {},
        ),
        _buildInputField(
          label: 'Perusahaan',
          controller: _perusahaanController,
          hint: 'Masukkan Nama Perusahaan',
        ),
        _buildInputField(
          label: 'Jabatan',
          controller: _jabatanController,
          hint: 'Masukkan Jabatan',
        ),
        _buildInputField(
          label: 'Alamat Organisasi/Perusahaan',
          controller: _alamatPerusahaanController,
          hint: 'Masukkan Alamat Perusahaan',
          maxLines: 2,
        ),
        _buildInputField(
          label: 'No.Kontak Perusahaan',
          controller: _noKontakPerusahaanController,
          hint: 'Masukkan No.Kontak',
        ),
        _buildSelectField(
          label: 'TUK',
          value: _tuk,
          hint: 'Pilih TUK',
          onTap: () {},
        ),
        _buildSelectField(
          label: 'Pra Asesmen Checked',
          value: _praAsesmenChecked,
          hint: 'Pilih Status',
          onTap: () {},
        ),
        _buildSelectField(
          label: 'Perangkat Asesmen',
          value: _perangkatAsesmen,
          hint: 'Pilih Perangkat',
          onTap: () {},
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String hint = '',
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
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF94A3B8),
                      ),
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
                  const SizedBox(width: 6),
                  rightAction,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectField({
    required String label,
    required String value,
    String hint = 'Pilih...',
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final bool hasValue = value.isNotEmpty;

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
                        hasValue ? value : hint,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
                          color: hasValue ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
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

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    String hint = 'dd/mm/yyyy',
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
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                    ),
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

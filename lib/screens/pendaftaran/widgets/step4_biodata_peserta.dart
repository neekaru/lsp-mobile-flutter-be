// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/master_models.dart';
import '../../../services/common/master_service.dart';
import '../../../widgets/pendaftaran/modal_select_sheet.dart';
import '../../../services/asesi/permohonan_service.dart';
import '../../../widgets/pendaftaran/biodata_form_fields.dart';
import '../../../widgets/pendaftaran/step4_biodata_sections.dart';

class Step4BiodataPeserta extends StatefulWidget {
  final int? permohonanId;

  const Step4BiodataPeserta({
    super.key,
    this.permohonanId,
  });

  @override
  State<Step4BiodataPeserta> createState() => Step4BiodataPesertaState();
}

class Step4BiodataPesertaState extends State<Step4BiodataPeserta> {
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
  late TextEditingController _tempatLahirController;
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

  // Asesor info
  String _asesorShortName = '';
  String _asesorEmail = '';
  // ignore: unused_field
  String _asesorUserCategory = '';
  // Perangkat asesmen info
  String _namaPerangkatAsesmen = '';
  String _kodePerangkatAsesmen = '';

  // Raw IDs from backend (for PUT-back)
  int? _idProvinsi;
  int? _idKabupaten;
  String _idKecamatan = '';
  int? _idPendidikan;
  int? _idPekerjaan;
  String _idPerangkat = '';
  int? _idAsesor;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _nikController = TextEditingController();
    _namaLengkapController = TextEditingController();
    _tempatLahirController = TextEditingController();
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

        // Normalisasi Jenis Kelamin
        if (realData['jenis_kelamin'] != null) {
          final jk = realData['jenis_kelamin']!;
          if (jk == '1' || jk.toLowerCase() == 'laki-laki' || jk.toLowerCase() == 'l') {
            _jenisKelamin = 'Laki-laki';
          } else if (jk == '2' || jk.toLowerCase() == 'perempuan' || jk.toLowerCase() == 'p') {
            _jenisKelamin = 'Perempuan';
          } else {
            _jenisKelamin = jk;
          }
        }

        if (realData['tempat_lahir'] != null) _tempatLahirController.text = realData['tempat_lahir']!;
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

        // Raw IDs for PUT-back
        if (realData['id_provinsi'] != null) _idProvinsi = int.tryParse(realData['id_provinsi']!);
        if (realData['id_kabupaten'] != null) _idKabupaten = int.tryParse(realData['id_kabupaten']!);
        if (realData['id_kecamatan'] != null) _idKecamatan = realData['id_kecamatan']!;
        if (realData['id_pendidikan'] != null) _idPendidikan = int.tryParse(realData['id_pendidikan']!);
        if (realData['id_pekerjaan'] != null) _idPekerjaan = int.tryParse(realData['id_pekerjaan']!);
        if (realData['id_perangkat'] != null) _idPerangkat = realData['id_perangkat']!;
        if (realData['id_asesor'] != null) _idAsesor = int.tryParse(realData['id_asesor']!);
      });

      // Auto-resolve display names dari master list berdasarkan ID
      await _resolveAsesorAndPerangkat();
    }
  }

  Future<void> _resolveAsesorAndPerangkat() async {
    final futures = await Future.wait([
      if (_idAsesor != null) PermohonanService.getMasterAsesor() else Future.value(<Map<String, dynamic>>[]),
      if (_idPerangkat.isNotEmpty) PermohonanService.getMasterPerangkat() else Future.value(<Map<String, dynamic>>[]),
    ]);

    if (!mounted) return;

    final asesorList = futures[0];
    final perangkatList = futures[1];

    setState(() {
      if (_idAsesor != null && asesorList.isNotEmpty) {
        final match = asesorList.where((e) {
          final id = e['id'];
          return (id is int ? id : int.tryParse(id.toString())) == _idAsesor;
        }).toList();
        if (match.isNotEmpty) {
          _asesorShortName = match.first['short_name'] as String? ?? '';
          _asesorEmail = match.first['email'] as String? ?? '';
          _asesorUserCategory = match.first['user_category']?.toString() ?? '';
        }
      }
      if (_idPerangkat.isNotEmpty && perangkatList.isNotEmpty) {
        final idInt = int.tryParse(_idPerangkat);
        final match = perangkatList.where((e) {
          final id = e['id'];
          return (id is int ? id : int.tryParse(id.toString())) == idInt;
        }).toList();
        if (match.isNotEmpty) {
          _namaPerangkatAsesmen = match.first['nama_perangkat'] as String? ?? '';
          _kodePerangkatAsesmen = match.first['no_perangkat'] as String? ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _nikController.dispose();
    _namaLengkapController.dispose();
    _tempatLahirController.dispose();
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

  Future<void> saveData() async {
    debugPrint('🔵 saveData called, permohonanId: ${widget.permohonanId}');
    
    if (widget.permohonanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID permohonan tidak valid'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Build update payload
    final Map<String, dynamic> updateData = {};

    // Data Peserta
    if (_skemaSertifikasi.isNotEmpty) updateData['skema_sertifikasi'] = _skemaSertifikasi;
    if (_nikController.text.isNotEmpty) updateData['nik'] = _nikController.text;
    if (_namaLengkapController.text.isNotEmpty) updateData['nama_lengkap'] = _namaLengkapController.text;
    if (_jenisKelamin.isNotEmpty) {
      updateData['jenis_kelamin'] = _jenisKelamin == 'Laki-laki' ? '1' : '2';
    }
    if (_tempatLahirController.text.isNotEmpty) updateData['tempat_lahir'] = _tempatLahirController.text;
    if (_tanggalLahirController.text.isNotEmpty) updateData['tgl_lahir'] = _tanggalLahirController.text;
    if (_alamatController.text.isNotEmpty) updateData['alamat'] = _alamatController.text;
    if (_kontakController.text.isNotEmpty) updateData['telp'] = _kontakController.text;
    if (_emailController.text.isNotEmpty) updateData['email'] = _emailController.text;

    // Label fallback string fields
    if (_provinsi.isNotEmpty) updateData['provinsi'] = _provinsi;
    if (_kabupaten.isNotEmpty) updateData['kabupaten'] = _kabupaten;
    if (_kecamatan.isNotEmpty) updateData['kecamatan'] = _kecamatan;

    // Data Pendidikan
    if (_pendidikanTerakhir.isNotEmpty) updateData['pendidikan_terakhir'] = _pendidikanTerakhir;
    if (_namaSekolahController.text.isNotEmpty) updateData['perg_tinggi'] = _namaSekolahController.text;
    if (_jurusanController.text.isNotEmpty) updateData['jurusan'] = _jurusanController.text;

    // Data Pekerjaan
    if (_pekerjaan.isNotEmpty) updateData['pekerjaan'] = _pekerjaan;
    if (_perusahaanController.text.isNotEmpty) updateData['organisasi'] = _perusahaanController.text;
    if (_jabatanController.text.isNotEmpty) updateData['jabatan'] = _jabatanController.text;
    if (_alamatPerusahaanController.text.isNotEmpty) updateData['alamat_company'] = _alamatPerusahaanController.text;
    if (_noKontakPerusahaanController.text.isNotEmpty) updateData['telp_company'] = _noKontakPerusahaanController.text;

    // ID-based fields (pass raw IDs back to backend)
    if (_idProvinsi != null) updateData['id_provinsi'] = _idProvinsi;
    if (_idKabupaten != null) updateData['id_kabupaten'] = _idKabupaten;
    if (_idKecamatan.isNotEmpty) updateData['id_kecamatan'] = _idKecamatan;
    if (_idPendidikan != null) updateData['id_pendidikan'] = _idPendidikan;
    if (_idPekerjaan != null) updateData['id_pekerjaan'] = _idPekerjaan;
    if (_idPerangkat.isNotEmpty) {
      final perangkatInt = int.tryParse(_idPerangkat);
      if (perangkatInt != null) updateData['id_perangkat'] = perangkatInt;
    }
    if (_idAsesor != null) updateData['id_asesor'] = _idAsesor;
    if (_asesorShortName.isNotEmpty) updateData['asesor_short_name'] = _asesorShortName;
    if (_asesorEmail.isNotEmpty) updateData['asesor_email'] = _asesorEmail;
    if (_asesorUserCategory.isNotEmpty) updateData['asesor_user_category'] = _asesorUserCategory;
    if (_namaPerangkatAsesmen.isNotEmpty) updateData['nama_perangkat_asesmen'] = _namaPerangkatAsesmen;
    if (_kodePerangkatAsesmen.isNotEmpty) updateData['kode_perangkat_asesmen'] = _kodePerangkatAsesmen;

    if (updateData.isEmpty) {
      debugPrint('⚠️ updateData is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data yang diubah'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    debugPrint('🟢 updateData: $updateData');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint('🔵 Calling updatePermohonan API...');
      final result = await PermohonanService.updatePermohonan(
        widget.permohonanId!,
        updateData,
      );

      debugPrint('🟢 API result: $result');

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (result != null && result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Data berhasil disimpan'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'Gagal menyimpan data'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper Modal Selector
  void _showModalSelect<T>({
    required String title,
    List<T>? items,
    Future<List<T>> Function()? fetchItems,
    required String Function(T item) labelOf,
    required String currentSelectedLabel,
    required ValueChanged<T> onSelected,
    bool showSearch = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ModalSelectSheet<T>(
          title: title,
          items: items,
          fetchItems: fetchItems,
          labelOf: labelOf,
          currentSelectedLabel: currentSelectedLabel,
          onSelected: (val) {
            onSelected(val);
            Navigator.pop(context);
          },
          showSearch: showSearch,
        );
      },
    );
  }

  // Selection Handler: Skema Sertifikasi
  void _selectSkemaSertifikasi() {
    _showModalSelect<Map<String, dynamic>>(
      title: 'Pilih Skema Sertifikasi',
      fetchItems: () => PermohonanService.getMasterSkema(),
      labelOf: (item) => item['skema'] as String,
      currentSelectedLabel: _skemaSertifikasi,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _skemaSertifikasi = val['skema'] as String;
        });
      },
    );
  }

  // 1. Selection Handler: Jenis Kelamin
  void _selectJenisKelamin() {
    _showModalSelect<String>(
      title: 'Pilih Jenis Kelamin',
      items: ['Laki-laki', 'Perempuan'],
      labelOf: (item) => item,
      currentSelectedLabel: _jenisKelamin,
      onSelected: (val) {
        setState(() {
          _jenisKelamin = val;
        });
      },
    );
  }

  // 2. Selection Handler: Provinsi
  void _selectProvinsi() {
    _showModalSelect<MasterItem>(
      title: 'Pilih Provinsi',
      fetchItems: () => MasterService.getProvinsiList(),
      labelOf: (item) => item.name,
      currentSelectedLabel: _provinsi,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _provinsi = val.name;
          _idProvinsi = int.tryParse(val.id);
          _kabupaten = '';
          _idKabupaten = null;
          _kecamatan = '';
          _idKecamatan = '';
        });
      },
    );
  }

  // 3. Selection Handler: Kabupaten/Kota
  void _selectKabupaten() {
    if (_idProvinsi == null && _provinsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih Provinsi terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _showModalSelect<MasterItem>(
      title: 'Pilih Kabupaten/Kota',
      fetchItems: () async {
        if (_idProvinsi == null && _provinsi.isNotEmpty) {
          final provs = await MasterService.getProvinsiList();
          final match = provs.firstWhere(
            (e) => e.name.toLowerCase() == _provinsi.toLowerCase(),
            orElse: () => const MasterItem(id: '', name: ''),
          );
          if (match.id.isNotEmpty) {
            _idProvinsi = int.tryParse(match.id);
          }
        }
        return MasterService.getKabupatenList(_idProvinsi?.toString() ?? '');
      },
      labelOf: (item) => item.name,
      currentSelectedLabel: _kabupaten,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _kabupaten = val.name;
          _idKabupaten = int.tryParse(val.id);
          _kecamatan = '';
          _idKecamatan = '';
        });
      },
    );
  }

  // 4. Selection Handler: Kecamatan
  void _selectKecamatan() {
    if (_idKabupaten == null && _kabupaten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih Kabupaten/Kota terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _showModalSelect<MasterItem>(
      title: 'Pilih Kecamatan',
      fetchItems: () async {
        if (_idKabupaten == null && _kabupaten.isNotEmpty) {
          if (_idProvinsi == null && _provinsi.isNotEmpty) {
            final provs = await MasterService.getProvinsiList();
            final match = provs.firstWhere(
              (e) => e.name.toLowerCase() == _provinsi.toLowerCase(),
              orElse: () => const MasterItem(id: '', name: ''),
            );
            if (match.id.isNotEmpty) {
              _idProvinsi = int.tryParse(match.id);
            }
          }
          if (_idProvinsi != null) {
            final kabs = await MasterService.getKabupatenList(_idProvinsi.toString());
            final matchKab = kabs.firstWhere(
              (e) => e.name.toLowerCase() == _kabupaten.toLowerCase(),
              orElse: () => const MasterItem(id: '', name: ''),
            );
            if (matchKab.id.isNotEmpty) {
              _idKabupaten = int.tryParse(matchKab.id);
            }
          }
        }
        return MasterService.getKecamatanList(_idKabupaten?.toString() ?? '');
      },
      labelOf: (item) => item.name,
      currentSelectedLabel: _kecamatan,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _kecamatan = val.name;
          _idKecamatan = val.id;
        });
      },
    );
  }

  // 5. Selection Handler: Pendidikan Terakhir
  void _selectPendidikanTerakhir() {
    _showModalSelect<MasterPendidikan>(
      title: 'Pilih Pendidikan Terakhir',
      fetchItems: () async {
        final list = await MasterService.getMasterPendidikanList();
        if (list.isNotEmpty) return list;
        return const [
          MasterPendidikan(id: 1, namaPendidikan: 'SD / Sederajat'),
          MasterPendidikan(id: 2, namaPendidikan: 'SMP / Sederajat'),
          MasterPendidikan(id: 3, namaPendidikan: 'SMA / SMK / Sederajat'),
          MasterPendidikan(id: 4, namaPendidikan: 'D3 / Sederajat'),
          MasterPendidikan(id: 5, namaPendidikan: 'D4 / S1'),
          MasterPendidikan(id: 6, namaPendidikan: 'S2'),
          MasterPendidikan(id: 7, namaPendidikan: 'S3'),
        ];
      },
      labelOf: (item) => item.displayName,
      currentSelectedLabel: _pendidikanTerakhir,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _pendidikanTerakhir = val.displayName;
          _idPendidikan = val.id;
        });
      },
    );
  }

  // 6. Selection Handler: Pekerjaan
  void _selectPekerjaan() {
    _showModalSelect<MasterPekerjaan>(
      title: 'Pilih Pekerjaan',
      fetchItems: () async {
        final list = await MasterService.getMasterPekerjaanList();
        if (list.isNotEmpty) return list;
        return const [
          MasterPekerjaan(id: 1, namaPekerjaan: 'Siswa / Mahasiswa'),
          MasterPekerjaan(id: 2, namaPekerjaan: 'Karyawan Swasta'),
          MasterPekerjaan(id: 3, namaPekerjaan: 'PNS / ASN'),
          MasterPekerjaan(id: 4, namaPekerjaan: 'Wiraswasta / Pengusaha'),
          MasterPekerjaan(id: 5, namaPekerjaan: 'BUMN / BUMD'),
          MasterPekerjaan(id: 6, namaPekerjaan: 'Dosen / Pengajar'),
          MasterPekerjaan(id: 7, namaPekerjaan: 'Lainnya'),
        ];
      },
      labelOf: (item) => item.displayName,
      currentSelectedLabel: _pekerjaan,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _pekerjaan = val.displayName;
          _idPekerjaan = val.id;
        });
      },
    );
  }

  // 7. Selection Handler: TUK
  void _selectTUK() {
    final defaultOptions = [
      'TUK Sewaktu',
      'TUK Tempat Kerja',
      'TUK Mandiri',
      'TUK Pusat',
    ];
    if (_tuk.isNotEmpty && !defaultOptions.contains(_tuk)) {
      defaultOptions.insert(0, _tuk);
    }
    _showModalSelect<String>(
      title: 'Pilih TUK',
      items: defaultOptions,
      labelOf: (item) => item,
      currentSelectedLabel: _tuk,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _tuk = val;
        });
      },
    );
  }

  // 8. Selection Handler: Pra Asesmen Checked → Asesor dari API
  void _selectPraAsesmenChecked() {
    _showModalSelect<Map<String, dynamic>>(
      title: 'Pilih Asesor',
      fetchItems: () => PermohonanService.getMasterAsesor(),
      labelOf: (item) {
        final name = item['short_name'] as String;
        final email = item['email'] as String;
        return email.isNotEmpty ? '$name ($email)' : name;
      },
      currentSelectedLabel: _asesorShortName,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _asesorShortName = val['short_name'] as String;
          _asesorEmail = val['email'] as String;
          _asesorUserCategory = val['user_category']?.toString() ?? '';
          final id = val['id'];
          _idAsesor = id is int ? id : int.tryParse(id.toString());
        });
      },
    );
  }

  // 9. Selection Handler: Perangkat Asesmen → dari API
  void _selectPerangkatAsesmen() {
    _showModalSelect<Map<String, dynamic>>(
      title: 'Pilih Perangkat Asesmen',
      fetchItems: () => PermohonanService.getMasterPerangkat(),
      labelOf: (item) {
        final nama = item['nama_perangkat'] as String;
        final kode = item['no_perangkat'] as String;
        return kode.isNotEmpty ? '$nama [$kode]' : nama;
      },
      currentSelectedLabel: _namaPerangkatAsesmen,
      showSearch: true,
      onSelected: (val) {
        setState(() {
          _namaPerangkatAsesmen = val['nama_perangkat'] as String;
          _kodePerangkatAsesmen = val['no_perangkat'] as String;
          final id = val['id'];
          final idInt = id is int ? id : int.tryParse(id.toString());
          if (idInt != null) _idPerangkat = idInt.toString();
        });
      },
    );
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

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor kontak belum terisi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String formattedPhone = cleanPhone;
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    } else if (formattedPhone.startsWith('+')) {
      formattedPhone = formattedPhone.substring(1);
    }

    final Uri waUrl = Uri.parse('https://wa.me/$formattedPhone');
    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka WhatsApp: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBanner(),
        const SizedBox(height: 12),
        BiodataAccordionCard(
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
        BiodataAccordionCard(
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
        BiodataAccordionCard(
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
    return const Step4TopBanner();
  }

  Widget _buildDataPesertaContent() {
    return DataPesertaBiodataSection(
      skemaSertifikasi: _skemaSertifikasi,
      onSelectSkema: _selectSkemaSertifikasi,
      idController: _idController,
      nikController: _nikController,
      namaLengkapController: _namaLengkapController,
      jenisKelamin: _jenisKelamin,
      onSelectJenisKelamin: _selectJenisKelamin,
      tempatLahirController: _tempatLahirController,
      tanggalLahirController: _tanggalLahirController,
      onSelectTanggalLahir: () => _selectDate(context),
      alamatController: _alamatController,
      provinsi: _provinsi,
      onSelectProvinsi: _selectProvinsi,
      kabupaten: _kabupaten,
      onSelectKabupaten: _selectKabupaten,
      kecamatan: _kecamatan,
      onSelectKecamatan: _selectKecamatan,
      kontakController: _kontakController,
      onOpenWhatsApp: () => _openWhatsApp(_kontakController.text),
      emailController: _emailController,
      onLihatKtp: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membuka dokumen KTP...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildDataPendidikanContent() {
    return DataPendidikanBiodataSection(
      pendidikanTerakhir: _pendidikanTerakhir,
      onSelectPendidikan: _selectPendidikanTerakhir,
      namaSekolahController: _namaSekolahController,
      jurusanController: _jurusanController,
    );
  }

  Widget _buildDataPekerjaanContent() {
    return DataPekerjaanBiodataSection(
      pekerjaan: _pekerjaan,
      onSelectPekerjaan: _selectPekerjaan,
      perusahaanController: _perusahaanController,
      jabatanController: _jabatanController,
      alamatPerusahaanController: _alamatPerusahaanController,
      noKontakPerusahaanController: _noKontakPerusahaanController,
      onOpenWhatsAppPerusahaan: () => _openWhatsApp(_noKontakPerusahaanController.text),
      tuk: _tuk,
      onSelectTUK: _selectTUK,
      asesorValue: _asesorShortName.isNotEmpty && _asesorEmail.isNotEmpty
          ? '$_asesorShortName ($_asesorEmail)'
          : _asesorShortName,
      onSelectAsesor: _selectPraAsesmenChecked,
      perangkatValue: _namaPerangkatAsesmen.isNotEmpty && _kodePerangkatAsesmen.isNotEmpty
          ? '$_namaPerangkatAsesmen [$_kodePerangkatAsesmen]'
          : _namaPerangkatAsesmen,
      onSelectPerangkat: _selectPerangkatAsesmen,
    );
  }
}

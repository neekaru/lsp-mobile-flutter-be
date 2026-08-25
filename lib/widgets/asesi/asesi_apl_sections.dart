// ============================================================================
// Section form APL-01 & APL-02 (asesi).
//
// Diekstrak dari asesi_form_sections.dart agar tiap bagian form asesi
// menjadi modul tersendiri.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/asesor_asesi_models.dart';
import '../../screens/instrumen/instrumen_asesmen_screen.dart';
import '../../services/asesor/asesor_service.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

// ── 1. APL-01 ─────────────────────────────────────────────────────────────
class APL01Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const APL01Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final apl01 = detailData?.apl01;
    final dasarList = apl01?.persyaratanDasar ?? [];
    final adminList = apl01?.persyaratanAdministratif ?? [];
    final allDocs = apl01?.buktiDokumen ?? [];

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-APL.01 Permohonan Sertifikasi',
            status: (apl01?.status != null && apl01!.status.isNotEmpty)
                ? apl01.status
                : 'Belum Tervalidasi',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow(
            'Rekomendasi Admin',
            (apl01?.rekomendasi != null &&
                    apl01!.rekomendasi.isNotEmpty &&
                    apl01.rekomendasi != '0')
                ? apl01.rekomendasi
                : 'Belum Divalidasi',
          ),
          if (apl01?.catatan.isNotEmpty == true)
            AsesiDetailRow('Catatan', apl01!.catatan),
          if (apl01?.tanggalValidasi.isNotEmpty == true)
            AsesiDetailRow(
              'Tanggal Validasi',
              DateFormatHelper.formatToIndonesianWithTime(apl01!.tanggalValidasi),
            ),
          const SizedBox(height: 16),

          // 1. PERSYARATAN DASAR
          const Text(
            'PERSYARATAN DASAR',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          if (dasarList.isNotEmpty)
            ...dasarList.asMap().entries.map(
                  (entry) => DocItem(
                    index: entry.key + 1,
                    name: entry.value.nama,
                    jenis: entry.value.jenis,
                    ada: entry.value.ada,
                    url: entry.value.url,
                  ),
                )
          else if (allDocs.any((d) => d.jenis == 'Dasar' || (d.jenis == 'Wajib' && d.jenisBukti != 'foto' && d.jenisBukti != 'ktp_kk')))
            ...allDocs
                .where((d) => d.jenis == 'Dasar' || (d.jenis == 'Wajib' && d.jenisBukti != 'foto' && d.jenisBukti != 'ktp_kk'))
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => DocItem(
                    index: entry.key + 1,
                    name: entry.value.nama,
                    jenis: entry.value.jenis,
                    ada: entry.value.ada,
                    url: entry.value.url,
                  ),
                )
          else ...[
            const DocItem(index: 1, name: 'Foto Copy Transkrip Nilai / Ijazah Terakhir', jenis: 'Dasar', ada: true),
            const DocItem(index: 2, name: 'Foto Copy Sertifikat Pelatihan Berbasis Kompetensi', jenis: 'Dasar', ada: false),
            const DocItem(index: 3, name: 'Surat Keterangan Pengalaman Kerja di Bidang Terkait', jenis: 'Dasar', ada: false),
          ],

          const SizedBox(height: 18),

          // 2. PERSYARATAN ADMINISTRATIF
          const Text(
            'PERSYARATAN ADMINISTRATIF',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          if (adminList.isNotEmpty)
            ...adminList.asMap().entries.map(
                  (entry) => DocItem(
                    index: entry.key + 1,
                    name: entry.value.nama,
                    jenis: entry.value.jenis,
                    ada: entry.value.ada,
                    url: entry.value.url,
                  ),
                )
          else ...[
            DocItem(
              index: 1,
              name: 'Pasfoto *',
              jenis: 'Wajib',
              ada: detailData?.fotoProfilUrl != null && detailData!.fotoProfilUrl!.isNotEmpty,
              url: detailData?.fotoProfilUrl,
            ),
            DocItem(
              index: 2,
              name: 'Identitas Pribadi (KTP / Kartu Pelajar) *',
              jenis: 'Wajib',
              ada: (detailData?.nik.isNotEmpty ?? false),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 2. APL-02 ─────────────────────────────────────────────────────────────
class APL02Section extends StatefulWidget {
  final AsesorAsesiDetailData? detailData;
  final VoidCallback? onSaveSuccess;

  const APL02Section({
    super.key,
    required this.detailData,
    this.onSaveSuccess,
  });

  @override
  State<APL02Section> createState() => _APL02SectionState();
}

class _APL02SectionState extends State<APL02Section> {
  late TextEditingController _catatanController;
  late String _selectedTanggal;
  late String _selectedRekomendasi;
  late bool _isAgreed;
  late String _selectedKandidat;
  int? _selectedMapaId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  @override
  void didUpdateWidget(covariant APL02Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detailData != widget.detailData) {
      _initValues();
    }
  }

  void _initValues() {
    final apl02 = widget.detailData?.apl02;
    final tgl = apl02?.tanggal.trim() ?? '';
    _selectedTanggal = (tgl.isNotEmpty && !tgl.startsWith('0000') && !tgl.startsWith('0001'))
        ? tgl
        : DateTime.now().toIso8601String().substring(0, 10);
    _selectedRekomendasi = (apl02?.praAsesmen != null &&
            apl02!.praAsesmen != '0' &&
            apl02.praAsesmen.isNotEmpty)
        ? apl02.praAsesmen
        : '1';
    _catatanController = TextEditingController(
      text: (apl02?.catatanRekomendasi.isNotEmpty ?? false)
          ? apl02!.catatanRekomendasi
          : 'Di rekomendasi menjadi peserta uji kompetensi',
    );
    _isAgreed = apl02?.isApproved ?? true;
    _selectedKandidat = (apl02?.kandidat.isNotEmpty ?? false)
        ? apl02!.kandidat
        : '1';
    _selectedMapaId = (apl02?.idMapa != null && apl02!.idMapa! > 0) ? apl02.idMapa : null;
    if (_selectedMapaId == null && (apl02?.mapaOptions.isNotEmpty ?? false)) {
      final validList = _filterMapaOptions(apl02!.mapaOptions, _selectedKandidat);
      _selectedMapaId = validList.isNotEmpty ? validList.first.id : apl02.mapaOptions.first.id;
    }
  }

  bool _isPortofolio(MapaOption m) {
    final t = '${m.namaMapa} ${m.displayText}'.toLowerCase();
    return t.contains('portofolio') || t.contains('porotofolio') || t.contains('portfolio');
  }

  List<MapaOption> _filterMapaOptions(List<MapaOption> options, String kandidat) {
    final isExp = kandidat == '3';
    final filtered = options.where((m) {
      final isPort = _isPortofolio(m);
      if (isExp) {
        return isPort;
      } else {
        return !isPort ||
            m.namaMapa.toLowerCase().contains('observasi') ||
            m.namaMapa.toLowerCase().contains('terstruktur');
      }
    }).toList();
    return filtered.isNotEmpty ? filtered : options;
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.tryParse(_selectedTanggal) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTanggal = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _submitAPL02() async {
    final asesiId = widget.detailData?.id;
    if (asesiId == null || asesiId == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    final res = await AsesorService.updateAPL02(
      asesiId: asesiId,
      praAsesmen: _selectedRekomendasi,
      catatanRekomendasi: _catatanController.text.trim(),
      tanggal: _selectedTanggal,
      isApproved: _isAgreed,
      kandidat: _selectedKandidat,
      idMapa: _selectedMapaId,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (res != null && res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Rekomendasi FR-APL.02 berhasil disimpan'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onSaveSuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res?['message'] ?? 'Gagal menyimpan rekomendasi FR-APL.02'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _resolveQrCodeUrl() {
    final raw = widget.detailData?.apl02.qrCodeData.trim() ?? '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    final asesiId = widget.detailData?.id ?? 0;
    final jadwalId = widget.detailData?.jadwalId ?? 0;
    if (asesiId > 0 && jadwalId > 0) {
      return 'https://sertifikasi.lspdigital.id/qrcode/e_dokumen/0/$jadwalId/$asesiId/validasi_apl02';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final apl02 = widget.detailData?.apl02;
    final kandidatOptions = apl02?.kandidatOptions ?? [];
    final mapaOptions = apl02?.mapaOptions ?? [];
    final qrUrl = _resolveQrCodeUrl();

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-APL.02 Asesmen Mandiri',
            status: apl02?.status ?? 'Lengkap',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // ── Stat Row ──
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  'Total Unit',
                  '${apl02?.totalUnit ?? 0}',
                  const Color(0xFF2563EB),
                  const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  'Kompeten [K]',
                  '${apl02?.totalK ?? 0}',
                  const Color(0xFF059669),
                  const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  'Belum [BK]',
                  '${apl02?.totalBK ?? 0}',
                  const Color(0xFFDC2626),
                  const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Unit List ──
          const Text(
            'Daftar Unit Kompetensi:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (apl02 != null && apl02.units.isNotEmpty)
            ...apl02.units.map((u) => UnitItem(unit: u))
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Data unit kompetensi telah tervalidasi kompeten pada skema sertifikasi.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // ── FORM PENGISIAN ASESOR (APL-02) ──
          const Text(
            'REKOMENDASI PRA-ASESMEN (FR-APL.02)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Field 1: Tanggal
          const Text(
            'Tanggal :',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormatHelper.formatToIndonesian(_selectedTanggal),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                  ),
                  const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Field 2: Rekomendasi
          const Text(
            'Rekomendasi :',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedRekomendasi,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Asesmen Dilanjutkan')),
                  DropdownMenuItem(value: '2', child: Text('Tidak dapat dilanjutkan')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRekomendasi = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Field 3: Catatan Rekomendasi
          const Text(
            'Catatan Rekomendasi :',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _catatanController,
            maxLines: 2,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // QR Code Digital Validation Preview
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (qrUrl.isNotEmpty)
                    QrImageView(
                      data: qrUrl,
                      version: QrVersions.auto,
                      size: 110.0,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    )
                  else
                    const Icon(LucideIcons.qr_code, size: 84, color: Color(0xFF0F172A)),
                  const SizedBox(height: 6),
                  const Text(
                    'Tanda Tangan Elektronik Asesor Tervalidasi',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Checkbox Persetujuan
          InkWell(
            onTap: () {
              setState(() {
                _isAgreed = !_isAgreed;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (val) {
                    setState(() {
                      _isAgreed = val ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'Saya setuju menandatangani dokumen ini.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── SECTION FR.MAPA-01 & 02 (Green Banner) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF65A30D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'FR.MAPA-01 & 02',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Field Kandidat
          const Text(
            'Kandidat :',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedKandidat,
                style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                items: (kandidatOptions.isNotEmpty ? kandidatOptions : [
                  KandidatOption(
                    id: '1',
                    label: '1. Hasil Pelatihan dan / atau pendidikan dimana Kurikulum dan fasilitas praktek mampu telusur terhadap standar kompetensi.',
                  ),
                  KandidatOption(
                    id: '2',
                    label: '2. Hasil Pelatihan dan / atau pendidikan dimana kurikulum belum berbasis kompetensi.',
                  ),
                  KandidatOption(
                    id: '3',
                    label: '3. Pekerja berpengalaman.',
                  ),
                  KandidatOption(
                    id: '4',
                    label: '4. Pelatihan / Belajar Mandiri.',
                  ),
                ]).map((k) {
                  return DropdownMenuItem<String>(
                    value: k.id,
                    child: Text(
                      k.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedKandidat = val;
                      final validOptions = _filterMapaOptions(mapaOptions, val);
                      if (validOptions.isNotEmpty &&
                          !validOptions.any((m) => m.id == _selectedMapaId)) {
                        _selectedMapaId = validOptions.first.id;
                      }
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Field MAPA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MAPA :',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              Text(
                _selectedKandidat == '3' ? '(Metode Portofolio)' : '(Metode Observasi & Terstruktur)',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Builder(
            builder: (context) {
              final isExp = _selectedKandidat == '3';
              final effectiveList = _filterMapaOptions(mapaOptions, _selectedKandidat);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: (effectiveList.any((m) => m.id == _selectedMapaId)) ? _selectedMapaId : null,
                    hint: Text(
                      effectiveList.isEmpty
                          ? 'Tidak ada pilihan MAPA untuk skema ini'
                          : (isExp ? 'Pilih MAPA Portofolio...' : 'Pilih MAPA Observasi/Terstruktur...'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                    items: effectiveList.map((m) {
                      return DropdownMenuItem<int>(
                        value: m.id,
                        child: Text(
                          m.displayText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: effectiveList.isEmpty
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMapaId = val;
                              });
                            }
                          },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // ── Link ke Halaman Instrumen Asesmen (FR.IA) ──
          Builder(
            builder: (context) {
              final selectedMapa = mapaOptions.firstWhere(
                (m) => m.id == _selectedMapaId,
                orElse: () => MapaOption(id: 0, namaMapa: '', displayText: ''),
              );
              final isPorto = selectedMapa.isPortofolio || _selectedKandidat == '3';
              final String metodeBadge = isPorto
                  ? 'Verifikasi Portofolio'
                  : (selectedMapa.metode == 'terstruktur' ? 'Kegiatan Terstruktur' : 'Observasi Langsung');

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPorto ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPorto ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clipboard_check,
                              size: 18,
                              color: isPorto ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instrumen Asesmen (FR.IA)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isPorto ? const Color(0xFF92400E) : const Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPorto ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            metodeBadge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPorto ? const Color(0xFFB45309) : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPorto
                          ? 'Sesuai metode Portofolio yang dipilih pada MAPA, silakan buka dan lengkapi lembar instrumen asesmen:'
                          : 'Sesuai metode yang dipilih pada MAPA, silakan buka dan lengkapi lembar instrumen asesmen:',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.35),
                    ),
                    const SizedBox(height: 10),

                    // Dynamic buttons based on selected MAPA and candidate
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (selectedMapa.isInstrumentActive('IA01', _selectedKandidat))
                          _buildIAQuickButton(
                            context,
                            code: 'FR.IA.01',
                            label: 'IA.01 Observasi',
                            formId: 'IA01',
                            color: const Color(0xFF2563EB),
                          ),
                        if (selectedMapa.isInstrumentActive('IA02', _selectedKandidat))
                          _buildIAQuickButton(
                            context,
                            code: 'FR.IA.02',
                            label: 'IA.02 Tugas Praktik',
                            formId: 'IA02',
                            color: const Color(0xFF0284C7),
                          ),
                        if (selectedMapa.isInstrumentActive('IA03', _selectedKandidat))
                          _buildIAQuickButton(
                            context,
                            code: 'FR.IA.03',
                            label: isPorto ? 'IA.03 Tanya Lisan (Wawancara)' : 'IA.03 Tanya Lisan',
                            formId: 'IA03',
                            color: const Color(0xFFD97706),
                          ),
                        if (selectedMapa.isInstrumentActive('IA05', _selectedKandidat))
                          _buildIAQuickButton(
                            context,
                            code: 'FR.IA.05',
                            label: 'IA.05 Tanya Tertulis',
                            formId: 'IA05',
                            color: const Color(0xFF16A34A),
                          ),
                        if (selectedMapa.isInstrumentActive('IA06', _selectedKandidat))
                          _buildIAQuickButton(
                            context,
                            code: 'FR.IA.06',
                            label: 'IA.06 Tanya Esai',
                            formId: 'IA06',
                            color: const Color(0xFF0D9488),
                          ),
                        if (selectedMapa.isInstrumentActive('IA11', _selectedKandidat))
                          _buildIAQuickButton(
                            context,
                            code: 'FR.IA.11',
                            label: 'IA.11 Verifikasi Portofolio',
                            formId: 'IA11',
                            color: const Color(0xFF7C3AED),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitAPL02,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(LucideIcons.save, size: 16),
              label: Text(
                _isSubmitting ? 'Menyimpan...' : 'Simpan Rekomendasi FR-APL.02',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIAQuickButton(
    BuildContext context, {
    required String code,
    required String label,
    required String formId,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InstrumenAsesmenScreen(
              asesiId: widget.detailData?.id ?? 0,
              namaAsesi: widget.detailData?.namaLengkap ?? 'Peserta Asesmen',
              skema: widget.detailData?.skemaSertifikat ?? 'Skema Sertifikasi',
              tuk: widget.detailData?.tukNama ?? 'TUK',
              jadwal: widget.detailData?.jadwalNama ?? 'Jadwal Asesmen',
              initialForm: formId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(LucideIcons.external_link, size: 11, color: color),
          ],
        ),
      ),
    );
  }
}

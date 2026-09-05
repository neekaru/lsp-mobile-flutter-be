import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/asesi/asesi_form_common.dart';

class JadwalAK05Screen extends StatefulWidget {
  final int jadwalId;
  final String jadwalTitle;

  const JadwalAK05Screen({
    super.key,
    required this.jadwalId,
    required this.jadwalTitle,
  });

  @override
  State<JadwalAK05Screen> createState() => _JadwalAK05ScreenState();
}

class _JadwalAK05ScreenState extends State<JadwalAK05Screen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  JadwalAK05DetailData? _detailData;

  late TextEditingController _linkRekamanController;
  late TextEditingController _pencapaianController;
  late TextEditingController _unitBkController;
  late TextEditingController _saranController;
  late TextEditingController _peliharaController;
  late TextEditingController _catatanController;

  @override
  void initState() {
    super.initState();
    _linkRekamanController = TextEditingController();
    _pencapaianController = TextEditingController();
    _unitBkController = TextEditingController();
    _saranController = TextEditingController();
    _peliharaController = TextEditingController();
    _catatanController = TextEditingController();
    _fetchDetail();
  }

  @override
  void dispose() {
    _linkRekamanController.dispose();
    _pencapaianController.dispose();
    _unitBkController.dispose();
    _saranController.dispose();
    _peliharaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await AsesorService.getJadwalAK05(widget.jadwalId);
      if (res != null && res['data'] != null) {
        final data = JadwalAK05DetailData.fromJson(res['data'] as Map<String, dynamic>);
        setState(() {
          _detailData = data;
          _linkRekamanController.text = data.linkRekamanAsesor.isNotEmpty
              ? data.linkRekamanAsesor
              : data.linkFolderRekaman;
          _pencapaianController.text = data.pencapaian;
          _unitBkController.text = data.unitBk;
          _saranController.text = data.saranTindakLanjut;
          _peliharaController.text = data.peliharaKompetensi;
          _catatanController.text = data.catatan;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data FR-AK.05';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAK05() async {
    if (_detailData == null) return;
    if (!_detailData!.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_detailData!.lockReason.isNotEmpty
              ? _detailData!.lockReason
              : 'Selesaikan formulir FR-AK.01 terlebih dahulu.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    try {
      final pesertaList = _detailData!.peserta.map((p) {
        return {
          'id': p.id,
          'rekomendasi': p.rekomendasiAsesor,
          'unit_bk': p.unitBk,
        };
      }).toList();

      final payload = {
        'link_rekaman_asesmen': _linkRekamanController.text.trim(),
        'pencapaian': _pencapaianController.text.trim(),
        'unit_bk': _unitBkController.text.trim(),
        'saran_tindak_lanjut': _saranController.text.trim(),
        'pelihara_kompetensi': _peliharaController.text.trim(),
        'catatan': _catatanController.text.trim(),
        'peserta_rekomendasi': pesertaList,
      };

      final res = await AsesorService.saveJadwalAK05(jadwalId: widget.jadwalId, data: payload);
      if (res != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan Asesmen FR-AK.05 berhasil disimpan!'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchDetail();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan laporan asesmen.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    try {
      final uri = Uri.parse(urlString);
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(title: 'FR-AK.05 Laporan Asesmen'),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetchDetail,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _detailData!;
    final isSubmitted = data.statusLaporan == 'Sudah Diserahkan';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Lock Banner (if AK.01 not yet completed) ─────────────────────────
          if (!data.isUnlocked) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Color(0xFFDC2626), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Formulir FR-AK.05 Terkunci',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.lockReason.isNotEmpty
                              ? data.lockReason
                              : 'Selesaikan dan setujui formulir FR-AK.01 terlebih dahulu sebelum mengisi formulir Laporan Asesmen.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFB91C1C),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Card 1: Informasi Asesmen & Link Folder ──────────────────────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormSectionHeader(
                  title: 'Informasi Pelaksanaan Asesmen',
                  status: data.statusLaporan,
                  statusColor: isSubmitted ? const Color(0xFF16A34A) : const Color(0xFFEAB308),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                AsesiDetailRow('Skema Sertifikasi', data.skema.isNotEmpty ? data.skema : '-'),
                if (data.kodeSkema.isNotEmpty)
                  AsesiDetailRow('Kode Skema', data.kodeSkema),
                AsesiDetailRow('Nama Jadwal', data.namaJadwal.isNotEmpty ? data.namaJadwal : widget.jadwalTitle),
                AsesiDetailRow('TUK', data.tuk.isNotEmpty ? data.tuk : '-'),
                AsesiDetailRow('Kuota & Tanggal', '${data.kuota} • ${data.tanggal}'),
                AsesiDetailRow('SK Verifikasi TUK', data.skVerifikasiTuk),
                const SizedBox(height: 12),

                // Link Folder Rekaman Cloud LSP
                if (data.linkFolderRekaman.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Link Folder Rekaman :',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _launchURL(data.linkFolderRekaman),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.cloud, size: 14, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text(
                                'Link Folder Cloud',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: data.linkFolderRekaman));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link Folder Cloud berhasil disalin!'),
                              backgroundColor: Color(0xFF2563EB),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.copy, size: 13, color: Color(0xFF475569)),
                              SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Field Input: Link Rekaman Asesmen
                const Text(
                  'Link Rekaman Asesmen :',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(LucideIcons.video, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _linkRekamanController,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'https://cloud.lspdigital.id/s/... atau Google Drive',
                            hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tempel dari Clipboard',
                        icon: const Icon(LucideIcons.clipboard, size: 16, color: Color(0xFF64748B)),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null && data!.text!.isNotEmpty) {
                            setState(() {
                              _linkRekamanController.text = data.text!.trim();
                            });
                          }
                        },
                      ),
                      if (_linkRekamanController.text.isNotEmpty)
                        IconButton(
                          tooltip: 'Buka Tautan',
                          icon: const Icon(LucideIcons.external_link, size: 16, color: Color(0xFF2563EB)),
                          onPressed: () => _launchURL(_linkRekamanController.text.trim()),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Keterangan Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '*Keterangan : Link rekaman bisa menggunakan Link Folder Cloud atau Link Google Drive pribadi, pastikan link dapat diakses oleh asesor dan admin.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Rekaman berisi :\n1. Hasil Pekerjaan atau Project Asesi\n2. Rekaman Verifikasi TUK, Rekaman Pra Asesmen, Rekaman Asesmen',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Card 1.5: Asesor Bertugas & Link Dokumentasi / Rekaman Uji ─────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Asesor Bertugas & Link Rekaman Uji',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${data.daftarAsesor.isNotEmpty ? data.daftarAsesor.length : 1} Asesor',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                if (data.daftarAsesor.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. ${data.namaAsesor}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_linkRekamanController.text.isNotEmpty)
                          InkWell(
                            onTap: () => _launchURL(_linkRekamanController.text.trim()),
                            child: Text(
                              _linkRekamanController.text.trim(),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF2563EB),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        else
                          const Text(
                            '(Belum ada link rekaman)',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                          ),
                      ],
                    ),
                  )
                else
                  ...data.daftarAsesor.asMap().entries.map((entry) {
                    final index = entry.key;
                    final as = entry.value;
                    final link = as.linkRekaman.isNotEmpty
                        ? as.linkRekaman
                        : (_linkRekamanController.text.isNotEmpty
                            ? _linkRekamanController.text.trim()
                            : '');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${as.masaAktif} • ${as.noReg}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      as.namaAsesor,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Link Rekaman Asesor
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.link, size: 14, color: Color(0xFF2563EB)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: link.isNotEmpty
                                      ? InkWell(
                                          onTap: () => _launchURL(link),
                                          child: Text(
                                            link,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      : const Text(
                                          'Belum ada link rekaman tersimpan',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                ),
                                if (link.isNotEmpty)
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: link));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Link rekaman berhasil disalin!'),
                                          backgroundColor: Color(0xFF2563EB),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(LucideIcons.copy, size: 14, color: Color(0xFF64748B)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Summary K / BK / Belum
                          Row(
                            children: [
                              _buildCountChip('K', as.totalK, const Color(0xFF16A34A)),
                              const SizedBox(width: 6),
                              _buildCountChip('BK', as.totalBk, const Color(0xFFDC2626)),
                              const SizedBox(width: 6),
                              _buildCountChip('Belum', as.totalBelum, const Color(0xFF94A3B8)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Sistem Penilaian Asesi (Daftar & Dropdown) ────────────────────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Penilaian Peserta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Total: ${data.peserta.length} Peserta',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                // Info note
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Status rekomendasi peserta merupakan rekapitulasi hasil asesmen yang telah dinilai pada FR-AK.02 (Rekaman Asesmen).',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1D4ED8),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Summary chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildCountChip('Kompeten', data.peserta.where((p) => p.rekomendasiAsesor == '1').length, const Color(0xFF16A34A)),
                    _buildCountChip('Belum Kompeten', data.peserta.where((p) => p.rekomendasiAsesor == '2').length, const Color(0xFFDC2626)),
                    _buildCountChip('Belum Rekomendasi', data.peserta.where((p) => p.rekomendasiAsesor != '1' && p.rekomendasiAsesor != '2').length, const Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 14),

                // Peserta Items
                ...data.peserta.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  return _buildPesertaCard(index + 1, p);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Rekomendasi & Tindak Lanjut Kolektif ───────────────────────────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan & Rekomendasi Kolektif',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                _buildInputField(
                  label: 'Pencapaian Unjuk Kerja',
                  controller: _pencapaianController,
                  hintText: 'Pencapaian unjuk kerja peserta...',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Unit yang Belum Kompeten (Jika ada)',
                  controller: _unitBkController,
                  hintText: 'Tuliskan kode/judul unit yang belum kompeten...',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Saran Tindak Lanjut',
                  controller: _saranController,
                  hintText: 'Saran tindak lanjut bagi peserta...',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Pelihara Kompetensi',
                  controller: _peliharaController,
                  hintText: 'Saran pemeliharaan kompetensi...',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Catatan Laporan',
                  controller: _catatanController,
                  hintText: 'Catatan tambahan asesmen...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Action Button ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (_isSaving || !data.isUnlocked) ? null : _saveAK05,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(!data.isUnlocked ? Icons.lock_outline : LucideIcons.save, size: 18),
              label: Text(
                _isSaving
                    ? 'Menyimpan Laporan...'
                    : !data.isUnlocked
                        ? 'Formulir Terkunci (Selesaikan AK.01)'
                        : 'Simpan Laporan Asesmen (AK.05)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: !data.isUnlocked ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPesertaCard(int no, JadwalAK05PesertaItem p) {
    final isK = p.rekomendasiAsesor == '1';
    final isBK = p.rekomendasiAsesor == '2';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isK
              ? const Color(0xFFBBF7D0)
              : isBK
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$no',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.namaLengkap,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'No: ${p.noPeserta.isNotEmpty ? p.noPeserta : '-'} • NIK: ${p.nik}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Read-only Assessment Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isK
                      ? const Color(0xFFDCFCE7)
                      : isBK
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isK
                        ? const Color(0xFF86EFAC)
                        : isBK
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isK
                          ? Icons.check_circle_rounded
                          : isBK
                              ? Icons.cancel_rounded
                              : Icons.schedule_rounded,
                      size: 14,
                      color: isK
                          ? const Color(0xFF16A34A)
                          : isBK
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isK
                          ? 'Kompeten (K)'
                          : isBK
                              ? 'Belum Kompeten (BK)'
                              : 'Belum Dinilai',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isK
                            ? const Color(0xFF16A34A)
                            : isBK
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isBK) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: p.unitBk,
              decoration: InputDecoration(
                labelText: 'Unit yang Belum Kompeten',
                hintText: 'Contoh: J.620100.004.01',
                labelStyle: const TextStyle(fontSize: 11),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
              style: const TextStyle(fontSize: 12),
              onChanged: (val) {
                p.unitBk = val.trim();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
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
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

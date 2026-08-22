import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/asesor_asesi_models.dart';
import '../../services/api_service.dart';
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

  late TextEditingController _pencapaianController;
  late TextEditingController _unitBkController;
  late TextEditingController _saranController;
  late TextEditingController _peliharaController;
  late TextEditingController _catatanController;

  @override
  void initState() {
    super.initState();
    _pencapaianController = TextEditingController();
    _unitBkController = TextEditingController();
    _saranController = TextEditingController();
    _peliharaController = TextEditingController();
    _catatanController = TextEditingController();
    _fetchDetail();
  }

  @override
  void dispose() {
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
      final res = await ApiService.getJadwalAK05(widget.jadwalId);
      if (res != null && res['data'] != null) {
        final data = JadwalAK05DetailData.fromJson(res['data'] as Map<String, dynamic>);
        setState(() {
          _detailData = data;
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
        'pencapaian': _pencapaianController.text.trim(),
        'unit_bk': _unitBkController.text.trim(),
        'saran_tindak_lanjut': _saranController.text.trim(),
        'pelihara_kompetensi': _peliharaController.text.trim(),
        'catatan': _catatanController.text.trim(),
        'peserta_rekomendasi': pesertaList,
      };

      final res = await ApiService.saveJadwalAK05(widget.jadwalId, payload);
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
          // ── Card 1: Informasi Asesmen & Link ──────────────────────────────────
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
                const SizedBox(height: 8),

                // Link Folder Rekaman (disatukan)
                if (data.linkFolderRekaman.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _launchURL(data.linkFolderRekaman),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.folder, size: 18, color: Color(0xFF2563EB)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Buka Folder Rekaman Asesmen',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          Icon(LucideIcons.external_link, size: 16, color: Color(0xFF2563EB)),
                        ],
                      ),
                    ),
                  ),
                ],
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
                const SizedBox(height: 12),

                // Summary chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildCountChip('Kompeten', data.peserta.where((p) => p.rekomendasiAsesor == '1').length, const Color(0xFF16A34A)),
                    _buildCountChip('Belum Kompeten', data.peserta.where((p) => p.rekomendasiAsesor == '2').length, const Color(0xFFDC2626)),
                    _buildCountChip('Belum Dinilai', data.peserta.where((p) => p.rekomendasiAsesor != '1' && p.rekomendasiAsesor != '2').length, const Color(0xFF94A3B8)),
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
              onPressed: _isSaving ? null : _saveAK05,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(LucideIcons.save, size: 18),
              label: Text(
                _isSaving ? 'Menyimpan Laporan...' : 'Simpan Laporan Asesmen (AK.05)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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
              // Dropdown Penilaian Ringkas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isK
                        ? const Color(0xFF16A34A)
                        : isBK
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFCBD5E1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: (p.rekomendasiAsesor == '1' || p.rekomendasiAsesor == '2')
                        ? p.rekomendasiAsesor
                        : '0',
                    isDense: true,
                    items: const [
                      DropdownMenuItem(
                        value: '0',
                        child: Text(
                          'Belum Dinilai',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '1',
                        child: Text(
                          'Kompeten (K)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '2',
                        child: Text(
                          'Belum Kompeten (BK)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          p.rekomendasiAsesor = val;
                          if (val == '1') {
                            p.rekomendasiLabel = 'Kompeten';
                          } else if (val == '2') {
                            p.rekomendasiLabel = 'Belum Kompeten';
                          } else {
                            p.rekomendasiLabel = 'Belum Dinilai';
                          }
                        });
                      }
                    },
                  ),
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

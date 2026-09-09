import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/jadwal/jadwal_ak05_info_sections.dart';
import '../../widgets/jadwal/jadwal_ak05_peserta_sections.dart';

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
          _linkRekamanController.text = data.linkRekamanAsesor;
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

  Future<void> _pasteLinkRekaman() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _linkRekamanController.text = data.text!.trim();
      });
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Lock Banner (if AK.01 not yet completed) ─────────────────────────
          if (!data.isUnlocked) ...[
            buildAk05LockBanner(data: data),
          ],

          // ── Card 1: Informasi Asesmen & Link Folder ──────────────────────────
          buildAk05InfoCard(
            context: context,
            data: data,
            jadwalTitle: widget.jadwalTitle,
            linkController: _linkRekamanController,
            onPasteLink: _pasteLinkRekaman,
            onLaunchUrl: _launchURL,
          ),
          const SizedBox(height: 16),

          // ── Card 1.5: Asesor Bertugas & Link Dokumentasi / Rekaman Uji ─────────
          buildAk05AsesorCard(
            context: context,
            data: data,
            linkRekamanText: _linkRekamanController.text,
            onLaunchUrl: _launchURL,
          ),
          const SizedBox(height: 16),

          // ── Sistem Penilaian Asesi (Daftar & Dropdown) ────────────────────────
          buildAk05PenilaianSection(data: data),
          const SizedBox(height: 16),

          // ── Rekomendasi & Tindak Lanjut Kolektif ───────────────────────────────
          buildAk05RekomendasiSection(
            pencapaianController: _pencapaianController,
            unitBkController: _unitBkController,
            saranController: _saranController,
            peliharaController: _peliharaController,
            catatanController: _catatanController,
          ),
          const SizedBox(height: 24),

          // ── Action Button ───────────────────────────────────────────────────
          buildAk05SaveButton(
            isSaving: _isSaving,
            isUnlocked: data.isUnlocked,
            onSave: _saveAK05,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

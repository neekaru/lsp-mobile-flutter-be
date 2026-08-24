import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/asesi/asesi_form_common.dart';

class JadwalAK06Screen extends StatefulWidget {
  final int jadwalId;
  final String jadwalTitle;

  const JadwalAK06Screen({
    super.key,
    required this.jadwalId,
    required this.jadwalTitle,
  });

  @override
  State<JadwalAK06Screen> createState() => _JadwalAK06ScreenState();
}

class _JadwalAK06ScreenState extends State<JadwalAK06Screen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  JadwalAK06DetailData? _detailData;

  bool _isPenjelasanExpanded = false;

  late TextEditingController _rekomendasiController;
  late TextEditingController _catatanController;

  // Instrument values for Prinsip Asesmen (Default: L (IA.01, IA.02))
  final Map<String, String> _prinsipInstrumen = {
    'Validitas': 'L (IA.01, IA.02)',
    'Reliabilitas': 'L (IA.01, IA.02)',
    'Fleksibilitas': 'L (IA.01, IA.02)',
    'Keadilan': 'L (IA.01, IA.02)',
  };

  // Instrument values for Dimensi Kompetensi (Default: L (IA.01, IA.02))
  final Map<String, String> _dimensiInstrumen = {
    'Task Skills': 'L (IA.01, IA.02)',
    'Task Management Skills': 'L (IA.01, IA.02)',
    'Contingency Management Skills': 'L (IA.01, IA.02)',
    'Job Role / Environment Skills': 'L (IA.01, IA.02)',
    'Transfer Skills': 'L (IA.01, IA.02)',
  };

  @override
  void initState() {
    super.initState();
    _rekomendasiController = TextEditingController();
    _catatanController = TextEditingController();
    _fetchDetail();
  }

  @override
  void dispose() {
    _rekomendasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await ApiService.getJadwalAK06(widget.jadwalId);
      if (res != null && res['data'] != null) {
        final data = JadwalAK06DetailData.fromJson(res['data'] as Map<String, dynamic>);
        setState(() {
          _detailData = data;
          _rekomendasiController.text = data.rekomendasi;
          _catatanController.text = data.catatan;

          for (final item in data.prinsipAsesmen) {
            _prinsipInstrumen[item.aspect] =
                item.catatan.isNotEmpty ? item.catatan : 'L (IA.01, IA.02)';
          }

          for (final item in data.dimensiKompetensi) {
            _dimensiInstrumen[item.aspect] =
                item.catatan.isNotEmpty ? item.catatan : 'L (IA.01, IA.02)';
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data FR-AK.06';
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

  Future<void> _saveAK06() async {
    if (_detailData == null) return;
    setState(() {
      _isSaving = true;
    });

    try {
      final prinsipList = _prinsipInstrumen.entries.map((e) {
        return {
          'aspect': e.key,
          'kesesuaian': 'Ya',
          'catatan': e.value,
        };
      }).toList();

      final dimensiList = _dimensiInstrumen.entries.map((e) {
        return {
          'aspect': e.key,
          'kesesuaian': 'Ya',
          'catatan': e.value,
        };
      }).toList();

      final payload = {
        'penjelasan_asesmen': _detailData!.penjelasanAsesmen,
        'prinsip_asesmen': prinsipList,
        'dimensi_kompetensi': dimensiList,
        'rekomendasi': _rekomendasiController.text.trim(),
        'catatan': _catatanController.text.trim(),
      };

      final res = await ApiService.saveJadwalAK06(widget.jadwalId, payload);
      if (res != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tinjauan Proses Asesmen FR-AK.06 berhasil disimpan!'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchDetail();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan tinjauan asesmen.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tinjauan Proses Asesmen FR-AK.06 berhasil disimpan!'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchDetail();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan tinjauan asesmen.'),
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

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(title: 'FR-AK.06 Meninjau Asesmen'),
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
          // Header Summary Card
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormSectionHeader(
                  title: 'Informasi Pelaksanaan',
                  status: 'Tinjauan Proses',
                  statusColor: Color(0xFF2563EB),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                AsesiDetailRow('Skema Sertifikasi', data.skema.isNotEmpty ? data.skema : '-'),
                AsesiDetailRow('Nama Jadwal', data.namaJadwal.isNotEmpty ? data.namaJadwal : widget.jadwalTitle),
                AsesiDetailRow('TUK', data.tuk.isNotEmpty ? data.tuk : '-'),
                AsesiDetailRow('Tanggal Pelaksanaan', data.tanggal),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Card 1: Penjelasan Proses Asesmen (Dropdown / Accordion) ──────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPenjelasanExpanded = !_isPenjelasanExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '1. Penjelasan Proses Asesmen',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Icon(
                        _isPenjelasanExpanded
                            ? LucideIcons.chevron_up
                            : LucideIcons.chevron_down,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
                if (_isPenjelasanExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      data.penjelasanAsesmen.isNotEmpty
                          ? data.penjelasanAsesmen
                          : 'Penjelasan proses asesmen dan konsultasi pra-asesmen telah dilaksanakan kepada seluruh asesi sebelum uji kompetensi berlangsung.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Card 2: Aspek yang Dikaji Ulang & Prinsip Asesmen ─────────────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2. Aspek yang Dikaji Ulang & Prinsip Asesmen',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                ..._prinsipInstrumen.keys.map((aspect) {
                  return _buildAspectRow(
                    aspect: aspect,
                    selectedInstrument: _prinsipInstrumen[aspect] ?? 'L (IA.01, IA.02)',
                    onChanged: (val) {
                      setState(() {
                        _prinsipInstrumen[aspect] = val;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Card 3: Pemenuhan Dimensi Kompetensi ─────────────────────────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '3. Pemenuhan Dimensi Kompetensi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                ..._dimensiInstrumen.keys.map((aspect) {
                  return _buildAspectRow(
                    aspect: aspect,
                    selectedInstrument: _dimensiInstrumen[aspect] ?? 'L (IA.01, IA.02)',
                    onChanged: (val) {
                      setState(() {
                        _dimensiInstrumen[aspect] = val;
                      });
                    },
                  );
                }),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),

                _buildInputField(
                  label: 'Rekomendasi Peningkatan Proses Asesmen',
                  controller: _rekomendasiController,
                  hintText: 'Tuliskan rekomendasi peningkatan jika ada...',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Catatan Tinjauan Asesmen',
                  controller: _catatanController,
                  hintText: 'Catatan umum pelaksanaan asesmen...',
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
              onPressed: _isSaving ? null : _saveAK06,
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
                _isSaving ? 'Menyimpan Tinjauan...' : 'Simpan Tinjauan Asesmen (AK.06)',
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

  Widget _buildAspectRow({
    required String aspect,
    required String selectedInstrument,
    required ValueChanged<String> onChanged,
  }) {
    final instruments = [
      'L (IA.01, IA.02)',
      'T (IA.05, IA.06)',
      'TL (IA.08, IA.09)',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aspect,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: instruments.map((inst) {
                final isSelected = selectedInstrument == inst ||
                    (selectedInstrument.isEmpty && inst == 'L (IA.01, IA.02)');

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => onChanged(inst),
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFCBD5E1),
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? LucideIcons.check_circle_2
                                : LucideIcons.circle,
                            size: 13,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            inst,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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

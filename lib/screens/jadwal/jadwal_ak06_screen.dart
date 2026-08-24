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

  late TextEditingController _taskSkillController;
  late TextEditingController _taskManagementController;
  late TextEditingController _contingencyController;
  late TextEditingController _jobRoleController;
  late TextEditingController _transferSkillController;

  List<AK06PrinsipItem> _prinsipItems = [];

  @override
  void initState() {
    super.initState();
    _rekomendasiController = TextEditingController();
    _catatanController = TextEditingController();
    _taskSkillController = TextEditingController(text: 'L (IA.01, IA.02)');
    _taskManagementController = TextEditingController(text: 'L (IA.01, IA.02)');
    _contingencyController = TextEditingController(text: 'L (IA.01, IA.02)');
    _jobRoleController = TextEditingController(text: 'L (IA.01, IA.02)');
    _transferSkillController = TextEditingController(text: 'L (IA.01, IA.02)');
    _fetchDetail();
  }

  @override
  void dispose() {
    _rekomendasiController.dispose();
    _catatanController.dispose();
    _taskSkillController.dispose();
    _taskManagementController.dispose();
    _contingencyController.dispose();
    _jobRoleController.dispose();
    _transferSkillController.dispose();
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
          _prinsipItems = data.prinsipAsesmen;
          _taskSkillController.text = data.dimensiKompetensi.taskSkill.isNotEmpty
              ? data.dimensiKompetensi.taskSkill
              : 'L (IA.01, IA.02)';
          _taskManagementController.text = data.dimensiKompetensi.taskManagementSkill.isNotEmpty
              ? data.dimensiKompetensi.taskManagementSkill
              : 'L (IA.01, IA.02)';
          _contingencyController.text = data.dimensiKompetensi.contingencyManagementSkill.isNotEmpty
              ? data.dimensiKompetensi.contingencyManagementSkill
              : 'L (IA.01, IA.02)';
          _jobRoleController.text = data.dimensiKompetensi.jobRoleEnvironmentSkill.isNotEmpty
              ? data.dimensiKompetensi.jobRoleEnvironmentSkill
              : 'L (IA.01, IA.02)';
          _transferSkillController.text = data.dimensiKompetensi.transferSkill.isNotEmpty
              ? data.dimensiKompetensi.transferSkill
              : 'L (IA.01, IA.02)';
          _rekomendasiController.text = data.rekomendasi;
          _catatanController.text = data.catatan;
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
      final dimensi = AK06DimensiItem(
        taskSkill: _taskSkillController.text.trim(),
        taskManagementSkill: _taskManagementController.text.trim(),
        contingencyManagementSkill: _contingencyController.text.trim(),
        jobRoleEnvironmentSkill: _jobRoleController.text.trim(),
        transferSkill: _transferSkillController.text.trim(),
      );

      final payload = {
        'penjelasan_asesmen': _detailData!.penjelasanAsesmen,
        'prinsip_asesmen': _prinsipItems.map((e) => e.toJson()).toList(),
        'dimensi_kompetensi': dimensi.toJson(),
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
                const SizedBox(height: 4),
                const Text(
                  'Centang prinsip asesmen yang terpenuhi pada setiap prosedur:',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                ..._prinsipItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isFlexibleBlocked = item.prosedur.toLowerCase().contains('keputusan') ||
                      item.prosedur.toLowerCase().contains('umpan balik');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${item.prosedur}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildCheckboxChip(
                              label: 'Valid',
                              value: item.valid,
                              onChanged: (val) {
                                setState(() {
                                  item.valid = val;
                                });
                              },
                            ),
                            _buildCheckboxChip(
                              label: 'Reliable',
                              value: item.reliable,
                              onChanged: (val) {
                                setState(() {
                                  item.reliable = val;
                                });
                              },
                            ),
                            _buildCheckboxChip(
                              label: 'Flexible',
                              value: item.flexible,
                              isBlocked: isFlexibleBlocked,
                              onChanged: (val) {
                                if (!isFlexibleBlocked) {
                                  setState(() {
                                    item.flexible = val;
                                  });
                                }
                              },
                            ),
                            _buildCheckboxChip(
                              label: 'Fair',
                              value: item.fair,
                              onChanged: (val) {
                                setState(() {
                                  item.fair = val;
                                });
                              },
                            ),
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

          // ── Card 3: Pemenuhan terhadap Dimensi Kompetensi ─────────────────────
          FormSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '3. Pemenuhan terhadap Dimensi Kompetensi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Konsistensi keputusan asesmen / bukti unjuk kerja:',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                _buildDimensiField('Task Skills', _taskSkillController),
                _buildDimensiField('Task Management Skills', _taskManagementController),
                _buildDimensiField('Contingency Management Skills', _contingencyController),
                _buildDimensiField('Job Role / Environment Skills', _jobRoleController),
                _buildDimensiField('Transfer Skills', _transferSkillController),

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

  Widget _buildDimensiField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'L (IA.01, IA.02)',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildQuickChip(controller, 'L (IA.01, IA.02)'),
              _buildQuickChip(controller, 'T (IA.05, IA.06)'),
              _buildQuickChip(controller, 'TL (IA.08, IA.09)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(TextEditingController controller, String text) {
    final isCurrent = controller.text == text;
    return InkWell(
      onTap: () {
        setState(() {
          controller.text = text;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxChip({
    required String label,
    required bool value,
    bool isBlocked = false,
    required ValueChanged<bool> onChanged,
  }) {
    if (isBlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$label (N/A)',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            decoration: TextDecoration.lineThrough,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
            width: value ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? LucideIcons.check_square : LucideIcons.square,
              size: 15,
              color: value ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: value ? FontWeight.bold : FontWeight.w500,
                color: value ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
              ),
            ),
          ],
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

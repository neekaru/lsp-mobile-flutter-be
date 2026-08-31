// ============================================================================
// FR-AK.02 Rekaman Asesmen + form rekomendasi asesor.
// Diekstrak dari asesi_ak_sections.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import '../../screens/instrumen/instrumen_asesmen_screen.dart';
import '../../services/asesor/asesor_service.dart';
import 'asesi_form_common.dart';

class AK02Section extends StatefulWidget {
  final AsesorAsesiDetailData? detailData;
  final VoidCallback? onSaveSuccess;

  const AK02Section({
    super.key,
    required this.detailData,
    this.onSaveSuccess,
  });

  @override
  State<AK02Section> createState() => _AK02SectionState();
}

class _AK02SectionState extends State<AK02Section> {
  String _selectedRekom = ''; // '': Belum dipilih (non-active), '1': Kompeten, '2': Belum Kompeten
  late TextEditingController _pesanController;
  final Set<String> _selectedUnitBK = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _syncFromDetailData();
    _pesanController = TextEditingController(text: _initialPesan());
  }

  @override
  void didUpdateWidget(covariant AK02Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detailData != widget.detailData) {
      _syncFromDetailData();
      final initialPesan = _initialPesan();
      if (_pesanController.text != initialPesan) {
        _pesanController.text = initialPesan;
      }
    }
  }

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  String _initialPesan() {
    final d = widget.detailData;
    if (d == null) return 'Pelihara dan Kembangkan Kompetensimu';
    if (d.ak02.pesan.isNotEmpty) {
      return d.ak02.pesan;
    }
    if (d.pesanAsesor.isNotEmpty) {
      return d.pesanAsesor;
    }
    if (d.ak02.saranTindakLanjut.isNotEmpty) {
      return d.ak02.saranTindakLanjut;
    }
    return d.ak02.komentarObservasi.isNotEmpty ? d.ak02.komentarObservasi : 'Pelihara dan Kembangkan Kompetensimu';
  }

  void _syncFromDetailData() {
    final d = widget.detailData;
    if (d == null) return;
    final currentCode = d.ak02.rekomendasiAsesor.trim();
    final generalRekom = d.rekomendasiAsesor.trim().toLowerCase();
    if (currentCode == '2' || generalRekom == 'belum kompeten' || generalRekom == 'bk') {
      _selectedRekom = '2';
    } else if (currentCode == '1' || generalRekom == 'kompeten' || generalRekom == 'k') {
      _selectedRekom = '1';
    } else {
      _selectedRekom = ''; // Belum rekomendasi / netral
    }

    _selectedUnitBK.clear();
    if (d.ak02.unitBKList.isNotEmpty) {
      _selectedUnitBK.addAll(d.ak02.unitBKList);
    }
  }

  Future<void> _submitRekomendasi() async {
    final asesiId = widget.detailData?.id;
    if (asesiId == null || asesiId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Asesi tidak valid.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedRekom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih Keputusan Rekomendasi (Kompeten atau Belum Kompeten) terlebih dahulu.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final res = await AsesorService.updateAsesiRekomendasi(
        asesiId: asesiId,
        rekomendasiAsesor: _selectedRekom,
        pesan: _pesanController.text.trim(),
        catatan: _pesanController.text.trim(),
        komentarObservasi: _pesanController.text.trim(),
        saranTindakLanjut: _pesanController.text.trim(),
        peliharaKompetensi: _selectedRekom == '1' ? _pesanController.text.trim() : null,
        unitBkList: _selectedRekom == '2' ? _selectedUnitBK.toList() : [],
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (res != null && res['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Rekomendasi asesor berhasil disimpan'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          widget.onSaveSuccess?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res?['message'] ?? 'Gagal menyimpan rekomendasi asesor.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ak02 = widget.detailData?.ak02;
    final apl02 = widget.detailData?.apl02;
    final kandidat = apl02?.kandidat ?? '1';
    final selectedMapaId = apl02?.idMapa;
    
    MapaOption? selectedMapa;
    if (apl02?.mapaOptions.isNotEmpty == true) {
      if (selectedMapaId != null && selectedMapaId > 0) {
        selectedMapa = apl02!.mapaOptions.firstWhere(
          (m) => m.id == selectedMapaId,
          orElse: () => apl02.mapaOptions.first,
        );
      } else {
        selectedMapa = apl02!.mapaOptions.first;
      }
    }

    final isExp = kandidat == '3' || kandidat == '4';
    final isTerstruktur = !isExp && selectedMapa != null && (
        selectedMapa.isTerstruktur ||
        selectedMapa.namaMapa.toLowerCase().contains('terstruktur') ||
        selectedMapa.namaMapa.toLowerCase().contains('dit')
    );
    final isPorto = isExp || (selectedMapa != null && (
        selectedMapa.isPortofolio ||
        selectedMapa.namaMapa.toLowerCase().contains('portofolio') ||
        selectedMapa.namaMapa.toLowerCase().contains('porotofolio') ||
        selectedMapa.namaMapa.toLowerCase().contains('portfolio')
    )) || (widget.detailData?.skemaSertifikat.toLowerCase().contains('portofolio') ?? false);

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.02 Rekaman Asesmen',
            status: ak02?.status ?? 'Belum Dinilai',
            statusColor: ak02?.status == 'Selesai' ? const Color(0xFF059669) : const Color(0xFF64748B),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Ringkasan Hasil Asesmen (Sesuai Persis dengan Kondisi MAPA yang Dipilih di APL-02)
          if (isPorto) ...[
            AsesiDetailRow('Hasil Verifikasi Portofolio (FR.IA.08/11)', ak02?.hasilPortofolio ?? '-'),
            AsesiDetailRow('Hasil Pertanyaan Wawancara (FR.IA.09/03)', (ak02?.hasilWawancara != '-' && ak02?.hasilWawancara.isNotEmpty == true) ? ak02!.hasilWawancara : (ak02?.hasilLisan ?? '-')),
          ] else if (isTerstruktur) ...[
            AsesiDetailRow('Hasil Penilaian Proyek Singkat (FR.IA.04A)', ak02?.hasilProyekSingkat ?? '-'),
            AsesiDetailRow('Hasil Penilaian Proyek Terstruktur (FR.IA.04B)', ak02?.hasilProyek ?? '-'),
            AsesiDetailRow('Hasil Pertanyaan Tertulis (FR.IA.05)', (ak02?.hasilPG != '-' && ak02?.hasilPG.isNotEmpty == true) ? ak02!.hasilPG : (ak02?.hasilEsai ?? '-')),
          ] else ...[
            // Kondisi 1: Observasi Langsung (Peserta Pelatihan)
            AsesiDetailRow('Hasil Observasi Langsung (FR.IA.01)', ak02?.hasilObservasi ?? '-'),
            AsesiDetailRow('Hasil Uji Praktik / Demonstrasi (FR.IA.02)', ak02?.hasilPraktik ?? '-'),
            AsesiDetailRow('Hasil Pertanyaan Mendukung Observasi (FR.IA.03)', ak02?.hasilLisan ?? '-'),
            AsesiDetailRow('Hasil Pertanyaan Tertulis / Esai (FR.IA.05/06)', (ak02?.hasilPG != '-' && ak02?.hasilPG.isNotEmpty == true) ? ak02!.hasilPG : (ak02?.hasilEsai ?? '-')),
          ],

          const SizedBox(height: 12),

          // Tombol Buka Lembar Instrumen Asesmen
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isPorto) ...[
                _buildIAQuickButton(
                  context,
                  label: 'IA.03 Tanya Lisan (Wawancara)',
                  formId: 'IA03',
                  color: const Color(0xFFD97706),
                  icon: LucideIcons.message_circle,
                ),
                _buildIAQuickButton(
                  context,
                  label: 'IA.11 Verifikasi Portofolio',
                  formId: 'IA11',
                  color: const Color(0xFF7C3AED),
                  icon: LucideIcons.file_check,
                ),
              ] else if (isTerstruktur) ...[
                _buildIAQuickButton(
                  context,
                  label: 'IA.04A Proyek Singkat (DIT)',
                  formId: 'IA04A',
                  color: const Color(0xFF0D9488),
                  icon: LucideIcons.file_text,
                ),
                _buildIAQuickButton(
                  context,
                  label: 'IA.04B Penilaian Proyek',
                  formId: 'IA04B',
                  color: const Color(0xFF2563EB),
                  icon: LucideIcons.briefcase,
                ),
                _buildIAQuickButton(
                  context,
                  label: 'IA.05 Tanya Tertulis',
                  formId: 'IA05',
                  color: const Color(0xFFEA580C),
                  icon: LucideIcons.pen_tool,
                ),
              ] else ...[
                _buildIAQuickButton(
                  context,
                  label: 'IA.01 Ceklis Observasi',
                  formId: 'IA01',
                  color: const Color(0xFF2563EB),
                  icon: LucideIcons.clipboard_list,
                ),
                _buildIAQuickButton(
                  context,
                  label: 'IA.02 Tugas Praktik',
                  formId: 'IA02',
                  color: const Color(0xFF0284C7),
                  icon: LucideIcons.hammer,
                ),
                _buildIAQuickButton(
                  context,
                  label: 'IA.03 Pertanyaan Mendukung Observasi',
                  formId: 'IA03',
                  color: const Color(0xFFD97706),
                  icon: LucideIcons.message_circle,
                ),
                _buildIAQuickButton(
                  context,
                  label: 'IA.05 Tanya Tertulis',
                  formId: 'IA05',
                  color: const Color(0xFFEA580C),
                  icon: LucideIcons.pen_tool,
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // ── FORM REKOMENDASI ASESOR ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.rate_review_outlined, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Rekomendasi Asesor',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Keputusan Rekomendasi :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),

          // Pilihan Rekomendasi (Kompeten / Belum Kompeten)
          Row(
            children: [
              Expanded(
                child: _buildRekomOption(
                  value: '1',
                  label: 'Kompeten',
                  selectedBg: const Color(0xFFDCFCE7),
                  selectedBorder: const Color(0xFF16A34A),
                  selectedIcon: Icons.check_circle_rounded,
                  selectedIconColor: const Color(0xFF16A34A),
                  selectedTextColor: const Color(0xFF166534),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRekomOption(
                  value: '2',
                  label: 'Belum Kompeten',
                  selectedBg: const Color(0xFFFEE2E2),
                  selectedBorder: const Color(0xFFDC2626),
                  selectedIcon: Icons.cancel_rounded,
                  selectedIconColor: const Color(0xFFDC2626),
                  selectedTextColor: const Color(0xFF991B1B),
                ),
              ),
            ],
          ),

          // Pilihan Unit BK jika Belum Kompeten
          if (_selectedRekom == '2') ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Unit Kompetensi Belum Kompeten (BK):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
                Text(
                  '${_selectedUnitBK.length} dipilih',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.detailData?.apl02.units.isNotEmpty == true)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.detailData!.apl02.units.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFFEE2E2)),
                  itemBuilder: (context, index) {
                    final unit = widget.detailData!.apl02.units[index];
                    final isChecked = _selectedUnitBK.contains(unit.idUnit) || _selectedUnitBK.contains(unit.kodeUnit);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _selectedUnitBK.remove(unit.idUnit);
                            _selectedUnitBK.remove(unit.kodeUnit);
                          } else {
                            _selectedUnitBK.add(unit.idUnit.isNotEmpty ? unit.idUnit : unit.kodeUnit);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: const Color(0xFFDC2626),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedUnitBK.add(unit.idUnit.isNotEmpty ? unit.idUnit : unit.kodeUnit);
                                  } else {
                                    _selectedUnitBK.remove(unit.idUnit);
                                    _selectedUnitBK.remove(unit.kodeUnit);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unit.kodeUnit,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    unit.judulUnit,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Tidak ada daftar unit kompetensi yang tersedia.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ),
          ],

          const SizedBox(height: 14),

          // Textbox Pesan / Catatan Asesor
          const Text(
            'Pesan / Catatan Rekomendasi :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _pesanController,
            maxLines: 3,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Tuliskan catatan/pesan atau saran tindak lanjut untuk asesi...',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
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

          const SizedBox(height: 16),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRekomendasi,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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
                  : const Icon(Icons.save_outlined, size: 17),
              label: Text(
                _isSubmitting ? 'Menyimpan...' : 'Simpan Rekomendasi Asesor',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekomOption({
    required String value,
    required String label,
    required Color selectedBg,
    required Color selectedBorder,
    required IconData selectedIcon,
    required Color selectedIconColor,
    required Color selectedTextColor,
  }) {
    final bool isSelected = _selectedRekom == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRekom = value;
          if (value == '1') {
            _pesanController.text = 'Pelihara dan Kembangkan Kompetensimu';
            _selectedUnitBK.clear();
          } else if (value == '2') {
            if (_pesanController.text.isEmpty || _pesanController.text == 'Pelihara dan Kembangkan Kompetensimu') {
              _pesanController.text = 'Perlu peningkatan kompetensi pada unit terkait';
            }
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedBorder : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : Icons.radio_button_unchecked_rounded,
              color: isSelected ? selectedIconColor : const Color(0xFF94A3B8),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? selectedTextColor : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIAQuickButton(
    BuildContext context, {
    required String label,
    required String formId,
    required Color color,
    required IconData icon,
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
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
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
            Icon(LucideIcons.arrow_up_right, size: 12, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

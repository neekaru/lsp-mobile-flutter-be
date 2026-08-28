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
    if (d == null) return '';
    if (d.ak02.pesan.isNotEmpty) {
      return d.ak02.pesan;
    }
    if (d.pesanAsesor.isNotEmpty) {
      return d.pesanAsesor;
    }
    return d.ak02.komentarObservasi;
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
    final isPorto = (widget.detailData?.apl02.kandidat == '3') ||
        (widget.detailData?.skemaSertifikat.toLowerCase().contains('portofolio') ?? false);

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.02 Rekaman Asesmen',
            status: ak02?.status ?? 'Selesai',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Ringkasan Hasil Asesmen (Sesuai Instrumen yang digunakan)
          if (isPorto) ...[
            AsesiDetailRow('Hasil Verifikasi Portofolio (FR.IA.11)', ak02?.hasilPortofolio ?? 'Kompeten'),
            AsesiDetailRow('Hasil Pertanyaan Wawancara / Lisan (FR.IA.03/09)', ak02?.hasilLisan ?? 'Kompeten'),
          ] else ...[
            AsesiDetailRow('Hasil Observasi Langsung (FR.IA.01)', ak02?.hasilObservasi ?? 'Kompeten'),
            AsesiDetailRow('Hasil Uji Praktik / Demonstrasi (FR.IA.02)', ak02?.hasilPraktik ?? 'Kompeten'),
            AsesiDetailRow('Hasil Pertanyaan Lisan (FR.IA.03)', ak02?.hasilLisan ?? 'Kompeten'),
            AsesiDetailRow('Hasil Pertanyaan Tertulis / Esai (FR.IA.05/06)', ak02?.hasilEsai ?? 'Kompeten'),
          ],

          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InstrumenAsesmenScreen(
                      asesiId: widget.detailData?.id ?? 0,
                      namaAsesi: widget.detailData?.namaLengkap ?? 'Peserta Asesmen',
                      skema: widget.detailData?.skemaSertifikat ?? 'Skema Sertifikasi',
                      tuk: widget.detailData?.tukNama ?? 'TUK',
                      jadwal: widget.detailData?.jadwalNama ?? 'Jadwal Asesmen',
                      initialForm: 'IA01',
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF93C5FD)),
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(LucideIcons.clipboard_list, size: 15),
              label: const Text(
                'Lihat / Isi Ceklis Observasi (FR.IA.01)',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
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
}

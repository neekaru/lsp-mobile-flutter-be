// ============================================================================
// Section form AK-01 .. AK-05 (asesi).
//
// Diekstrak dari asesi_form_sections.dart agar tiap bagian form asesi
// menjadi modul tersendiri.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/asesor_asesi_models.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

// ── 3. AK-01 ──────────────────────────────────────────────────────────────
class AK01Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK01Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak01 = detailData?.ak01;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.01 Persetujuan & Kerahasiaan',
            status: ak01?.status ?? 'Disetujui',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Pernyataan Asesi', ak01?.persetujuan ?? 'Asesi Menyetujui Pelaksanaan Asesmen Sesuai Prosedur LSP'),
          AsesiDetailRow('TUK Pelaksanaan', ak01?.tuk ?? detailData?.tukNama ?? '-'),
          AsesiDetailRow(
            'Tanggal Asesmen',
            ak01?.tglAsesmen.isNotEmpty == true
                ? DateFormatHelper.formatToIndonesian(ak01!.tglAsesmen)
                : (detailData?.jadwalTanggal.isNotEmpty == true
                    ? DateFormatHelper.formatToIndonesian(detailData!.jadwalTanggal)
                    : '-'),
          ),
          AsesiDetailRow('Status Tanda Tangan', ak01?.tandaTangan == true ? 'Sudah Ditandatangani' : 'Belum Ditandatangani'),
        ],
      ),
    );
  }
}

// ── 4. AK-02 ──────────────────────────────────────────────────────────────
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
  String _selectedRekom = '1'; // '1': Kompeten, '2': Belum Kompeten
  late TextEditingController _pesanController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final currentCode = widget.detailData?.ak02.rekomendasiAsesor;
    if (currentCode == '2' || widget.detailData?.rekomendasiAsesor == 'Belum Kompeten') {
      _selectedRekom = '2';
    } else {
      _selectedRekom = '1';
    }

    final initialPesan = widget.detailData?.ak02.pesan.isNotEmpty == true
        ? widget.detailData!.ak02.pesan
        : (widget.detailData?.pesanAsesor.isNotEmpty == true
            ? widget.detailData!.pesanAsesor
            : (widget.detailData?.ak02.komentarObservasi ?? ''));

    _pesanController = TextEditingController(text: initialPesan);
  }

  @override
  void didUpdateWidget(covariant AK02Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detailData != widget.detailData) {
      final currentCode = widget.detailData?.ak02.rekomendasiAsesor;
      if (currentCode == '2' || widget.detailData?.rekomendasiAsesor == 'Belum Kompeten') {
        _selectedRekom = '2';
      } else {
        _selectedRekom = '1';
      }

      final initialPesan = widget.detailData?.ak02.pesan.isNotEmpty == true
          ? widget.detailData!.ak02.pesan
          : (widget.detailData?.pesanAsesor.isNotEmpty == true
              ? widget.detailData!.pesanAsesor
              : (widget.detailData?.ak02.komentarObservasi ?? ''));

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

          // Ringkasan Hasil Asesmen
          AsesiDetailRow('Hasil Observasi Langsung', ak02?.hasilObservasi ?? 'Kompeten'),
          AsesiDetailRow('Hasil Uji Praktik / Demonstrasi', ak02?.hasilPraktik ?? 'Kompeten'),
          AsesiDetailRow('Hasil Pertanyaan Lisan', ak02?.hasilLisan ?? 'Kompeten'),
          AsesiDetailRow('Hasil Tes Tertulis / Esai', ak02?.hasilEsai ?? 'Kompeten'),

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
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRekom = '1';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _selectedRekom == '1'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedRekom == '1'
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFCBD5E1),
                        width: _selectedRekom == '1' ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedRekom == '1'
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: _selectedRekom == '1'
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kompeten',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _selectedRekom == '1'
                                ? const Color(0xFF166534)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRekom = '2';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _selectedRekom == '2'
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedRekom == '2'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFCBD5E1),
                        width: _selectedRekom == '2' ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedRekom == '2'
                              ? Icons.cancel_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: _selectedRekom == '2'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF94A3B8),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Belum Kompeten',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _selectedRekom == '2'
                                ? const Color(0xFF991B1B)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
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
}

// ── 5. AK-03 ──────────────────────────────────────────────────────────────
class AK03Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK03Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak03 = detailData?.ak03;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.03 Umpan Balik Asesi',
            status: ak03?.status ?? 'Telah Diisi',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Umpan Balik Asesi', ak03?.umpanBalik ?? 'Proses asesmen berjalan sangat baik, objektif dan kondusif.'),
          if (ak03?.catatan.isNotEmpty == true)
            AsesiDetailRow('Catatan Tambahan', ak03!.catatan),
        ],
      ),
    );
  }
}

// ── 6. AK-04 ──────────────────────────────────────────────────────────────
class AK04Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK04Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak04 = detailData?.ak04;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.04 Banding Asesmen',
            status: ak04?.status ?? 'Tidak Ada Banding',
            statusColor: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Permohonan Banding', ak04?.adaBanding == true ? 'Ada Pengajuan Banding' : 'Tidak Ada Pengajuan Banding'),
          if (ak04?.alasanBanding.isNotEmpty == true && ak04!.alasanBanding != '-')
            AsesiDetailRow('Alasan Banding', ak04.alasanBanding),
        ],
      ),
    );
  }
}

// ── 7. AK-05 ──────────────────────────────────────────────────────────────
class AK05Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK05Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak05 = detailData?.ak05;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.05 Laporan Asesmen',
            status: ak05?.status ?? 'Selesai',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Rekomendasi Akhir Asesor', ak05?.rekomendasi ?? detailData?.rekomendasiAsesor ?? 'Belum Dinilai'),
          AsesiDetailRow(
            'Tanggal Rekomendasi',
            ak05?.tanggalRekomendasi.isNotEmpty == true
                ? DateFormatHelper.formatToIndonesianWithTime(ak05!.tanggalRekomendasi)
                : 'Belum diisi asesor',
          ),
          AsesiDetailRow('Pencapaian Unjuk Kerja', ak05?.pencapaian ?? 'Semua kriteria unjuk kerja telah terpenuhi'),
          AsesiDetailRow('Unit yang Belum Kompeten', ak05?.unitBk ?? '-'),
          AsesiDetailRow('Saran Tindak Lanjut', ak05?.saranTindakLanjut ?? 'Pertahankan kompetensi di bidang terkait'),
          AsesiDetailRow('Pemeliharaan Kompetensi', ak05?.peliharaKompetensi ?? 'Mengikuti pelatihan berkelanjutan dan sertifikasi ulang'),
        ],
      ),
    );
  }
}

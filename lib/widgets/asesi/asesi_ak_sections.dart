// ============================================================================
// Section form AK-01 .. AK-05 (asesi).
//
// Diekstrak dari asesi_form_sections.dart agar tiap bagian form asesi
// menjadi modul tersendiri.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

// ── 3. AK-01 ──────────────────────────────────────────────────────────────
class AK01Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK01Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak01 = detailData?.ak01;
    final String tglFormatted = ak01?.tglAsesmen.isNotEmpty == true
        ? DateFormatHelper.formatToIndonesian(ak01!.tglAsesmen)
        : (detailData?.jadwalTanggal.isNotEmpty == true
            ? DateFormatHelper.formatToIndonesian(detailData!.jadwalTanggal)
            : '26 Agustus 2026');

    final String judulSkema = ak01?.judulSkema.isNotEmpty == true
        ? ak01!.judulSkema
        : (detailData?.skemaSertifikat.isNotEmpty == true
            ? detailData!.skemaSertifikat
            : 'Pemrogram Web Pratama');

    final String nomorSkema = ak01?.nomorSkema.isNotEmpty == true
        ? ak01!.nomorSkema
        : (detailData?.idSkema.isNotEmpty == true
            ? 'SKK-${detailData!.idSkema}'
            : 'SKK-28-10/2024');

    final String tuk = ak01?.tuk.isNotEmpty == true
        ? ak01!.tuk
        : (detailData?.tukNama.isNotEmpty == true ? detailData!.tukNama : 'SMKN 5 MALANG');

    final String namaAsesor = ak01?.namaAsesor.isNotEmpty == true
        ? ak01!.namaAsesor
        : 'Asesor LSP';

    final String namaAsesi = ak01?.namaAsesi.isNotEmpty == true
        ? ak01!.namaAsesi
        : (detailData?.namaLengkap.isNotEmpty == true ? detailData!.namaLengkap : 'Peserta Asesmen');

    // Checklist bukti
    final defaultBukti = [
      {'nama': 'Hasil Verifikasi Portofolio', 'checked': false},
      {'nama': 'Hasil Reviu Produk', 'checked': false},
      {'nama': 'Hasil Observasi Langsung', 'checked': true},
      {'nama': 'Hasil Kegiatan Terstruktur', 'checked': false},
      {'nama': 'Hasil Pertanyaan Lisan', 'checked': false},
      {'nama': 'Hasil Pertanyaan Tertulis', 'checked': true},
      {'nama': 'Lainnya', 'checked': false},
      {'nama': 'Hasil Pertanyaan Wawancara', 'checked': false},
    ];

    final buktiItems = ak01?.buktiDikumpulkan.isNotEmpty == true
        ? ak01!.buktiDikumpulkan.map((b) => {'nama': b.nama, 'checked': b.checked}).toList()
        : defaultBukti;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.01 Persetujuan & Kerahasiaan',
            status: ak01?.status ?? 'Disetujui',
          ),
          const SizedBox(height: 10),

          // Subtitle deskripsi BNSP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Persetujuan Asesmen ini untuk menjamin bahwa Asesi telah diberi arahan secara rinci tentang perencanaan dan proses asesmen.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF475569),
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // 1. DETAIL SKEMA & PESERTA
          _buildInfoRow('Skema Sertifikasi', judulSkema),
          _buildInfoRow('Nomor Skema', nomorSkema),
          _buildInfoRow('TUK', tuk),
          _buildInfoRow('Nama Asesor', namaAsesor),
          _buildInfoRow('Nama Asesi', namaAsesi),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // 2. BUKTI YANG AKAN DIKUMPULKAN
          const Text(
            'Bukti yang akan dikumpulkan :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: buktiItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 8,
              childAspectRatio: 3.8,
            ),
            itemBuilder: (context, index) {
              final item = buktiItems[index];
              final bool isChecked = item['checked'] == true;
              final String name = item['nama'] as String;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: isChecked ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isChecked ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 16,
                      color: isChecked ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                          color: isChecked ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // 3. PELAKSANAAN ASESMEN
          const Text(
            'Pelaksanaan asesmen disepakati pada :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildScheduleRow('Hari / Tanggal', tglFormatted),
                const SizedBox(height: 4),
                _buildScheduleRow('Waktu', ak01?.waktu.isNotEmpty == true ? ak01!.waktu : '08:00 WIB'),
                const SizedBox(height: 4),
                _buildScheduleRow('TUK', tuk),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // 4. PERNYATAAN & PERSETUJUAN
          const Text(
            'Pernyataan & Persetujuan :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          // Pernyataan Asesi 1
          _buildPernyataanCard(
            pihak: 'Asesi : Setuju',
            color: const Color(0xFF16A34A),
            bgHeader: const Color(0xFFDCFCE7),
            isi: 'Bahwa Saya Sudah Mendapatkan Penjelasan Hak dan Prosedur Banding Oleh Asesor.',
          ),

          const SizedBox(height: 8),

          // Pernyataan Asesor
          _buildPernyataanCard(
            pihak: 'Asesor : Setuju',
            color: const Color(0xFF2563EB),
            bgHeader: const Color(0xFFEFF6FF),
            isi: 'Menyatakan tidak akan membuka hasil pekerjaan yang saya peroleh karena penugasan saya sebagai asesor dalam pekerjaan Asesmen kepada siapapun atau organisasi apapun selain kepada pihak yang berwenang sehubungan dengan kewajiban saya sebagai Asesor yang ditugaskan oleh LSP.\n\nMenyatakan setuju untuk melaksanakan asesmen jarak jauh sesuai dengan prosedur yang ditentukan.',
          ),

          const SizedBox(height: 8),

          // Pernyataan Asesi 2
          _buildPernyataanCard(
            pihak: 'Asesi : Setuju',
            color: const Color(0xFF16A34A),
            bgHeader: const Color(0xFFDCFCE7),
            isi: 'Saya setuju mengikuti asesmen tatap muka / asesmen jarak jauh dengan pemahaman bahwa informasi yang dikumpulkan hanya digunakan untuk pengembangan profesional dan hanya dapat diakses oleh orang tertentu saja.',
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // 5. TANDA TANGAN ELEKTRONIK
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Text(
                            'Tanda Tangan Peserta',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: $tglFormatted',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Text(
                            'Tanda Tangan Asesor',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: $tglFormatted',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          const Text(' :  ', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPernyataanCard({
    required String pihak,
    required Color color,
    required Color bgHeader,
    required String isi,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bgHeader,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Text(
              pihak,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              isi,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ),
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

  static const List<String> _defaultKomponenList = [
    'Saya mendapatkan penjelasan yang cukup memadai mengenai proses asesmen/uji kompetensi',
    'Asesor memberikan kesempatan untuk mendiskusikan/ menegosiasikan metoda, instrumen dan sumber asesmen serta jadwal asesmen',
    'Asesor berusaha menggali seluruh bukti pendukung yang sesuai dengan latar belakang pelatihan dan pengalaman yang saya miliki',
    'Saya mendapatkan jaminan kerahasiaan hasil asesmen serta penjelasan penanganan dokumen asesmen',
    'Saya sepenuhnya diberikan kesempatan untuk mendemonstrasikan kompetensi yang saya miliki selama asesmen',
    'Saya mendapatkan penjelasan yang memadai mengenai keputusan asesmen',
    'Asesor memberikan umpan balik yang mendukung setelah asesmen serta tindak lanjutnya',
    'Asesor menggunakan keterampilan komunikasi yang efektif selama asesmen',
    'Asesor bersama saya menandatangani semua dokumen hasil asesmen',
  ];

  @override
  Widget build(BuildContext context) {
    final ak03 = detailData?.ak03;

    final String namaAsesi = ak03?.namaAsesi.isNotEmpty == true
        ? ak03!.namaAsesi
        : (detailData?.namaLengkap.isNotEmpty == true ? detailData!.namaLengkap : '-');

    final String tglMulai = ak03?.tanggalMulai.isNotEmpty == true
        ? DateFormatHelper.formatToIndonesian(ak03!.tanggalMulai)
        : (detailData?.jadwalTanggal.isNotEmpty == true
            ? DateFormatHelper.formatToIndonesian(detailData!.jadwalTanggal)
            : '-');

    final String tglSelesai = ak03?.tanggalSelesai.isNotEmpty == true
        ? DateFormatHelper.formatToIndonesian(ak03!.tanggalSelesai)
        : (detailData?.jadwalTanggal.isNotEmpty == true
            ? DateFormatHelper.formatToIndonesian(detailData!.jadwalTanggal)
            : '-');

    // Build items list
    final List<AK03Item> displayItems = (ak03 != null && ak03.items.isNotEmpty)
        ? ak03.items
        : List.generate(
            _defaultKomponenList.length,
            (i) => AK03Item(
              no: i + 1,
              komponen: _defaultKomponenList[i],
              hasil: 'Ya',
              catatanKomentar: '',
            ),
          );

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.03 Umpan Balik & Catatan Asesmen',
            status: ak03?.status ?? 'Telah Diisi Peserta',
          ),
          const SizedBox(height: 10),

          // Banner Read-Only info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Formulir ini diisi oleh Peserta (Asesi) sebagai evaluasi dan umpan balik pelaksanaan asesmen. Mode: Read-Only (Hanya Baca).',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Header Detail Peserta & Tanggal
          _buildInfoRow('Asesi', namaAsesi),
          _buildInfoRow('Tanggal Mulai', tglMulai),
          _buildInfoRow('Tanggal Selesai', tglSelesai),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Daftar Komponen Evaluasi
          const Text(
            'Komponen Evaluasi & Umpan Balik :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = displayItems[index];
              final bool isYa = item.hasil.toLowerCase() == 'ya' || item.hasil == '1';
              final bool isTidak = item.hasil.toLowerCase() == 'tidak' || item.hasil == '0';

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.no}. ',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.komponen,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF334155),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Hasil Badge (Ya / Tidak / -)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isYa
                                ? const Color(0xFFDCFCE7)
                                : (isTidak ? const Color(0xFFFEE2E2) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isYa
                                  ? const Color(0xFF16A34A)
                                  : (isTidak ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isYa
                                    ? Icons.check_circle_rounded
                                    : (isTidak ? Icons.cancel_rounded : Icons.remove_circle_outline_rounded),
                                size: 12,
                                color: isYa
                                    ? const Color(0xFF16A34A)
                                    : (isTidak ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isYa ? 'Ya' : (isTidak ? 'Tidak' : '-'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isYa
                                      ? const Color(0xFF166534)
                                      : (isTidak ? const Color(0xFF991B1B) : const Color(0xFF475569)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (item.catatanKomentar.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'Catatan: ${item.catatanKomentar}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          if (ak03?.umpanBalik.isNotEmpty == true || ak03?.catatan.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            const Text(
              'Catatan Tambahan Asesi :',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            if (ak03?.umpanBalik.isNotEmpty == true)
              AsesiDetailRow('Umpan Balik Umum', ak03!.umpanBalik),
            if (ak03?.catatan.isNotEmpty == true)
              AsesiDetailRow('Catatan Khusus', ak03!.catatan),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          const Text(' :  ', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            ),
          ),
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
class AK05Section extends StatefulWidget {
  final AsesorAsesiDetailData? detailData;
  final VoidCallback? onSaveSuccess;

  const AK05Section({super.key, required this.detailData, this.onSaveSuccess});

  @override
  State<AK05Section> createState() => _AK05SectionState();
}

class _AK05SectionState extends State<AK05Section> {
  late String _selectedKompetensi;
  late String _selectedRekomendasi;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _syncValues();
  }

  @override
  void didUpdateWidget(covariant AK05Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detailData != widget.detailData) _syncValues();
  }

  void _syncValues() {
    final detail = widget.detailData;
    final ak05 = detail?.ak05;
    _selectedKompetensi = _normaliseScore(detail?.isKompeten ?? '');
    _selectedRekomendasi = _normaliseRecommendation(
      detail?.rekomendasiAsesorCode ?? ak05?.rekomendasi ?? '',
    );
  }

  String _normaliseScore(String value) {
    final score = value.trim().toUpperCase();
    return score == 'K' || score == '1' ? 'K' : score == 'BK' || score == '2' ? 'BK' : '0';
  }

  String _normaliseRecommendation(String value) {
    final recommendation = value.trim().toUpperCase();
    if (recommendation == '1' || recommendation == 'K' || recommendation == 'KOMPETEN') return '1';
    if (recommendation == '2' || recommendation == 'BK' || recommendation.contains('BELUM')) return '2';
    return '0';
  }

  Future<void> _saveAssessment() async {
    final asesiId = widget.detailData?.id;
    if (asesiId == null || asesiId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Asesi tidak valid.')));
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await AsesorService.updateAsesiRekomendasi(
      asesiId: asesiId,
      rekomendasiAsesor: _selectedRekomendasi,
      isKompeten: _selectedKompetensi == '0' ? null : _selectedKompetensi,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    final success = result?['status'] == 'success';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result?['message'] ?? (success ? 'Penilaian berhasil disimpan.' : 'Gagal menyimpan penilaian.')),
        backgroundColor: success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      ),
    );
    if (success) widget.onSaveSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detailData;
    final ak05 = detail?.ak05;
    final kuota = ak05?.kuota.isNotEmpty == true ? ak05!.kuota : '-';
    final tanggal = detail?.jadwalTanggal.isNotEmpty == true
        ? DateFormatHelper.formatToIndonesian(detail!.jadwalTanggal)
        : '-';
    final skVerifikasi = ak05?.skVerifikasiTuk.isNotEmpty == true ? ak05!.skVerifikasiTuk : '-';
    final linkRekaman = ak05?.linkFolderRekaman ?? '';
    final namaAsesor = ak05?.namaAsesor.isNotEmpty == true ? ak05!.namaAsesor : '-';

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.05 Laporan Asesmen',
            status: ak05?.status ?? 'Selesai',
          ),
          const SizedBox(height: 12),
          _buildCardTitle(Icons.info_outline_rounded, 'Informasi Asesmen & Link'),
          const SizedBox(height: 8),
          AsesiDetailRow('Skema Sertifikasi', detail?.skemaSertifikat ?? '-'),
          AsesiDetailRow('Nama Jadwal', detail?.jadwalNama ?? '-'),
          AsesiDetailRow('Kuota & Tanggal', '$kuota peserta · $tanggal'),
          AsesiDetailRow('SK Verifikasi TUK', skVerifikasi),
          _buildLinkRow(context, linkRekaman),
          const SizedBox(height: 16),
          _buildCardTitle(Icons.fact_check_outlined, 'Sistem Penilaian Asesi'),
          const SizedBox(height: 10),
          _buildDropdown<String>(
            label: 'Kompetensi Asesi',
            value: _selectedKompetensi,
            items: const [
              DropdownMenuItem(value: '0', child: Text('Pilih penilaian')),
              DropdownMenuItem(value: 'K', child: Text('Kompeten (K)')),
              DropdownMenuItem(value: 'BK', child: Text('Belum Kompeten (BK)')),
            ],
            onChanged: (value) => setState(() => _selectedKompetensi = value ?? '0'),
          ),
          const SizedBox(height: 10),
          _buildDropdown<String>(
            label: 'Rekomendasi Asesor',
            value: _selectedRekomendasi,
            items: const [
              DropdownMenuItem(value: '0', child: Text('Pilih rekomendasi')),
              DropdownMenuItem(value: '1', child: Text('Kompeten (K)')),
              DropdownMenuItem(value: '2', child: Text('Belum Kompeten (BK)')),
            ],
            onChanged: (value) => setState(() => _selectedRekomendasi = value ?? '0'),
          ),
          const SizedBox(height: 10),
          AsesiDetailRow('Asesor Kompetensi', namaAsesor),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _saveAssessment,
              icon: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined, size: 17),
              label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Penilaian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF2563EB)),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildLinkRow(BuildContext context, String url) {
    final hasLink = url.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 135, child: Text('Rekaman Asesmen', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500))),
          const SizedBox(width: 8),
          Expanded(
            child: hasLink
                ? InkWell(
                    onTap: () => openDocumentUrl(context, url),
                    child: const Row(children: [Icon(Icons.folder_open_outlined, size: 15, color: Color(0xFF2563EB)), SizedBox(width: 5), Text('Buka folder rekaman', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600, decoration: TextDecoration.underline))]),
                  )
                : const Text('Belum tersedia', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── 8. AK-06 ──────────────────────────────────────────────────────────────
class AK06Section extends StatefulWidget {
  final AsesorAsesiDetailData? detailData;
  final VoidCallback? onSaveSuccess;

  const AK06Section({super.key, required this.detailData, this.onSaveSuccess});

  @override
  State<AK06Section> createState() => _AK06SectionState();
}

class _AK06SectionState extends State<AK06Section> {
  bool _isPenjelasanExpanded = false;
  bool _isSubmitting = false;

  final TextEditingController _rekomendasiController = TextEditingController();

  // Prinsip asesmen: '0' = belum dipilih, '1' = Ya/Terpenuhi, '2' = Tidak/Belum
  late String _prinsipValid;
  late String _prinsipReliable;
  late String _prinsipFlexible;
  late String _prinsipFair;

  // Dimensi kompetensi: '0' = belum dipilih, '1' = Ya/Terpenuhi, '2' = Tidak/Belum
  late String _taskSkill;
  late String _taskManagementSkill;
  late String _contingencyManagementSkill;
  late String _jobRoleEnvironmentSkill;
  late String _transferSkill;

  static const String _penjelasanText =
      'Formulir ini digunakan untuk meninjau proses asesmen yang telah dilaksanakan. '
      'Asesor memeriksa apakah prosedur asesmen sudah sesuai, prinsip asesmen '
      '(Valid, Reliable, Flexible, Fair) terpenuhi, serta konsistensi keputusan asesmen '
      'terhadap seluruh dimensi kompetensi.';

  @override
  void initState() {
    super.initState();
    _syncFromData();
  }

  @override
  void didUpdateWidget(covariant AK06Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detailData != widget.detailData) _syncFromData();
  }

  @override
  void dispose() {
    _rekomendasiController.dispose();
    super.dispose();
  }

  void _syncFromData() {
    final ak06 = widget.detailData?.ak06;
    _prinsipValid = ak06?.prinsipValid ?? '0';
    _prinsipReliable = ak06?.prinsipReliable ?? '0';
    _prinsipFlexible = ak06?.prinsipFlexible ?? '0';
    _prinsipFair = ak06?.prinsipFair ?? '0';
    _taskSkill = ak06?.taskSkill ?? '0';
    _taskManagementSkill = ak06?.taskManagementSkill ?? '0';
    _contingencyManagementSkill = ak06?.contingencyManagementSkill ?? '0';
    _jobRoleEnvironmentSkill = ak06?.jobRoleEnvironmentSkill ?? '0';
    _transferSkill = ak06?.transferSkill ?? '0';
    final rekom = ak06?.rekomendasiPeningkatan ?? '';
    if (_rekomendasiController.text != rekom) {
      _rekomendasiController.text = rekom;
    }
  }

  Future<void> _saveReview() async {
    final asesiId = widget.detailData?.id;
    if (asesiId == null || asesiId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Asesi tidak valid.'), backgroundColor: Color(0xFFDC2626)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await AsesorService.updateAK06(
      asesiId: asesiId,
      data: {
        'prinsip_valid': _prinsipValid,
        'prinsip_reliable': _prinsipReliable,
        'prinsip_flexible': _prinsipFlexible,
        'prinsip_fair': _prinsipFair,
        'task_skill': _taskSkill,
        'task_management_skill': _taskManagementSkill,
        'contingency_management_skill': _contingencyManagementSkill,
        'job_role_environment_skill': _jobRoleEnvironmentSkill,
        'transfer_skill': _transferSkill,
        'rekomendasi_peningkatan': _rekomendasiController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    final success = result?['status'] == 'success';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result?['message'] ?? (success ? 'Tinjauan proses asesmen berhasil disimpan.' : 'Gagal menyimpan tinjauan proses asesmen.')),
        backgroundColor: success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      ),
    );
    if (success) widget.onSaveSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ak06 = widget.detailData?.ak06;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.06 Meninjau Proses Asesmen',
            status: ak06?.status ?? 'Selesai',
          ),
          const SizedBox(height: 12),

          // ── Card 1: Penjelasan (Dropdown expand/collapse) ──
          _buildExpansionCard(
            icon: Icons.help_outline_rounded,
            title: 'Penjelasan Proses Asesmen',
            expanded: _isPenjelasanExpanded,
            onToggle: () => setState(() => _isPenjelasanExpanded = !_isPenjelasanExpanded),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 4, 0, 2),
              child: Text(
                _penjelasanText,
                style: TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Card 2: Aspek yang Dikaji Ulang & Prinsip Asesmen ──
          _buildCardTitle(Icons.fact_check_outlined, 'Aspek yang Dikaji Ulang & Prinsip Asesmen'),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Prosedur Asesmen',
            ak06?.prosedur.isNotEmpty == true ? ak06!.prosedur : 'Proses asesmen dilaksanakan sesuai prosedur yang ditetapkan',
          ),
          const SizedBox(height: 10),
          _buildOptionDropdown(
            label: 'Prinsip Valid',
            value: _prinsipValid,
            onChanged: (v) => setState(() => _prinsipValid = v ?? '0'),
          ),
          const SizedBox(height: 8),
          _buildOptionDropdown(
            label: 'Prinsip Reliable',
            value: _prinsipReliable,
            onChanged: (v) => setState(() => _prinsipReliable = v ?? '0'),
          ),
          const SizedBox(height: 8),
          _buildOptionDropdown(
            label: 'Prinsip Flexible',
            value: _prinsipFlexible,
            onChanged: (v) => setState(() => _prinsipFlexible = v ?? '0'),
          ),
          const SizedBox(height: 8),
          _buildOptionDropdown(
            label: 'Prinsip Fair',
            value: _prinsipFair,
            onChanged: (v) => setState(() => _prinsipFair = v ?? '0'),
          ),
          const SizedBox(height: 14),

          // ── Card 3: Pemenuhan Dimensi Kompetensi ──
          _buildCardTitle(Icons.grid_view_rounded, 'Pemenuhan Dimensi Kompetensi'),
          const SizedBox(height: 6),
          const Text(
            'Konsistensi keputusan asesmen — bukti dari rentang asesmen diperiksa terhadap konsistensi dimensi kompetensi:',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 10),
          _buildOptionDropdown(
            label: 'Task Skill',
            value: _taskSkill,
            onChanged: (v) => setState(() => _taskSkill = v ?? '0'),
          ),
          const SizedBox(height: 8),
          _buildOptionDropdown(
            label: 'Task Management Skill',
            value: _taskManagementSkill,
            onChanged: (v) => setState(() => _taskManagementSkill = v ?? '0'),
          ),
          const SizedBox(height: 8),
          _buildOptionDropdown(
            label: 'Contingency Management Skill',
            value: _contingencyManagementSkill,
            onChanged: (v) => setState(() => _contingencyManagementSkill = v ?? '0'),
          ),
          const SizedBox(height: 8),
          _buildOptionDropdown(
            label: 'Job Role/Environment Skill',
            value: _jobRoleEnvironmentSkill,
            onChanged: (v) => setState(() => _jobRoleEnvironmentSkill = v ?? '0'),
          ),
          const SizedBox(height: 8),
          _buildOptionDropdown(
            label: 'Transfer Skill',
            value: _transferSkill,
            onChanged: (v) => setState(() => _transferSkill = v ?? '0'),
          ),
          const SizedBox(height: 14),

          // Rekomendasi untuk peningkatan
          const Text(
            'Rekomendasi untuk peningkatan:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _rekomendasiController,
            maxLines: 3,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Tuliskan rekomendasi untuk peningkatan proses asesmen...',
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
          const SizedBox(height: 14),

          // Tombol Simpan Perubahan
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _saveReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 17),
              label: Text(
                _isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF2563EB)),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
          items: const [
            DropdownMenuItem(value: '0', child: Text('Pilih')),
            DropdownMenuItem(value: '1', child: Text('Terpenuhi')),
            DropdownMenuItem(value: '2', child: Text('Belum Terpenuhi')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildExpansionCard({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, size: 17, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: child,
            ),
        ],
      ),
    );
  }
}

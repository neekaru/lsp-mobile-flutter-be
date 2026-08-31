// ============================================================================
// FR-AK.01 Persetujuan & Kerahasiaan.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

class AK01Section extends StatefulWidget {
  final AsesorAsesiDetailData? detailData;
  final VoidCallback? onSaveSuccess;

  const AK01Section({
    super.key,
    required this.detailData,
    this.onSaveSuccess,
  });

  @override
  State<AK01Section> createState() => _AK01SectionState();
}

class _AK01SectionState extends State<AK01Section> {
  bool _isSubmitting = false;
  String _asesorOption = '1'; // '1': Setuju, '0': Tidak Setuju
  String _asesiOption = '1';  // '1': Setuju, '2': Tidak Setuju
  bool _isSigned = false;
  late List<Map<String, dynamic>> _buktiList;

  @override
  void initState() {
    super.initState();
    _initBuktiList();
  }

  @override
  void didUpdateWidget(covariant AK01Section oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detailData != widget.detailData) {
      _initBuktiList();
    }
  }

  void _initBuktiList() {
    final ak01 = widget.detailData?.ak01;
    final defaultBukti = [
      {'id': '1', 'nama': 'Hasil Verifikasi Portofolio', 'checked': false},
      {'id': '2', 'nama': 'Hasil Reviu Produk', 'checked': false},
      {'id': '3', 'nama': 'Hasil Observasi Langsung', 'checked': true},
      {'id': '4', 'nama': 'Hasil Kegiatan Terstruktur', 'checked': false},
      {'id': '5', 'nama': 'Hasil Pertanyaan Lisan', 'checked': false},
      {'id': '6', 'nama': 'Hasil Pertanyaan Tertulis', 'checked': true},
      {'id': '7', 'nama': 'Lainnya', 'checked': false},
      {'id': '8', 'nama': 'Hasil Pertanyaan Wawancara', 'checked': false},
    ];

    if (ak01?.buktiDikumpulkan.isNotEmpty == true) {
      _buktiList = List<Map<String, dynamic>>.from(defaultBukti);
      for (int i = 0; i < _buktiList.length; i++) {
        final match = ak01!.buktiDikumpulkan.firstWhere(
          (b) => b.nama.toLowerCase().trim() == _buktiList[i]['nama'].toString().toLowerCase().trim(),
          orElse: () => BuktiAK01Item(nama: '', checked: false),
        );
        if (match.nama.isNotEmpty) {
          _buktiList[i]['checked'] = match.checked;
        }
      }
    } else {
      _buktiList = List<Map<String, dynamic>>.from(defaultBukti);
    }
  }

  Future<void> _submitApproval() async {
    final asesiId = widget.detailData?.id ?? 0;
    if (asesiId == 0) return;

    if (!_isSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang persetujuan tanda tangan dokumen terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final checkedIds = _buktiList
        .where((b) => b['checked'] == true)
        .map((b) => b['id'].toString())
        .toList();

    try {
      final res = await AsesorService.updateAK01(
        asesiId: asesiId,
        validasiAK01: _asesorOption,
        opsiPersetujuanAsesmen: _asesiOption,
        bukti: checkedIds,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (res != null && res['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Formulir FR-AK.01 berhasil disetujui'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          widget.onSaveSuccess?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res?['message'] ?? 'Gagal menyetujui formulir FR-AK.01.'),
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
    final ak01 = widget.detailData?.ak01;
    final bool isApproved = ak01?.status == 'Disetujui' ||
        ak01?.tandaTanganAsesi == true ||
        ak01?.tandaTanganAsesor == true ||
        ak01?.tandaTangan == true;

    final String tglFormatted = ak01?.tglAsesmen.isNotEmpty == true
        ? DateFormatHelper.formatToIndonesian(ak01!.tglAsesmen)
        : (widget.detailData?.jadwalTanggal.isNotEmpty == true
            ? DateFormatHelper.formatToIndonesian(widget.detailData!.jadwalTanggal)
            : '26 Agustus 2026');

    final String judulSkema = ak01?.judulSkema.isNotEmpty == true
        ? ak01!.judulSkema
        : (widget.detailData?.skemaSertifikat.isNotEmpty == true
            ? widget.detailData!.skemaSertifikat
            : 'Pemrogram Web Pratama');

    final String nomorSkema = ak01?.nomorSkema.isNotEmpty == true
        ? ak01!.nomorSkema
        : (widget.detailData?.idSkema.isNotEmpty == true
            ? 'SKK-${widget.detailData!.idSkema}'
            : 'SKK-28-10/2024');

    final String tuk = ak01?.tuk.isNotEmpty == true
        ? ak01!.tuk
        : (widget.detailData?.tukNama.isNotEmpty == true ? widget.detailData!.tukNama : 'SMKN 5 MALANG');

    final String namaAsesor = ak01?.namaAsesor.isNotEmpty == true
        ? ak01!.namaAsesor
        : 'Asesor LSP';

    final String namaAsesi = ak01?.namaAsesi.isNotEmpty == true
        ? ak01!.namaAsesi
        : (widget.detailData?.namaLengkap.isNotEmpty == true ? widget.detailData!.namaLengkap : 'Peserta Asesmen');

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.01 Persetujuan & Kerahasiaan',
            status: isApproved ? 'Disetujui' : (ak01?.status ?? 'Belum Disetujui'),
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
            itemCount: _buktiList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 8,
              childAspectRatio: 3.8,
            ),
            itemBuilder: (context, index) {
              final item = _buktiList[index];
              final bool isChecked = item['checked'] == true;
              final String name = item['nama'] as String;

              return InkWell(
                onTap: isApproved
                    ? null
                    : () {
                        setState(() {
                          _buktiList[index]['checked'] = !isChecked;
                        });
                      },
                borderRadius: BorderRadius.circular(6),
                child: Container(
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
                _buildScheduleRow(
                  'Waktu',
                  (ak01 != null && ak01.waktu.trim().isNotEmpty && ak01.waktu.trim() != '0')
                      ? (ak01.waktu.toLowerCase().contains('wib') ? ak01.waktu : '${ak01.waktu} WIB')
                      : '08:00 WIB',
                ),
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

          // Pernyataan Asesor
          _buildInteractivePernyataanCard(
            title: 'Asesor',
            selectedValue: _asesorOption,
            isLocked: isApproved,
            onChanged: (val) {
              if (val != null) setState(() => _asesorOption = val);
            },
            color: const Color(0xFF2563EB),
            bgHeader: const Color(0xFFEFF6FF),
            options: const [
              DropdownMenuItem(value: '1', child: Text('Setuju')),
              DropdownMenuItem(value: '0', child: Text('Tidak Setuju')),
            ],
            isi: 'Menyatakan tidak akan membuka hasil pekerjaan yang saya peroleh karena penugasan saya sebagai Asesor dalam pekerjaan Asesmen kepada siapapun atau organisasi apapun selain kepada pihak yang berwenang sehubungan dengan kewajiban saya sebagai Asesor yang ditugaskan oleh LSP.\n\nMenyatakan setuju untuk melaksanakan asesmen sesuai dengan prosedur yang ditentukan.',
          ),

          const SizedBox(height: 10),

          // Pernyataan Peserta (Asesi)
          _buildInteractivePernyataanCard(
            title: 'Peserta Sertifikasi (Asesi)',
            selectedValue: _asesiOption,
            isLocked: isApproved,
            onChanged: (val) {
              if (val != null) setState(() => _asesiOption = val);
            },
            color: const Color(0xFF16A34A),
            bgHeader: const Color(0xFFDCFCE7),
            options: const [
              DropdownMenuItem(value: '1', child: Text('Setuju')),
              DropdownMenuItem(value: '2', child: Text('Tidak Setuju')),
            ],
            isi: 'Saya setuju bahwa saya telah mendapatkan penjelasan terkait hak dan prosedur banding asesmen dari asesor dan mengikuti asesmen dengan pemahaman bahwa informasi yang dikumpulkan hanya digunakan untuk pengembangan profesional dan hanya dapat diakses oleh orang tertentu saja.',
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
                    color: isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isApproved ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isApproved ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: isApproved ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'Tanda Tangan Peserta',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isApproved ? 'Tanggal: $tglFormatted' : 'Menunggu Persetujuan',
                        style: TextStyle(
                          fontSize: 10,
                          color: isApproved ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
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
                    color: isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isApproved ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isApproved ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: isApproved ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'Tanda Tangan Asesor',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isApproved ? 'Tanggal: $tglFormatted' : 'Menunggu Persetujuan',
                        style: TextStyle(
                          fontSize: 10,
                          color: isApproved ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // 6. CHECKBOX TANDA TANGAN & TOMBOL SIMPAN
          if (_isSigned || isApproved) ...[
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
                    QrImageView(
                      data: 'https://sertifikasi.lspdigital.id/qrcode/e_dokumen/0/${widget.detailData?.jadwalId ?? 0}/${widget.detailData?.id ?? 0}/validasi_ak01',
                      version: QrVersions.auto,
                      size: 110.0,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tanda Tangan Elektronik Asesor & Asesi Tervalidasi',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (isApproved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Persetujuan FR-AK.01 telah lengkap dan disetujui oleh Asesor & Asesi.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF15803D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            InkWell(
              onTap: () {
                setState(() {
                  _isSigned = !_isSigned;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isSigned,
                      onChanged: (val) {
                        setState(() {
                          _isSigned = val ?? false;
                        });
                      },
                      activeColor: const Color(0xFF16A34A),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Expanded(
                      child: Text(
                        'Saya setuju menandatangani dokumen persetujuan ini.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC2626), // Merah sesuai format web
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting || !_isSigned ? null : _submitApproval,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                label: Text(
                  _isSubmitting ? 'Memproses Persetujuan...' : 'Simpan & Setujui Formulir FR-AK.01',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractivePernyataanCard({
    required String title,
    required String selectedValue,
    required bool isLocked,
    required ValueChanged<String?> onChanged,
    required Color color,
    required Color bgHeader,
    required List<DropdownMenuItem<String>> options,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bgHeader,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (!isLocked)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        items: options,
                        onChanged: onChanged,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Setuju',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
              ],
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
}

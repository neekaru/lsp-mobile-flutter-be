// ============================================================================
// FR-AK.01 Persetujuan & Kerahasiaan (read-only).
// Diekstrak dari asesi_ak_sections.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/asesor_asesi_models.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

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

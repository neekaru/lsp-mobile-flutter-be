// ============================================================================
// FR-AK.03 Umpan Balik & Catatan Asesmen (read-only, diisi asesi).
// Diekstrak dari asesi_ak_sections.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/asesor_asesi_models.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

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
              return _buildItemCard(displayItems[index]);
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

  Widget _buildItemCard(AK03Item item) {
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
              _buildHasilBadge(isYa: isYa, isTidak: isTidak),
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
  }

  Widget _buildHasilBadge({required bool isYa, required bool isTidak}) {
    return Container(
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

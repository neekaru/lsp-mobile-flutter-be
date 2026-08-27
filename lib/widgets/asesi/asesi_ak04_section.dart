// ============================================================================
// FR.AK.04A Permohonan Banding & FR.AK.04B Keputusan Banding Asesmen.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import 'asesi_form_common.dart';

/// FR.AK.04A Permohonan Banding Asesmen (Pengajuan oleh Asesi)
class AK04ASection extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK04ASection({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak04 = detailData?.ak04;
    final adaBanding = ak04?.adaBanding == true;

    final pertanyaanList = (ak04 != null && ak04.pertanyaan.isNotEmpty)
        ? ak04.pertanyaan
        : [
            AK04PertanyaanItem(no: 1, pertanyaan: 'Apakah Proses Banding telah dijelaskan kepada anda?', jawaban: null),
            AK04PertanyaanItem(no: 2, pertanyaan: 'Apakah anda telah mendiskusikan banding dengan asesor?', jawaban: null),
            AK04PertanyaanItem(no: 3, pertanyaan: 'Apakah anda mau melibatkan "orang lain" membantu anda dalam Proses Banding?', jawaban: null),
          ];

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR.AK.04A Permohonan Banding Asesmen',
            status: adaBanding ? 'Ada Permohonan Banding' : 'Tidak Ada Permohonan Banding',
            statusColor: adaBanding ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Info Peserta & Asesor
          AsesiDetailRow('Nama Asesi', ak04?.namaAsesi.isNotEmpty == true ? ak04!.namaAsesi : (detailData?.namaLengkap ?? '-')),
          AsesiDetailRow('Nama Asesor', ak04?.namaAsesor.isNotEmpty == true ? ak04!.namaAsesor : (detailData?.ak01.namaAsesor.isNotEmpty == true ? detailData!.ak01.namaAsesor : '-')),
          AsesiDetailRow('Tanggal Asesmen', ak04?.tanggalAsesmen.isNotEmpty == true ? ak04!.tanggalAsesmen : (detailData?.jadwalTanggal ?? '-')),
          AsesiDetailRow('Skema Sertifikasi', ak04?.skema.isNotEmpty == true ? ak04!.skema : (detailData?.skemaSertifikat ?? '-')),
          if (ak04?.noSkema.isNotEmpty == true)
            AsesiDetailRow('No. Skema', ak04!.noSkema),
          const SizedBox(height: 14),

          // List Pertanyaan Banding as Cards
          const Text(
            'Pertanyaan Proses Banding (Oleh Asesi) :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          ...pertanyaanList.map((p) {
            final isYa = p.jawaban != null && p.jawaban!.toLowerCase() == 'ya';
            final isTidak = p.jawaban != null && p.jawaban!.toLowerCase() == 'tidak';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.no}. ${p.pertanyaan}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPill(
                        label: 'Ya',
                        isSelected: isYa,
                        selectedColor: const Color(0xFF16A34A),
                        selectedBg: const Color(0xFFDCFCE7),
                      ),
                      const SizedBox(width: 8),
                      _buildPill(
                        label: 'Tidak',
                        isSelected: isTidak,
                        selectedColor: const Color(0xFFDC2626),
                        selectedBg: const Color(0xFFFEE2E2),
                      ),
                      if (!isYa && !isTidak) ...[
                        const SizedBox(width: 8),
                        _buildPill(
                          label: 'Kosong / Belum Diisi',
                          isSelected: true,
                          selectedColor: const Color(0xFF64748B),
                          selectedBg: const Color(0xFFE2E8F0),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          AsesiDetailRow(
            'Alasan / Uraian Banding',
            adaBanding && ak04?.alasanBanding.isNotEmpty == true ? ak04!.alasanBanding : '(Tidak ada permohonan banding dari asesi)',
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required Color selectedBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? selectedColor : const Color(0xFFCBD5E1),
          width: isSelected ? 1.2 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            Icon(
              label == 'Tidak' ? LucideIcons.x : (label == 'Ya' ? LucideIcons.check : LucideIcons.minus),
              size: 13,
              color: selectedColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? selectedColor : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// FR.AK.04B Keputusan Banding Asesmen (Keputusan oleh Tim Banding / Asesor)
class AK04BSection extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK04BSection({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak04 = detailData?.ak04;
    final adaBanding = ak04?.adaBanding == true;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR.AK.04B Keputusan Banding Asesmen',
            status: adaBanding ? 'Dalam Proses Banding' : 'Keputusan Asesor Tetap Berlaku',
            statusColor: adaBanding ? const Color(0xFFD97706) : const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Info Peserta & Skema
          AsesiDetailRow('Nama Asesi', detailData?.namaLengkap ?? '-'),
          AsesiDetailRow('Skema Sertifikasi', detailData?.skemaSertifikat ?? '-'),
          AsesiDetailRow('Status Permohonan', adaBanding ? 'Terdapat Permohonan Banding' : 'Tidak Ada Permohonan Banding'),
          const SizedBox(height: 14),

          // Status Keputusan Banding Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: adaBanding ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: adaBanding ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  adaBanding ? LucideIcons.alert_circle : LucideIcons.check_circle_2,
                  size: 20,
                  color: adaBanding ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adaBanding ? 'Keputusan Banding: Dalam Peninjauan' : 'Keputusan Banding: Sah / Tidak Ada Banding',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: adaBanding ? const Color(0xFF92400E) : const Color(0xFF166534),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adaBanding
                            ? 'Permohonan banding sedang ditinjau oleh Komite / Tim Banding LSP.'
                            : 'Hasil asesmen yang direkomendasikan oleh asesor dinyatakan sah dan berkekuatan tetap.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: adaBanding ? const Color(0xFFB45309) : const Color(0xFF15803D),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Rekomendasi & Catatan Tim Banding
          AsesiDetailRow(
            'Catatan / Rekomendasi Tim Banding',
            adaBanding && ak04?.alasanBanding.isNotEmpty == true
                ? ak04!.alasanBanding
                : 'Tidak ada perubahan terhadap keputusan awal asesor.',
          ),
          const SizedBox(height: 12),

          // Info Validasi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.shield_check, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tervalidasi oleh Komite Teknis / Tim Banding LSP',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Composite Section backward compatibility
class AK04Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK04Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AK04ASection(detailData: detailData),
        const SizedBox(height: 16),
        AK04BSection(detailData: detailData),
      ],
    );
  }
}

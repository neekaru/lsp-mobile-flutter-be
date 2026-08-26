// ============================================================================
// FR.AK.04 Banding Asesmen (read-only).
// Diekstrak dari asesi_ak_sections.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import 'asesi_form_common.dart';

class AK04Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK04Section({super.key, required this.detailData});

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
            title: 'FR.AK.04 Banding Asesmen',
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
            'Pertanyaan Proses Banding :',
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
            'Alasan Banding',
            adaBanding && ak04?.alasanBanding.isNotEmpty == true ? ak04!.alasanBanding : '(Tidak ada permohonan banding)',
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

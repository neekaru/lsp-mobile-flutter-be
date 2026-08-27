// ============================================================================
// FR.AK.07 Penyesuaian yang Wajar dan Beralasan (Reasonable Adjustment).
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/asesor_asesi_models.dart';
import 'asesi_form_common.dart';

class AK07Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK07Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormSectionHeader(
            title: 'FR.AK.07 Penyesuaian Wajar Beralasan',
            status: 'Tidak Ada Penyesuaian Khusus',
            statusColor: Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Info Peserta & Asesor
          AsesiDetailRow('Nama Asesi', detailData?.namaLengkap ?? '-'),
          AsesiDetailRow('Nama Asesor', detailData?.ak01.namaAsesor.isNotEmpty == true ? detailData!.ak01.namaAsesor : '-'),
          AsesiDetailRow('Tanggal Asesmen', detailData?.jadwalTanggal ?? '-'),
          AsesiDetailRow('Skema Sertifikasi', detailData?.skemaSertifikat ?? '-'),
          const SizedBox(height: 14),

          // Penjelasan Form
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.info, size: 18, color: Color(0xFF2563EB)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Formulir ini digunakan untuk mengidentifikasi apakah asesi memerlukan penyesuaian wajar dan beralasan dalam proses asesmen tanpa mengurangi standar kompetensi.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Hasil Identifikasi & Penyesuaian :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          _buildCheckItem(
            no: 1,
            title: 'Kebutuhan Khusus / Hambatan Asesi',
            value: 'Tidak ada kebutuhan khusus yang dilaporkan oleh asesi.',
            isNormal: true,
          ),
          _buildCheckItem(
            no: 2,
            title: 'Penyesuaian Metode Asesmen',
            value: 'Metode asesmen standar sesuai MAPA yang telah disepakati.',
            isNormal: true,
          ),
          _buildCheckItem(
            no: 3,
            title: 'Fasilitas & Peralatan Pendukung TUK',
            value: 'Fasilitas TUK telah memenuhi persyaratan teknis uji kompetensi.',
            isNormal: true,
          ),

          const SizedBox(height: 14),

          // Validasi Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.check_circle_2, size: 20, color: Color(0xFF16A34A)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Persetujuan Penyesuaian Tervalidasi',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Asesor dan asesi menyetujui pelaksanaan asesmen dengan kondisi standar tanpa penyesuaian khusus.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF15803D), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required int no,
    required String title,
    required String value,
    required bool isNormal,
  }) {
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
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$no',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
              const Icon(LucideIcons.check, size: 16, color: Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}


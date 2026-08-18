// ============================================================================
// Section form APL-01 & APL-02 (asesi).
//
// Diekstrak dari asesi_form_sections.dart agar tiap bagian form asesi
// menjadi modul tersendiri.
// ============================================================================

import 'package:flutter/material.dart';

import '../../models/asesor_asesi_models.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

// ── 1. APL-01 ─────────────────────────────────────────────────────────────
class APL01Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const APL01Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final apl01 = detailData?.apl01;
    final dasarList = apl01?.persyaratanDasar ?? [];
    final adminList = apl01?.persyaratanAdministratif ?? [];
    final allDocs = apl01?.buktiDokumen ?? [];

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-APL.01 Permohonan Sertifikasi',
            status: (apl01?.status != null && apl01!.status.isNotEmpty)
                ? apl01.status
                : 'Belum Terverifikasi',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow(
            'Rekomendasi Admin',
            (apl01?.rekomendasi != null &&
                    apl01!.rekomendasi.isNotEmpty &&
                    apl01.rekomendasi != '0')
                ? apl01.rekomendasi
                : 'Belum Diverifikasi',
          ),
          if (apl01?.catatan.isNotEmpty == true)
            AsesiDetailRow('Catatan', apl01!.catatan),
          if (apl01?.tanggalValidasi.isNotEmpty == true)
            AsesiDetailRow(
              'Tanggal Validasi',
              DateFormatHelper.formatToIndonesianWithTime(apl01!.tanggalValidasi),
            ),
          const SizedBox(height: 16),

          // 1. PERSYARATAN DASAR
          const Text(
            'PERSYARATAN DASAR',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          if (dasarList.isNotEmpty)
            ...dasarList.asMap().entries.map(
                  (entry) => DocItem(
                    index: entry.key + 1,
                    name: entry.value.nama,
                    jenis: entry.value.jenis,
                    ada: entry.value.ada,
                    url: entry.value.url,
                  ),
                )
          else if (allDocs.any((d) => d.jenis == 'Dasar' || (d.jenis == 'Wajib' && d.jenisBukti != 'foto' && d.jenisBukti != 'ktp_kk')))
            ...allDocs
                .where((d) => d.jenis == 'Dasar' || (d.jenis == 'Wajib' && d.jenisBukti != 'foto' && d.jenisBukti != 'ktp_kk'))
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => DocItem(
                    index: entry.key + 1,
                    name: entry.value.nama,
                    jenis: entry.value.jenis,
                    ada: entry.value.ada,
                    url: entry.value.url,
                  ),
                )
          else ...[
            const DocItem(index: 1, name: 'Foto Copy Transkrip Nilai / Ijazah Terakhir', jenis: 'Dasar', ada: true),
            const DocItem(index: 2, name: 'Foto Copy Sertifikat Pelatihan Berbasis Kompetensi', jenis: 'Dasar', ada: false),
            const DocItem(index: 3, name: 'Surat Keterangan Pengalaman Kerja di Bidang Terkait', jenis: 'Dasar', ada: false),
          ],

          const SizedBox(height: 18),

          // 2. PERSYARATAN ADMINISTRATIF
          const Text(
            'PERSYARATAN ADMINISTRATIF',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          if (adminList.isNotEmpty)
            ...adminList.asMap().entries.map(
                  (entry) => DocItem(
                    index: entry.key + 1,
                    name: entry.value.nama,
                    jenis: entry.value.jenis,
                    ada: entry.value.ada,
                    url: entry.value.url,
                  ),
                )
          else ...[
            DocItem(
              index: 1,
              name: 'Pasfoto *',
              jenis: 'Wajib',
              ada: detailData?.fotoProfilUrl != null && detailData!.fotoProfilUrl!.isNotEmpty,
              url: detailData?.fotoProfilUrl,
            ),
            DocItem(
              index: 2,
              name: 'Identitas Pribadi (KTP / Kartu Pelajar) *',
              jenis: 'Wajib',
              ada: (detailData?.nik.isNotEmpty ?? false),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 2. APL-02 ─────────────────────────────────────────────────────────────
class APL02Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const APL02Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final apl02 = detailData?.apl02;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-APL.02 Asesmen Mandiri',
            status: apl02?.status ?? 'Lengkap',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  'Total Unit',
                  '${apl02?.totalUnit ?? 0}',
                  const Color(0xFF2563EB),
                  const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  'Kompeten [K]',
                  '${apl02?.totalK ?? 0}',
                  const Color(0xFF059669),
                  const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  'Belum [BK]',
                  '${apl02?.totalBK ?? 0}',
                  const Color(0xFFDC2626),
                  const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Daftar Unit Kompetensi:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (apl02 != null && apl02.units.isNotEmpty)
            ...apl02.units.map((u) => UnitItem(unit: u))
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Data unit kompetensi telah terverifikasi kompeten pada skema sertifikasi.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import '../asesi/asesi_form_common.dart';

class Ak05CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const Ak05CountChip(
    this.label,
    this.count,
    this.color, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class Ak05InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;

  const Ak05InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ],
    );
  }
}

class Ak05PesertaCard extends StatelessWidget {
  final int no;
  final JadwalAK05PesertaItem p;

  const Ak05PesertaCard({
    super.key,
    required this.no,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final isK = p.rekomendasiAsesor == '1';
    final isBK = p.rekomendasiAsesor == '2';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isK
              ? const Color(0xFFBBF7D0)
              : isBK
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$no',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.namaLengkap,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'No: ${p.noPeserta.isNotEmpty ? p.noPeserta : '-'} • NIK: ${p.nik}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Read-only Assessment Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isK
                      ? const Color(0xFFDCFCE7)
                      : isBK
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isK
                        ? const Color(0xFF86EFAC)
                        : isBK
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isK
                          ? Icons.check_circle_rounded
                          : isBK
                              ? Icons.cancel_rounded
                              : Icons.schedule_rounded,
                      size: 14,
                      color: isK
                          ? const Color(0xFF16A34A)
                          : isBK
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isK
                          ? 'Kompeten (K)'
                          : isBK
                              ? 'Belum Kompeten (BK)'
                              : 'Belum Dinilai',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isK
                            ? const Color(0xFF16A34A)
                            : isBK
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isBK) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: p.unitBk,
              decoration: InputDecoration(
                labelText: 'Unit yang Belum Kompeten',
                hintText: 'Contoh: J.620100.004.01',
                labelStyle: const TextStyle(fontSize: 11),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
              style: const TextStyle(fontSize: 12),
              onChanged: (val) {
                p.unitBk = val.trim();
              },
            ),
          ],
        ],
      ),
    );
  }
}

Widget buildAk05PenilaianSection({
  required JadwalAK05DetailData data,
}) {
  return FormSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Penilaian Peserta',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Total: ${data.peserta.length} Peserta',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        // Info note
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Status rekomendasi peserta merupakan rekapitulasi hasil asesmen yang telah dinilai pada FR-AK.02 (Rekaman Asesmen).',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1D4ED8),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Summary chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Ak05CountChip('Kompeten', data.peserta.where((p) => p.rekomendasiAsesor == '1').length, const Color(0xFF16A34A)),
            Ak05CountChip('Belum Kompeten', data.peserta.where((p) => p.rekomendasiAsesor == '2').length, const Color(0xFFDC2626)),
            Ak05CountChip('Belum Rekomendasi', data.peserta.where((p) => p.rekomendasiAsesor != '1' && p.rekomendasiAsesor != '2').length, const Color(0xFF94A3B8)),
          ],
        ),
        const SizedBox(height: 14),

        // Peserta Items
        ...data.peserta.asMap().entries.map((entry) {
          final index = entry.key;
          final p = entry.value;
          return Ak05PesertaCard(no: index + 1, p: p);
        }),
      ],
    ),
  );
}

Widget buildAk05RekomendasiSection({
  required TextEditingController pencapaianController,
  required TextEditingController unitBkController,
  required TextEditingController saranController,
  required TextEditingController peliharaController,
  required TextEditingController catatanController,
}) {
  return FormSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan & Rekomendasi Kolektif',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 12),

        Ak05InputField(
          label: 'Pencapaian Unjuk Kerja',
          controller: pencapaianController,
          hintText: 'Pencapaian unjuk kerja peserta...',
        ),
        const SizedBox(height: 12),
        Ak05InputField(
          label: 'Unit yang Belum Kompeten (Jika ada)',
          controller: unitBkController,
          hintText: 'Kosongkan jika semua peserta kompeten...',
        ),
        const SizedBox(height: 12),
        Ak05InputField(
          label: 'Saran Tindak Lanjut',
          controller: saranController,
          hintText: 'Saran tindak lanjut bagi peserta...',
        ),
        const SizedBox(height: 12),
        Ak05InputField(
          label: 'Pelihara Kompetensi',
          controller: peliharaController,
          hintText: 'Saran pemeliharaan kompetensi...',
        ),
        const SizedBox(height: 12),
        Ak05InputField(
          label: 'Catatan Laporan',
          controller: catatanController,
          hintText: 'Catatan tambahan asesmen...',
        ),
      ],
    ),
  );
}

Widget buildAk05SaveButton({
  required bool isSaving,
  required bool isUnlocked,
  required VoidCallback onSave,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton.icon(
      onPressed: (isSaving || !isUnlocked) ? null : onSave,
      icon: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(!isUnlocked ? Icons.lock_outline : LucideIcons.save, size: 18),
      label: Text(
        isSaving
            ? 'Menyimpan Laporan...'
            : !isUnlocked
                ? 'Formulir Terkunci (Selesaikan AK.01)'
                : 'Simpan Laporan Asesmen (AK.05)',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: !isUnlocked ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
    ),
  );
}

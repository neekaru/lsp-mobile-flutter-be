import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';

class IA01InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const IA01InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class IA01KeputusanObservasiCard extends StatelessWidget {
  final IA01UnitKompetensi currentUnit;
  final TextEditingController alasanPertanyaanCtrl;
  final TextEditingController alasanBuktiCtrl;
  final TextEditingController catatanCtrl;
  final ValueChanged<String?> onRekomChanged;

  const IA01KeputusanObservasiCard({
    super.key,
    required this.currentUnit,
    required this.alasanPertanyaanCtrl,
    required this.alasanBuktiCtrl,
    required this.catatanCtrl,
    required this.onRekomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isK = currentUnit.rekomendasiUnit == 'K';
    final isBK = currentUnit.rekomendasiUnit == 'BK';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keputusan & Rekomendasi Unit',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Dropdown Keputusan Unit
          Row(
            children: [
              const SizedBox(
                width: 110,
                child: Text(
                  'Hasil Unit:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isK
                        ? const Color(0xFFDCFCE7)
                        : isBK
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isK
                          ? const Color(0xFF16A34A)
                          : isBK
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: (currentUnit.rekomendasiUnit == 'K' || currentUnit.rekomendasiUnit == 'BK')
                          ? currentUnit.rekomendasiUnit
                          : null,
                      hint: const Text(
                        '- Pilih Rekomendasi -',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'K',
                          child: Text(
                            'Kompeten (K)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'BK',
                          child: Text(
                            'Belum Kompeten (BK)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                          ),
                        ),
                      ],
                      onChanged: onRekomChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Alasan Pertanyaan Pendukung (jika BK)
          if (isBK) ...[
            IA01InputField(
              label: 'Alasan Pertanyaan Pendukung Observasi (IA.03)',
              controller: alasanPertanyaanCtrl,
              hint: 'Tuliskan alasan mengapa diperlukan pertanyaan lisan tambahan...',
              onChanged: (v) => currentUnit.alasanPertanyaanPendukung = v,
            ),
            const SizedBox(height: 10),
            IA01InputField(
              label: 'Alasan Bukti Tambahan (IA.04)',
              controller: alasanBuktiCtrl,
              hint: 'Tuliskan alasan jika diperlukan bukti verifikasi pihak ketiga...',
              onChanged: (v) => currentUnit.alasanBuktiTambahan = v,
            ),
            const SizedBox(height: 10),
          ],

          IA01InputField(
            label: 'Catatan Asesor untuk Unit Ini',
            controller: catatanCtrl,
            hint: 'Catatan pengamatan atau unjuk kerja asesi...',
            onChanged: (v) => currentUnit.catatanUnit = v,
          ),
        ],
      ),
    );
  }
}

class IA01CatatanOnlyCard extends StatelessWidget {
  final IA01UnitKompetensi currentUnit;
  final TextEditingController catatanCtrl;

  const IA01CatatanOnlyCard({
    super.key,
    required this.currentUnit,
    required this.catatanCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unit Kompetensi ${currentUnit.noUnit}',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          IA01InputField(
            label: 'Catatan Asesor untuk Unit Ini',
            controller: catatanCtrl,
            hint: 'Catatan pengamatan atau unjuk kerja asesi...',
            onChanged: (v) => currentUnit.catatanUnit = v,
          ),
        ],
      ),
    );
  }
}

class IA01RekomendasiKeseluruhanCard extends StatelessWidget {
  final String rekomendasi;
  final TextEditingController catatanController;
  final String buktiTambahanPmo;
  final String buktiTambahan;
  final TextEditingController alasanPmoController;
  final ValueChanged<String> onRekomChanged;
  final ValueChanged<String?> onPmoChanged;
  final ValueChanged<String?> onBuktiChanged;

  const IA01RekomendasiKeseluruhanCard({
    super.key,
    required this.rekomendasi,
    required this.catatanController,
    required this.buktiTambahanPmo,
    required this.buktiTambahan,
    required this.alasanPmoController,
    required this.onRekomChanged,
    required this.onPmoChanged,
    required this.onBuktiChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isK = rekomendasi == 'K';
    final isBK = rekomendasi == 'BK';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isK ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isK ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  LucideIcons.award,
                  size: 18,
                  color: isK ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekomendasi Keseluruhan Observasi (FR.IA.01)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Keputusan ini otomatis muncul di FR-AK.02 & Laporan FR-AK.05',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Big Segmented Button for Overall Recommendation
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onRekomChanged('K'),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isK ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isK ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        width: isK ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isK ? LucideIcons.circle_check : LucideIcons.circle,
                          size: 18,
                          color: isK ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kompeten (K)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isK ? FontWeight.bold : FontWeight.w600,
                            color: isK ? const Color(0xFF15803D) : const Color(0xFF64748B),
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
                  onTap: () => onRekomChanged('BK'),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isBK ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBK ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                        width: isBK ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isBK ? LucideIcons.circle_x : LucideIcons.circle,
                          size: 18,
                          color: isBK ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Belum Kompeten (BK)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isBK ? FontWeight.bold : FontWeight.w600,
                            color: isBK ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          IA01InputField(
            label: 'Catatan & Umpan Balik Asesor Keseluruhan',
            controller: catatanController,
            hint: 'Tuliskan catatan keseluruhan hasil observasi asesi...',
            onChanged: (v) {},
          ),
          const SizedBox(height: 12),

          // Diperlukan Pertanyaan Pendukung (PMO)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diperlukan Pertanyaan Pendukung:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: buktiTambahanPmo,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                          items: const [
                            DropdownMenuItem(value: '0', child: Text('Tidak')),
                            DropdownMenuItem(value: '1', child: Text('Ya')),
                          ],
                          onChanged: onPmoChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keterangan / Alasan:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: alasanPmoController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Misal: Sudah terpenuhi saat TPD',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Diperlukan Bukti Tambahan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diperlukan Bukti Tambahan:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              Container(
                height: 40,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: buktiTambahan,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                    items: const [
                      DropdownMenuItem(value: '0', child: Text('Tidak')),
                      DropdownMenuItem(value: '1', child: Text('Ya')),
                    ],
                    onChanged: onBuktiChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

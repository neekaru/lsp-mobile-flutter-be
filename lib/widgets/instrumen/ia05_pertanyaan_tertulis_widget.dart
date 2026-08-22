import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';

class IA05PertanyaanTertulisWidget extends StatefulWidget {
  final IA05Data data;
  final VoidCallback? onSaved;

  const IA05PertanyaanTertulisWidget({
    super.key,
    required this.data,
    this.onSaved,
  });

  @override
  State<IA05PertanyaanTertulisWidget> createState() => _IA05PertanyaanTertulisWidgetState();
}

class _IA05PertanyaanTertulisWidgetState extends State<IA05PertanyaanTertulisWidget> {
  late TextEditingController _catatanCtrl;

  @override
  void initState() {
    super.initState();
    _catatanCtrl = TextEditingController(text: widget.data.catatanAsesor);
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _markAllYa() {
    setState(() {
      for (var item in widget.data.items) {
        item.pencapaian = 'Ya';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua soal tertulis ditandai Tercapai (Ya).'),
        backgroundColor: Color(0xFF16A34A),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _autoEvaluate() {
    setState(() {
      for (var item in widget.data.items) {
        if (item.jawabanAsesi.isNotEmpty) {
          final isCorrect = item.jawabanAsesi.trim().toLowerCase().startsWith(
                item.kunciText.trim().toLowerCase().substring(0, 1),
              );
          item.pencapaian = isCorrect ? 'Ya' : 'Tidak';
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pencapaian otomatis dievaluasi berdasarkan kunci jawaban.'),
        backgroundColor: Color(0xFF2563EB),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSoal = widget.data.items.length;
    final totalBenar = widget.data.totalBenar;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Green Title Banner (FR.IA.05) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF84CC16), // Light Green / Lime BNSP banner
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: const Color(0xFF65A30D)),
            ),
            child: const Text(
              'FR.IA.05. Pertanyaan Tertulis',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // ── Quick Actions Bar: Info & Tombol Cepat ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                left: BorderSide(color: Color(0xFFCBD5E1)),
                right: BorderSide(color: Color(0xFFCBD5E1)),
                bottom: BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.file_question, size: 16, color: Color(0xFF65A30D)),
                    const SizedBox(width: 6),
                    Text(
                      'Total $totalSoal Soal Tertulis (Benar: $totalBenar)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _autoEvaluate,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: const Color(0xFFEFF6FF),
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(LucideIcons.sparkles, size: 13),
                      label: const Text(
                        'Auto Cek',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      onPressed: _markAllYa,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(LucideIcons.check_check, size: 13),
                      label: const Text(
                        'Pilih Semua Ya',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 2. Table Soal Pilihan Ganda, Jawaban & Pencapaian ──
          _buildSoalTable(),

          // ── 3. Catatan & Feedback Asesor Box ──
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Hasil Asesmen Tertulis :',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _catatanCtrl,
                  maxLines: 3,
                  onChanged: (val) {
                    widget.data.catatanAsesor = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Tuliskan catatan atau rekomendasi tindak lanjut tes tertulis (opsional)...',
                    hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── 4. Bottom Action Save Button ──
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.data.catatanAsesor = _catatanCtrl.text.trim();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pertanyaan tertulis FR.IA.05 berhasil disimpan (UI Mode).'),
                    backgroundColor: Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                widget.onSaved?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text(
                'Simpan Form FR.IA.05',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Tabel Soal, Jawaban Asesi, dan Kolom Pencapaian
  Widget _buildSoalTable() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFCBD5E1)),
          right: BorderSide(color: Color(0xFFCBD5E1)),
          bottom: BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                const Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Pertanyaan',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                const Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Jawaban',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                SizedBox(
                  width: 90,
                  child: Column(
                    children: [
                      const Text(
                        'Pencapaian',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Ya',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Tidak',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),

          // Table Rows
          ...widget.data.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isLast = idx == widget.data.items.length - 1;

            return Column(
              children: [
                Container(
                  color: idx.isEven ? Colors.white : const Color(0xFFFAFAFA),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // No
                        SizedBox(
                          width: 38,
                          child: Text(
                            '${item.no}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),

                        // Pertanyaan & Options
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.pertanyaan,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Options A, B, C, D
                                ...item.options.map((opt) {
                                  final isKunci = opt.isKunci;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Text(
                                      '${opt.kode}. ${opt.teks}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isKunci ? FontWeight.bold : FontWeight.w500,
                                        color: isKunci ? const Color(0xFF16A34A) : const Color(0xFF475569),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),

                        // Jawaban Asesi
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: item.jawabanAsesi.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.jawabanAsesi,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Telah Dijawab',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    '-',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),

                        // Ya & Tidak Radio Selectors
                        SizedBox(
                          width: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ya
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      item.pencapaian = 'Ya';
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: item.pencapaian == 'Ya'
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFF94A3B8),
                                          width: item.pencapaian == 'Ya' ? 5 : 1.5,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Tidak
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      item.pencapaian = 'Tidak';
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: item.pencapaian == 'Tidak'
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF94A3B8),
                                          width: item.pencapaian == 'Tidak' ? 5 : 1.5,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

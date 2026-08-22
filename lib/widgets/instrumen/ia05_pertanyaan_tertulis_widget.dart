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
    final totalBenar = widget.data.items.where((i) => i.pencapaian == 'Ya').length;
    final totalSalah = widget.data.items.where((i) => i.pencapaian == 'Tidak').length;
    final persentase = totalSoal > 0 ? ((totalBenar / totalSoal) * 100).toStringAsFixed(0) : '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Card Header & Quick Actions ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.file_text, size: 18, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Text(
                          'FR.IA.05 Pertanyaan Tertulis',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Skor: $persentase%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Stats Chips
                Row(
                  children: [
                    _buildBadge('Benar: $totalBenar', const Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    _buildBadge('Salah: $totalSalah', const Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    _buildBadge('Total: $totalSoal Soal', const Color(0xFF64748B)),
                  ],
                ),
                const SizedBox(height: 10),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _autoEvaluate,
                        icon: const Icon(LucideIcons.sparkles, size: 14),
                        label: const Text('Evaluasi Kunci', style: TextStyle(fontSize: 11.5)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _markAllYa,
                        icon: const Icon(LucideIcons.check_check, size: 14),
                        label: const Text('Pilih Semua Ya', style: TextStyle(fontSize: 11.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 2. List of Soal as Cards ──
          ...widget.data.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return _buildSoalCard(idx + 1, item);
          }),

          const SizedBox(height: 14),

          // ── 3. Card Catatan Asesor ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.message_square, size: 17, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text(
                      'Catatan Evaluasi Asesor',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _catatanCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'Tuliskan catatan hasil tes tertulis asesi jika ada...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(12),
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
            ),
          ),
          const SizedBox(height: 18),

          // ── 4. Bottom Save Button ──
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.data.catatanAsesor = _catatanCtrl.text.trim();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hasil pertanyaan tertulis FR.IA.05 berhasil disimpan.'),
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
                'Simpan Hasil Tes Tertulis (IA.05)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSoalCard(int no, IA05SoalItem item) {
    final isYa = item.pencapaian == 'Ya';
    final isTidak = item.pencapaian == 'Tidak';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isYa
              ? const Color(0xFFBBF7D0)
              : isTidak
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
          width: isYa || isTidak ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: No & Pertanyaan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isYa
                      ? const Color(0xFF16A34A)
                      : isTidak
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF64748B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$no',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.pertanyaan,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Options List (Pilihan Ganda)
          if (item.options.isNotEmpty) ...[
            ...item.options.map((opt) {
              final isChosen = item.jawabanAsesi.trim().toLowerCase().startsWith(opt.kode.toLowerCase()) ||
                  item.jawabanAsesi.trim().toLowerCase() == opt.kode.toLowerCase();
              final isKey = opt.isKunci || item.kunciText.trim().toLowerCase().startsWith(opt.kode.toLowerCase());

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isChosen
                      ? (isKey ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2))
                      : (isKey ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isChosen
                        ? (isKey ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
                        : (isKey ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isChosen
                            ? (isKey ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
                            : const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        opt.kode.toUpperCase(),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opt.teks,
                        style: TextStyle(
                          fontSize: 12,
                          color: isChosen ? const Color(0xFF0F172A) : const Color(0xFF334155),
                          fontWeight: isChosen ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isChosen) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isKey ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pilihan Asesi',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                    if (isKey && !isChosen) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Kunci',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ] else if (item.jawabanAsesi.isNotEmpty) ...[
            // Jawaban Esai
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jawaban Esai Asesi:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.jawabanAsesi,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Interactive Segmented Buttons (Ya / Tidak)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      item.pencapaian = 'Ya';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isYa ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isYa ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        width: isYa ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isYa ? LucideIcons.circle_check : LucideIcons.circle,
                          size: 16,
                          color: isYa ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Benar (Ya)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isYa ? FontWeight.bold : FontWeight.w500,
                            color: isYa ? const Color(0xFF15803D) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      item.pencapaian = 'Tidak';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isTidak ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isTidak ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                        width: isTidak ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isTidak ? LucideIcons.circle_x : LucideIcons.circle,
                          size: 16,
                          color: isTidak ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Salah (Tidak)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isTidak ? FontWeight.bold : FontWeight.w500,
                            color: isTidak ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';

class IA03PertanyaanLisanWidget extends StatefulWidget {
  final IA03Data data;
  final VoidCallback? onSaved;

  const IA03PertanyaanLisanWidget({
    super.key,
    required this.data,
    this.onSaved,
  });

  @override
  State<IA03PertanyaanLisanWidget> createState() => _IA03PertanyaanLisanWidgetState();
}

class _IA03PertanyaanLisanWidgetState extends State<IA03PertanyaanLisanWidget> {
  late TextEditingController _umpanBalikCtrl;

  @override
  void initState() {
    super.initState();
    _umpanBalikCtrl = TextEditingController(text: widget.data.umpanBalikUntukAsesi);
  }

  @override
  void dispose() {
    _umpanBalikCtrl.dispose();
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
        content: Text('Semua pertanyaan lisan ditandai Tercapai (Ya).'),
        backgroundColor: Color(0xFF16A34A),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.data.items.length;
    final totalYa = widget.data.items.where((i) => i.pencapaian == 'Ya').length;
    final totalTidak = widget.data.items.where((i) => i.pencapaian == 'Tidak').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Card Header & Quick Action ──
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
                        Icon(LucideIcons.message_circle, size: 18, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Text(
                          'FR.IA.03 Pertanyaan Lisan',
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
                        'Total: $total Soal',
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

                // Stats & Quick Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildBadge('Ya: $totalYa', const Color(0xFF16A34A)),
                        const SizedBox(width: 6),
                        _buildBadge('Tidak: $totalTidak', const Color(0xFFDC2626)),
                      ],
                    ),
                    InkWell(
                      onTap: _markAllYa,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.check_check, size: 14, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              'Pilih Semua Ya',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 2. List of Pertanyaan as Cards ──
          ...widget.data.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return _buildPertanyaanCard(idx + 1, item);
          }),

          const SizedBox(height: 14),

          // ── 3. Card Umpan Balik Asesi ──
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
                      'Umpan Balik untuk Asesi',
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
                  controller: _umpanBalikCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'Tuliskan umpan balik atau tanggapan untuk asesi terkait pertanyaan pendukung observasi...',
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
                widget.data.umpanBalikUntukAsesi = _umpanBalikCtrl.text.trim();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pertanyaan pendukung observasi FR.IA.03 berhasil disimpan.'),
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
                'Simpan Pertanyaan Lisan (IA.03)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPertanyaanCard(int no, IA03PertanyaanItem item) {
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

          // Kunci Jawaban / Jawaban yang Diharapkan
          if (item.kunciJawaban.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kunci Jawaban / Jawaban yang Diharapkan:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.kunciJawaban,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Tanggapan Asesi (jika ada)
          if (item.tanggapanAsesi.isNotEmpty) ...[
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
                    'Jawaban / Tanggapan Asesi:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.tanggapanAsesi,
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
                          'Tercapai (Ya)',
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
                          'Belum (Tidak)',
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

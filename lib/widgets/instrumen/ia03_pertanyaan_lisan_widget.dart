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
        content: Text('Semua pertanyaan ditandai Tercapai (Ya).'),
        backgroundColor: Color(0xFF16A34A),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Yellow Title Banner (FR.IA.03) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE047), // Yellow BNSP banner
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'FR.IA.03. Pertanyaan Untuk Mendukung Observasi',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: 0.2,
              ),
            ),
          ),

          // ── Quick Action: Pilih Semua Ya ──
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
                    const Icon(LucideIcons.message_circle, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      'Total ${widget.data.items.length} Pertanyaan Lisan',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _markAllYa,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(LucideIcons.check_check, size: 14),
                  label: const Text(
                    'Pilih Semua Ya',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Table Pertanyaan & Pencapaian ──
          _buildPertanyaanTable(),

          // ── 3. Umpan Balik Untuk Asesi Box ──
          _buildUmpanBalikBox(),

          const SizedBox(height: 18),

          // ── 4. Bottom Action Save Button ──
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.data.umpanBalikUntukAsesi = _umpanBalikCtrl.text.trim();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pertanyaan pendukung observasi FR.IA.03 berhasil disimpan (UI Mode).'),
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
                'Simpan Form FR.IA.03',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Tabel Pertanyaan dan Kolom Pencapaian (Ya / Tidak)
  Widget _buildPertanyaanTable() {
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
                  width: 42,
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Pertanyaan',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                SizedBox(
                  width: 100,
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
                          width: 42,
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

                        // Pertanyaan & Kunci Jawaban
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.pertanyaan,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                    height: 1.4,
                                  ),
                                ),
                                if (item.kunciJawaban.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Panduan Jawaban / Tanggapan yang Diharapkan:',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.kunciJawaban,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF475569),
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),

                        // Ya & Tidak Radio Selectors
                        SizedBox(
                          width: 100,
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
          }),
        ],
      ),
    );
  }

  /// Baris Bawah: Umpan Balik Untuk Asesi Box
  Widget _buildUmpanBalikBox() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: Color(0xFFCBD5E1)),
          right: BorderSide(color: Color(0xFFCBD5E1)),
          bottom: BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Label
            Container(
              width: 145,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF8FAFC),
              alignment: Alignment.topLeft,
              child: const Text(
                'Umpan Balik Untuk Asesi:',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
            // Right Textarea
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _umpanBalikCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan catatan dan umpan balik atas respon pertanyaan lisan asesi...',
                    hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.all(4),
                  ),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

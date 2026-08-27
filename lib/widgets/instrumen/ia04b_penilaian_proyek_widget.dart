import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';

class IA04BPenilaianProyekWidget extends StatefulWidget {
  final IA04BData? data;
  final Function(IA04BData updatedData) onSave;

  const IA04BPenilaianProyekWidget({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  State<IA04BPenilaianProyekWidget> createState() =>
      _IA04BPenilaianProyekWidgetState();
}

class _IA04BPenilaianProyekWidgetState extends State<IA04BPenilaianProyekWidget> {
  late List<IA04BItem> _items;
  late String _isKompeten;
  late TextEditingController _catatanController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _items = widget.data?.items ?? [];
    _isKompeten = (widget.data?.isDitKompeten.isNotEmpty == true &&
            widget.data?.isDitKompeten != '0')
        ? (widget.data?.isDitKompeten ?? 'K')
        : 'K';
    _catatanController =
        TextEditingController(text: widget.data?.catatanDit ?? '');
  }

  @override
  void didUpdateWidget(covariant IA04BPenilaianProyekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initData();
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  String _cleanHtml(String htmlString) {
    if (htmlString.isEmpty) return '';
    String text = htmlString;
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</tr>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</td>', caseSensitive: false), '  ');
    text = text.replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  void _setAllPencapaian(String pencapaian) {
    setState(() {
      for (var item in _items) {
        item.pencapaian = pencapaian;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    if (d == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Data FR.IA.04B belum tersedia untuk skema ini.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    final totalItems = _items.length;
    final totalTercapai = _items.where((i) => i.pencapaian == 'Ya').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF84CC16).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF84CC16)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.clipboard_list, color: Color(0xFF4D7C0F), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FR.IA.04B. PENILAIAN PROYEK SINGKAT ATAU KEGIATAN TERSTRUKTUR LAINNYA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F6212),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Summary & Quick Check Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pencapaian Rubrik:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalTercapai / $totalItems Tercapai',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _setAllPencapaian('Ya'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: const Color(0xFFDCFCE7),
                        foregroundColor: const Color(0xFF15803D),
                      ),
                      child: const Text('Semua Ya', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () => _setAllPencapaian('Tidak'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: const Color(0xFFB91C1C),
                      ),
                      child: const Text('Semua Tidak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Items List
          ..._items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return _buildRubricCard(idx, item);
          }),

          const SizedBox(height: 14),

          // Keputusan Asesor
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keputusan Asesor Proyek / DIT:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 110,
                      child: Text('Kompeten ?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                    const Text(': ', style: TextStyle(fontSize: 12.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButton<String>(
                        value: _isKompeten == 'BK' ? 'BK' : 'K',
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'K',
                            child: Text('K (Kompeten)', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem(
                            value: 'BK',
                            child: Text('BK (Belum Kompeten)', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _isKompeten = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Catatan / Bukti Tambahan:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan jika diperlukan bukti tambahan atau rekomendasi...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            final updated = IA04BData(
                              asesiId: d.asesiId,
                              namaAsesi: d.namaAsesi,
                              items: _items,
                              isDitKompeten: _isKompeten,
                              catatanDit: _catatanController.text,
                              umpanBalikDit: d.umpanBalikDit,
                            );
                            await widget.onSave(updated);
                            if (mounted) setState(() => _isSaving = false);
                          },
                    icon: _isSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(LucideIcons.save, size: 16),
                    label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Penilaian Proyek (FR.IA.04B)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRubricCard(int index, IA04BItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lingkup Penyajian Proyek
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.lingkupProyek.isNotEmpty ? _cleanHtml(item.lingkupProyek) : 'Lingkup Penyajian Proyek',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Pertanyaan
          if (item.pertanyaan.isNotEmpty) ...[
            const Text(
              'Pertanyaan Aspek Penilaian:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 3),
            Text(
              _cleanHtml(item.pertanyaan),
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.35),
            ),
            const SizedBox(height: 8),
          ],

          // Tanggapan
          if (item.tanggapan.isNotEmpty) ...[
            const Text(
              'Tanggapan / Catatan Asesi:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                _cleanHtml(item.tanggapan),
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Kesesuaian Standar KUK
          if (item.kesesuaianStandar.isNotEmpty) ...[
            Row(
              children: [
                const Icon(LucideIcons.tag, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Kesesuaian Standar: ${item.kesesuaianStandar}',
                    style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Radio Pencapaian: Ya / Tidak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pencapaian Standar:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
              Row(
                children: [
                  _buildPencapaianButton(
                    label: 'Ya',
                    isSelected: item.pencapaian == 'Ya',
                    activeColor: const Color(0xFF16A34A),
                    onTap: () => setState(() => item.pencapaian = 'Ya'),
                  ),
                  const SizedBox(width: 8),
                  _buildPencapaianButton(
                    label: 'Tidak',
                    isSelected: item.pencapaian == 'Tidak',
                    activeColor: const Color(0xFFDC2626),
                    onTap: () => setState(() => item.pencapaian = 'Tidak'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPencapaianButton({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

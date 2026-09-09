import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';
import 'ia01_langkah_card.dart';
import 'ia01_keputusan_cards.dart';

class IA01ObservasiWidget extends StatefulWidget {
  final List<IA01UnitKompetensi> units;
  final VoidCallback? onFinished;
  final Function(
    String rekomendasi,
    String catatan, {
    String? buktiTambahanPmo,
    String? buktiTambahan,
    String? alasanPmo,
  })? onFinishedWithRekom;

  const IA01ObservasiWidget({
    super.key,
    required this.units,
    this.onFinished,
    this.onFinishedWithRekom,
  });

  @override
  State<IA01ObservasiWidget> createState() => _IA01ObservasiWidgetState();
}

class _IA01ObservasiWidgetState extends State<IA01ObservasiWidget> {
  int _selectedUnitIndex = 0;
  String _rekomendasiKeseluruhan = 'K';
  String _buktiTambahanPmo = '0'; // 0 = Tidak, 1 = Ya
  String _buktiTambahan = '0'; // 0 = Tidak, 1 = Ya
  final TextEditingController _catatanKeseluruhanController = TextEditingController();
  final TextEditingController _alasanPmoController =
      TextEditingController(text: 'Sudah terpenuhi saat TPD');
  final Map<int, TextEditingController> _catatanControllers = {};
  final Map<int, TextEditingController> _alasanPertanyaanControllers = {};
  final Map<int, TextEditingController> _alasanBuktiControllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.units.length; i++) {
      _catatanControllers[i] = TextEditingController(text: widget.units[i].catatanUnit);
      _alasanPertanyaanControllers[i] =
          TextEditingController(text: widget.units[i].alasanPertanyaanPendukung);
      _alasanBuktiControllers[i] =
          TextEditingController(text: widget.units[i].alasanBuktiTambahan);
    }
  }

  @override
  void dispose() {
    _catatanKeseluruhanController.dispose();
    for (var controller in _catatanControllers.values) {
      controller.dispose();
    }
    for (var controller in _alasanPertanyaanControllers.values) {
      controller.dispose();
    }
    for (var controller in _alasanBuktiControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _markAllK(IA01UnitKompetensi unit) {
    setState(() {
      for (var item in unit.items) {
        item.penilaian = 'K';
      }
      unit.rekomendasiUnit = 'K';
      _rekomendasiKeseluruhan = 'K';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Semua langkah kerja Unit ${unit.noUnit} ditandai Kompeten (K)'),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.units.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Tidak ada unit kompetensi untuk FR.IA.01.'),
        ),
      );
    }

    final currentUnit = widget.units[_selectedUnitIndex];
    final totalSteps = currentUnit.items.length;
    final totalK = currentUnit.items.where((i) => i.penilaian == 'K').length;
    final totalBK = currentUnit.items.where((i) => i.penilaian == 'BK').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Unit Selector Chips (Jika > 1 unit) ──
          if (widget.units.length > 1) ...[
            _buildUnitSelector(),
            const SizedBox(height: 12),
          ],

          // ── 2. Card Header Unit Kompetensi ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Unit Kompetensi No. ${currentUnit.noUnit}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    Text(
                      currentUnit.kodeUnit,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentUnit.judulUnit,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Quick Action Checklist All & Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildBadge('K: $totalK', const Color(0xFF16A34A)),
                        const SizedBox(width: 6),
                        _buildBadge('BK: $totalBK', const Color(0xFFDC2626)),
                        const SizedBox(width: 6),
                        _buildBadge('Total: $totalSteps', const Color(0xFF64748B)),
                      ],
                    ),
                    InkWell(
                      onTap: () => _markAllK(currentUnit),
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
                              'Pilih Semua K',
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

          // ── 3. List of Langkah Kerja as Cards ──
          ...currentUnit.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return IA01LangkahCard(
              no: idx + 1,
              item: item,
              onMarkK: () => setState(() => item.penilaian = 'K'),
              onMarkBK: () => setState(() => item.penilaian = 'BK'),
            );
          }),

          const SizedBox(height: 14),

          // ── 4. Card untuk semua unit (non-last) ──
          // ──    unit non-terakhir: tampilkan catatan saja ──
          if (_selectedUnitIndex != widget.units.length - 1) ...[
            IA01CatatanOnlyCard(
              currentUnit: currentUnit,
              catatanCtrl: _catatanControllers[_selectedUnitIndex] ?? TextEditingController(),
            ),
            const SizedBox(height: 14),
          ],
          
          // ── 5. Card Keputusan & Rekomendasi (HANYA unit terakhir) ──
          if (_selectedUnitIndex == widget.units.length - 1) ...[
            IA01KeputusanObservasiCard(
              currentUnit: currentUnit,
              alasanPertanyaanCtrl: _alasanPertanyaanControllers[_selectedUnitIndex] ?? TextEditingController(),
              alasanBuktiCtrl: _alasanBuktiControllers[_selectedUnitIndex] ?? TextEditingController(),
              catatanCtrl: _catatanControllers[_selectedUnitIndex] ?? TextEditingController(),
              onRekomChanged: (val) => setState(() => currentUnit.rekomendasiUnit = val),
            ),
            const SizedBox(height: 14),
          ],

          // ── 6. Card Rekomendasi Keseluruhan (Tampil di semua / unit terakhir) ──
          IA01RekomendasiKeseluruhanCard(
            rekomendasi: _rekomendasiKeseluruhan,
            catatanController: _catatanKeseluruhanController,
            buktiTambahanPmo: _buktiTambahanPmo,
            buktiTambahan: _buktiTambahan,
            alasanPmoController: _alasanPmoController,
            onRekomChanged: (v) => setState(() => _rekomendasiKeseluruhan = v),
            onPmoChanged: (v) {
              if (v != null) setState(() => _buktiTambahanPmo = v);
            },
            onBuktiChanged: (v) {
              if (v != null) setState(() => _buktiTambahan = v);
            },
          ),

          const SizedBox(height: 18),

          // ── 7. Bottom Navigation & Action Buttons ──
          _buildBottomActionBar(currentUnit),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.units.length, (index) {
          final unit = widget.units[index];
          final isSelected = index == _selectedUnitIndex;
          final isDone = unit.isSemuaDinilai;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _selectedUnitIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Unit ${unit.noUnit}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                    if (isDone) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: isSelected ? Colors.white : const Color(0xFF16A34A),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomActionBar(IA01UnitKompetensi currentUnit) {
    final hasNext = _selectedUnitIndex < widget.units.length - 1;
    final hasPrev = _selectedUnitIndex > 0;

    return Row(
      children: [
        if (hasPrev) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedUnitIndex--;
                });
              },
              icon: const Icon(LucideIcons.arrow_left, size: 16),
              label: const Text('Unit Sebelumnya', style: TextStyle(fontSize: 12.5)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              if (hasNext) {
                setState(() {
                  _selectedUnitIndex++;
                });
              } else {
                if (widget.onFinishedWithRekom != null) {
                  widget.onFinishedWithRekom!(
                    _rekomendasiKeseluruhan,
                    _catatanKeseluruhanController.text,
                    buktiTambahanPmo: _buktiTambahanPmo,
                    buktiTambahan: _buktiTambahan,
                    alasanPmo: _alasanPmoController.text,
                  );
                } else {
                  widget.onFinished?.call();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: hasNext ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            icon: Icon(hasNext ? LucideIcons.arrow_right : LucideIcons.save, size: 16),
            label: Text(
              hasNext ? 'Lanjut Unit Berikutnya' : 'Simpan Ceklis Observasi (IA.01)',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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

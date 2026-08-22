import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';

class IA01ObservasiWidget extends StatefulWidget {
  final List<IA01UnitKompetensi> units;
  final VoidCallback? onFinished;

  const IA01ObservasiWidget({
    super.key,
    required this.units,
    this.onFinished,
  });

  @override
  State<IA01ObservasiWidget> createState() => _IA01ObservasiWidgetState();
}

class _IA01ObservasiWidgetState extends State<IA01ObservasiWidget> {
  int _selectedUnitIndex = 0;
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
            return _buildLangkahCard(idx + 1, item);
          }),

          const SizedBox(height: 14),

          // ── 4. Card Keputusan Observasi Unit (hanya unit terakhir) ──
          // ──    unit non-terakhir: tampilkan catatan saja ──
          if (_selectedUnitIndex == widget.units.length - 1)
            _buildKeputusanObservasiCard(currentUnit)
          else
            _buildCatatanOnlyCard(currentUnit),

          const SizedBox(height: 18),

          // ── 5. Bottom Navigation & Action Buttons ──
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

  Widget _buildLangkahCard(int no, IA01Item item) {
    final isK = item.penilaian == 'K';
    final isBK = item.penilaian == 'BK';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isK
              ? const Color(0xFFBBF7D0)
              : isBK
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
          width: isK || isBK ? 1.5 : 1.0,
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
          // Header: Langkah No & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isK
                      ? const Color(0xFF16A34A)
                      : isBK
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
                  item.langkahKerja,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Poin Observasi (KUK)
          if (item.poinObservasi.isNotEmpty) ...[
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
                    'Poin yang diobservasi (KUK):',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...item.poinObservasi.map((poin) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              poin,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF334155),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Interactive K / BK Mobile Segmented Buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      item.penilaian = 'K';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isK ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isK ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        width: isK ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isK ? LucideIcons.circle_check : LucideIcons.circle,
                          size: 16,
                          color: isK ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kompeten (K)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isK ? FontWeight.bold : FontWeight.w500,
                            color: isK ? const Color(0xFF15803D) : const Color(0xFF64748B),
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
                      item.penilaian = 'BK';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isBK ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBK ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                        width: isBK ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isBK ? LucideIcons.circle_x : LucideIcons.circle,
                          size: 16,
                          color: isBK ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Belum Kompeten (BK)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isBK ? FontWeight.bold : FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildKeputusanObservasiCard(IA01UnitKompetensi currentUnit) {
    final alasanPertanyaanCtrl =
        _alasanPertanyaanControllers[_selectedUnitIndex] ?? TextEditingController();
    final alasanBuktiCtrl =
        _alasanBuktiControllers[_selectedUnitIndex] ?? TextEditingController();
    final catatanCtrl =
        _catatanControllers[_selectedUnitIndex] ?? TextEditingController();

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
                      onChanged: (val) {
                        setState(() {
                          currentUnit.rekomendasiUnit = val;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Alasan Pertanyaan Pendukung (jika BK)
          if (isBK) ...[
            _buildInputField(
              label: 'Alasan Pertanyaan Pendukung Observasi (IA.03)',
              controller: alasanPertanyaanCtrl,
              hint: 'Tuliskan alasan mengapa diperlukan pertanyaan lisan tambahan...',
              onChanged: (v) => currentUnit.alasanPertanyaanPendukung = v,
            ),
            const SizedBox(height: 10),
            _buildInputField(
              label: 'Alasan Bukti Tambahan (IA.04)',
              controller: alasanBuktiCtrl,
              hint: 'Tuliskan alasan jika diperlukan bukti verifikasi pihak ketiga...',
              onChanged: (v) => currentUnit.alasanBuktiTambahan = v,
            ),
            const SizedBox(height: 10),
          ],

          _buildInputField(
            label: 'Catatan Asesor untuk Unit Ini',
            controller: catatanCtrl,
            hint: 'Catatan pengamatan atau unjuk kerja asesi...',
            onChanged: (v) => currentUnit.catatanUnit = v,
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanOnlyCard(IA01UnitKompetensi currentUnit) {
    final catatanCtrl =
        _catatanControllers[_selectedUnitIndex] ?? TextEditingController();

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

          _buildInputField(
            label: 'Catatan Asesor untuk Unit Ini',
            controller: catatanCtrl,
            hint: 'Catatan pengamatan atau unjuk kerja asesi...',
            onChanged: (v) => currentUnit.catatanUnit = v,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
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
                widget.onFinished?.call();
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

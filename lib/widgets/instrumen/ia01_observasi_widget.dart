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
  final Map<int, bool> _checklistAllStates = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.units.length; i++) {
      _catatanControllers[i] = TextEditingController(text: widget.units[i].catatanUnit);
      _alasanPertanyaanControllers[i] =
          TextEditingController(text: widget.units[i].alasanPertanyaanPendukung);
      _alasanBuktiControllers[i] =
          TextEditingController(text: widget.units[i].alasanBuktiTambahan);
      _checklistAllStates[i] = widget.units[i].isSemuaDinilai && !widget.units[i].adaBK;
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
    final catatanCtrl = _catatanControllers[_selectedUnitIndex] ?? TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Top Unit Selector Bar (Jika lebih dari 1 unit) ──
          if (widget.units.length > 1) ...[
            _buildUnitSelector(),
            const SizedBox(height: 12),
          ],

          // ── 2. Yellow Header Title Bar (BNSP Standard) ──
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
              'FR.IA.01. CL - CEKLIS OBSERVASI AKTIVITAS DI TEMPAT KERJA ATAU TEMPAT KERJA SIMULASI',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: 0.2,
              ),
            ),
          ),

          // ── 3. Unit Info Table Header ──
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Unit No Header
                  Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFFF1F5F9),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Unit Kompetensi No.${currentUnit.noUnit}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                  // Kode & Judul Unit
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 75,
                                child: Text(
                                  'Kode Unit',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const Text(' :  ', style: TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                              Expanded(
                                child: Text(
                                  currentUnit.kodeUnit,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 75,
                                child: Text(
                                  'Judul Unit',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const Text(' :  ', style: TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                              Expanded(
                                child: Text(
                                  currentUnit.judulUnit,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Quick Action: Tandai Semua K ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.check_circle_2, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      'Observasi Unit ${currentUnit.noUnit} (${currentUnit.items.length} Langkah)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _markAllK(currentUnit),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(LucideIcons.check_check, size: 14),
                  label: const Text(
                    'Pilih Semua K',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // ── 4. Observasi Table ──
          _buildObservasiTable(currentUnit),

          // ── 5. Keputusan & Tindak Lanjut Observasi Unit Box ──
          _buildKeputusanObservasiCard(currentUnit),

          const SizedBox(height: 18),

          // ── 6. Bottom Navigation & Action Buttons ──
          _buildBottomActionBar(currentUnit),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Unit Tab Selector Bar
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
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x142563EB),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
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

  /// Table Observasi Langkah Kerja
  Widget _buildObservasiTable(IA01UnitKompetensi unit) {
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
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Langkah Kerja',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                const Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Poin yang di observasi',
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
                        'Kompeten',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'K',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'BK',
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
          ...unit.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isLast = idx == unit.items.length - 1;

            return Column(
              children: [
                Container(
                  color: idx.isEven ? Colors.white : const Color(0xFFFAFAFA),
                  padding: const EdgeInsets.symmetric(vertical: 8),
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

                        // Langkah Kerja
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              item.langkahKerja,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),

                        // Poin Observasi (Bullet Points)
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: item.poinObservasi.map((poin) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '•  ',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          poin,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF334155),
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),

                        // K & BK Radio Selectors
                        SizedBox(
                          width: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // K (Kompeten)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      item.penilaian = 'K';
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
                                          color: item.penilaian == 'K'
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFF94A3B8),
                                          width: item.penilaian == 'K' ? 5 : 1.5,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // BK (Belum Kompeten)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      item.penilaian = 'BK';
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
                                          color: item.penilaian == 'BK'
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF94A3B8),
                                          width: item.penilaian == 'BK' ? 5 : 1.5,
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

  /// Card Keputusan Observasi, Catatan, dan Pertanyaan/Bukti Pendukung
  Widget _buildKeputusanObservasiCard(IA01UnitKompetensi currentUnit) {
    final alasanPertanyaanCtrl =
        _alasanPertanyaanControllers[_selectedUnitIndex] ?? TextEditingController();
    final alasanBuktiCtrl =
        _alasanBuktiControllers[_selectedUnitIndex] ?? TextEditingController();
    final catatanCtrl =
        _catatanControllers[_selectedUnitIndex] ?? TextEditingController();
    final isChecklistAll = _checklistAllStates[_selectedUnitIndex] ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Row: Kompeten ?: [-Pilih-]  [ ] Checklist All
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 95,
                child: Text(
                  'Kompeten ? :',
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
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: currentUnit.rekomendasiUnit,
                      hint: const Text(
                        '-Pilih-',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Kompeten',
                          child: Text('Kompeten', style: TextStyle(color: Color(0xFF16A34A))),
                        ),
                        DropdownMenuItem(
                          value: 'Belum Kompeten',
                          child: Text('Belum Kompeten', style: TextStyle(color: Color(0xFFDC2626))),
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
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final newVal = !isChecklistAll;
                  setState(() {
                    _checklistAllStates[_selectedUnitIndex] = newVal;
                    if (newVal) {
                      for (var item in currentUnit.items) {
                        item.penilaian = 'K';
                      }
                      currentUnit.rekomendasiUnit = 'Kompeten';
                    }
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecklistAll,
                      visualDensity: VisualDensity.compact,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) {
                        final newVal = val ?? false;
                        setState(() {
                          _checklistAllStates[_selectedUnitIndex] = newVal;
                          if (newVal) {
                            for (var item in currentUnit.items) {
                              item.penilaian = 'K';
                            }
                            currentUnit.rekomendasiUnit = 'Kompeten';
                          }
                        });
                      },
                    ),
                    const Text(
                      'Checklist All',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Row: Catatan :
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 95,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Catatan :',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: catatanCtrl,
                  maxLines: 3,
                  onChanged: (val) {
                    currentUnit.catatanUnit = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Tuliskan catatan terhadap langkah kerja pada unit kompetensi...',
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
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Row: Diperlukan Pertanyaan Pendukung: [Tidak / Ya]  Sudah terpenuhi saat TPD
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 140,
                child: Text(
                  'Diperlukan Pertanyaan Pendukung :',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                width: 85,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: currentUnit.perluPertanyaanPendukung,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Tidak', child: Text('Tidak')),
                      DropdownMenuItem(value: 'Ya', child: Text('Ya')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          currentUnit.perluPertanyaanPendukung = val;
                          if (val == 'Tidak' && alasanPertanyaanCtrl.text.isEmpty) {
                            alasanPertanyaanCtrl.text = 'Sudah terpenuhi saat TPD';
                            currentUnit.alasanPertanyaanPendukung = 'Sudah terpenuhi saat TPD';
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextFormField(
                    controller: alasanPertanyaanCtrl,
                    onChanged: (val) {
                      currentUnit.alasanPertanyaanPendukung = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'Keterangan...',
                      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Row: Diperlukan Bukti Tambahan: [Tidak / Ya]
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 140,
                child: Text(
                  'Diperlukan Bukti Tambahan :',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                width: 85,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: currentUnit.perluBuktiTambahan,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Tidak', child: Text('Tidak')),
                      DropdownMenuItem(value: 'Ya', child: Text('Ya')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          currentUnit.perluBuktiTambahan = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              if (currentUnit.perluBuktiTambahan == 'Ya') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextFormField(
                      controller: alasanBuktiCtrl,
                      onChanged: (val) {
                        currentUnit.alasanBuktiTambahan = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Tuliskan bukti tambahan...',
                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation and Action Buttons
  Widget _buildBottomActionBar(IA01UnitKompetensi currentUnit) {
    final isFirstUnit = _selectedUnitIndex == 0;
    final isLastUnit = _selectedUnitIndex == widget.units.length - 1;

    return Column(
      children: [
        Row(
          children: [
            // Previous Unit Button
            if (!isFirstUnit)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedUnitIndex--;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(LucideIcons.arrow_left, size: 16),
                  label: const Text('Unit Sebelumnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            if (!isFirstUnit && !isLastUnit) const SizedBox(width: 10),
            // Next Unit Button
            if (!isLastUnit)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedUnitIndex++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(LucideIcons.arrow_right, size: 16),
                  label: const Text('Unit Selanjutnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Simpan Observasi Draft Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ceklis observasi FR.IA.01 berhasil disimpan sementara (UI Mode).'),
                  backgroundColor: Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              widget.onFinished?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.save, size: 16),
            label: const Text(
              'Simpan Ceklis Observasi FR.IA.01',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

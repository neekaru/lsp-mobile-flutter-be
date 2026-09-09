import 'package:material_ui/material_ui.dart';
import '../../../services/marketing/places_service.dart';

class MarketingFilterValues {
  final bool filterRetail;
  final int radiusKm;
  final Set<String> blacklist;
  final Set<String> allowedCategories;
  const MarketingFilterValues({
    required this.filterRetail,
    required this.radiusKm,
    required this.blacklist,
    required this.allowedCategories,
  });
}

Future<void> showMarketingFilterSheet({
  required BuildContext context,
  required bool filterRetail,
  required int radiusKm,
  required Set<String> blacklist,
  required Set<String> allowedCategories,
  required void Function(MarketingFilterValues) onApply,
}) {
  const defaultCategories = [
    'SMK',
    'Kampus',
    'BLK',
    'LPK',
    'Dinas Pemda',
    'Perusahaan Swasta',
  ];
  final newKeywordController = TextEditingController();
  bool tempFilterRetail = filterRetail;
  int tempRadiusKm = radiusKm;
  final tempBlacklist = List<String>.from(blacklist);
  final tempAllowed = List<String>.from(allowedCategories);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune_rounded,
                                color: Color(0xFF2563EB), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Pengaturan Filter & Blacklist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempFilterRetail = true;
                              tempRadiusKm = 12;
                              tempBlacklist
                                ..clear()
                                ..addAll(PlacesService.defaultBlacklist);
                              tempAllowed
                                ..clear()
                                ..addAll(defaultCategories);
                            });
                          },
                          child: const Text('Reset Default',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '1. Pengecualian Tempat (Blacklist)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Switch(
                          value: tempFilterRetail,
                          activeThumbColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            setModalState(() => tempFilterRetail = val);
                          },
                        ),
                      ],
                    ),
                    Text(
                      tempFilterRetail
                          ? 'Aktif: Tempat dengan kata kunci di bawah otomatis disembunyikan.'
                          : 'Nonaktif: Semua jenis tempat publik diizinkan muncul.',
                      style: TextStyle(
                        fontSize: 11,
                        color: tempFilterRetail
                            ? const Color(0xFF059669)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              controller: newKeywordController,
                              decoration: const InputDecoration(
                                hintText:
                                    'Tambah kata kunci (cth: apotek, bengkel)...',
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8)),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final text = newKeywordController.text
                                .trim()
                                .toLowerCase();
                            if (text.isNotEmpty) {
                              setModalState(() {
                                tempBlacklist.add(text);
                                newKeywordController.clear();
                              });
                            }
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Tambah',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tempBlacklist.map((k) {
                        return Chip(
                          label: Text(k,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1E293B))),
                          deleteIcon: const Icon(Icons.close_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          onDeleted: () {
                            setModalState(() {
                              tempBlacklist.remove(k);
                            });
                          },
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: const BorderSide(
                              color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        'apotek',
                        'optik',
                        'pegadaian',
                        'klinik',
                        'bimbel',
                        'gym',
                      ]
                          .where((s) => !tempBlacklist.contains(s))
                          .map((sug) {
                        return ActionChip(
                          avatar: const Icon(Icons.add,
                              size: 12, color: Color(0xFF10B981)),
                          label: Text(sug,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF334155))),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onPressed: () {
                            setModalState(() {
                              tempBlacklist.add(sug);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2. Radius Jangkauan Pencarian',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            '$tempRadiusKm km',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: tempRadiusKm.toDouble().clamp(1.0, 100.0),
                      min: 1.0,
                      max: 100.0,
                      divisions: 99,
                      activeColor: const Color(0xFF2563EB),
                      inactiveColor: const Color(0xFFE2E8F0),
                      onChanged: (val) {
                        setModalState(() => tempRadiusKm = val.round());
                      },
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          [3, 5, 8, 12, 15, 25, 50, 75, 100].map((r) {
                        final isSelected = tempRadiusKm == r;
                        return ChoiceChip(
                          label: Text('$r km',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2563EB),
                          labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF334155)),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => tempRadiusKm = r);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24),
                    const Text(
                      '3. Kategori Sasaran (Dapat Disesuaikan)',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tempAllowed.map((cat) {
                        return FilterChip(
                          label: Text(cat,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold)),
                          selected: true,
                          selectedColor: const Color(0xFFEFF6FF),
                          checkmarkColor: const Color(0xFF2563EB),
                          side: const BorderSide(
                              color: Color(0xFF2563EB)),
                          onSelected: (_) {
                            setModalState(() {
                              if (tempAllowed.length > 1) {
                                tempAllowed.remove(cat);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '+ Saran Kategori Tambahan:',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        'SMA',
                        'Politeknik',
                        'BUMN',
                        'Rumah Sakit',
                        'Hotel',
                        'Yayasan',
                        'Pondok Pesantren',
                        'Balai Diklat',
                      ]
                          .where((s) => !tempAllowed.contains(s))
                          .map((sug) {
                        return ActionChip(
                          avatar: const Icon(Icons.add,
                              size: 13, color: Color(0xFF2563EB)),
                          label: Text(sug,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF334155))),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onPressed: () {
                            setModalState(() {
                              tempAllowed.add(sug);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onApply(MarketingFilterValues(
                            filterRetail: tempFilterRetail,
                            radiusKm: tempRadiusKm,
                            blacklist: Set.from(tempBlacklist),
                            allowedCategories: Set.from(tempAllowed),
                          ));
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.check_circle_rounded,
                            size: 18),
                        label: const Text(
                            'Terapkan Filter & Telusuri Ulang',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

import 'package:flutter/material.dart';

class AsesmenMandiriForm extends StatelessWidget {
  final List<Map<String, dynamic>> unitKompetensi;
  final Function(int index, bool kompeten) onKompetenChanged;

  const AsesmenMandiriForm({
    super.key,
    required this.unitKompetensi,
    required this.onKompetenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FR.APL.02 ASESMEN MANDIRI',
          style: TextStyle(
            color: Color(0xFF0F4C81),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Evaluasi diri Anda terhadap unit kompetensi di bawah ini. Nyatakan diri Anda Kompeten (K) jika menguasai kriteria kerja tersebut.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        ...List.generate(unitKompetensi.length, (index) {
          final unit = unitKompetensi[index];
          final bool isKompeten = unit['kompeten'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit['kode'] as String,
                  style: const TextStyle(
                    color: Color(0xFF0F4C81),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit['judul'] as String,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Apakah Anda Kompeten?',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('K', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          selected: isKompeten,
                          selectedColor: const Color(0xFFE8F5E9),
                          checkmarkColor: const Color(0xFF2E7D32),
                          onSelected: (selected) {
                            onKompetenChanged(index, true);
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('BK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          selected: !isKompeten,
                          selectedColor: const Color(0xFFFFEBEE),
                          checkmarkColor: const Color(0xFFC62828),
                          onSelected: (selected) {
                            onKompetenChanged(index, false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

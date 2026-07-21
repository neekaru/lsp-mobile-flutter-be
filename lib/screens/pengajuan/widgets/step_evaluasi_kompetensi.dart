import 'package:flutter/material.dart';
import '../../../models/sertifikat_models.dart';

class StepEvaluasiKompetensi extends StatelessWidget {
  final List<UnitKompetensi> units;
  final Map<int, String> answers;
  final void Function(int idElemen, String value) onAnswerChanged;
  final bool isLoading;

  const StepEvaluasiKompetensi({
    super.key,
    required this.units,
    required this.answers,
    required this.onAnswerChanged,
    this.isLoading = false,
  });

  /// Flat elemen list (one self-assessment row per elemen), like design mock.
  List<ElemenKompetensi> get _elemenFlat {
    final out = <ElemenKompetensi>[];
    for (final u in units) {
      for (final el in u.elemen) {
        if (el.idElemen > 0) out.add(el);
      }
    }
    return out;
  }

  String _displayText(ElemenKompetensi el) {
    final raw = el.elemenKompetensi.trim().isNotEmpty
        ? el.elemenKompetensi.trim()
        : el.pertanyaanKuk.trim();
    if (raw.isEmpty) return 'Kompetensi';
    final lower = raw.toLowerCase();
    if (lower.startsWith('mampu')) return raw;
    // Self-assessment phrasing (design mock: "Mampu anda …" / "Mampu …")
    if (lower.startsWith('melakukan') ||
        lower.startsWith('membuat') ||
        lower.startsWith('menjalankan') ||
        lower.startsWith('meng') ||
        lower.startsWith('men')) {
      return 'Mampu $raw';
    }
    return 'Mampu $raw';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        ),
      );
    }

    final items = _elemenFlat;
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            'Tidak ada data unit kompetensi.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evaluasi Kompetensi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Berikan penilaian kemampuan diri Anda pada kompetensi berikut.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: List.generate(items.length, (index) {
              final el = items[index];
              final selected = answers[el.idElemen];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == items.length - 1 ? 8 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${_displayText(el)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRadio(
                      label: 'Ya, saya bisa',
                      value: 'ya',
                      groupValue: selected,
                      onChanged: () => onAnswerChanged(el.idElemen, 'ya'),
                    ),
                    _buildRadio(
                      label: 'Tidak, saya tidak bisa',
                      value: 'tidak',
                      groupValue: selected,
                      onChanged: () => onAnswerChanged(el.idElemen, 'tidak'),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRadio({
    required String label,
    required String value,
    required String? groupValue,
    required VoidCallback onChanged,
  }) {
    final selected = groupValue == value;
    return InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3B82F6),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

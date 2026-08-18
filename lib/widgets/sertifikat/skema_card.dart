import 'package:material_ui/material_ui.dart';

import '../../models/sertifikat_models.dart';

/// Card skema sertifikasi — dipakai di grid [SkemaSertifikasiScreen].
class SkemaCard extends StatelessWidget {
  final SkemaSertifikatListItem skema;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback onTap;

  const SkemaCard({
    super.key,
    required this.skema,
    required this.colors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = skema.isOpen;
    final tags = skema.tags;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        // blurRadius reduced from 4 → 2: quadratic cost in blur pixels
        // (H1). 2px still visually preserves the soft-shadow feel but
        // cuts raster work ~4×. Combined with RepaintBoundary the shadow
        // is only rasterized once per card.
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Graphic header
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    icon,
                    size: 56,
                    // const color avoids a Color allocation per build (H3)
                    color: const Color(0x26FFFFFF), // 0.15 opacity white
                  ),
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 28,
                    color: const Color(0xF2FFFFFF), // 0.95 opacity white
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      skema.status,
                      style: TextStyle(
                        color: isOpen
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFFF4D4F),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    skema.title,
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Tags Row
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      // Closure extracted to a static helper (H6) so the
                      // inline lambda is not re-created on every build
                      // and the const children are reused by Flutter's
                      // element-reconciliation algorithm.
                      children: tags.map(_buildTagChip).toList(growable: false),
                    ),
                  ],

                  const Spacer(),

                  const Divider(height: 12, color: Color(0xFFF1F5F9)),

                  // Details rows
                  Row(
                    children: [
                      const Icon(
                        Icons.work_outline_rounded,
                        size: 10,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${skema.unitsCount} Unit Kompetensi',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 10,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          skema.price,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A9EDF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Lihat Skema',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pre-built tag chip — extracted from the inline lambda (H6) so Flutter
  /// can reuse the same widget instances across builds via element diffing.
  static Widget _buildTagChip(String tag) {
    final isPopular = tag == 'Populer';
    final isEUji = tag == 'E-Uji';
    final isSjj = tag.startsWith('SJJ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: isPopular
            ? const Color(0xFFFFEBEE)
            : (isEUji || isSjj)
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: isPopular
              ? const Color(0xFFC62828)
              : (isEUji || isSjj)
              ? const Color(0xFF2E7D32)
              : const Color(0xFF1565C0),
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Lightweight spec for a filter chip:
/// - label: text shown on the chip
/// - value: null → "Semua Skema", 'popular' → Populer, 'value' → bidang filter
class ChipSpec {
  final String label;
  final String? value;

  const ChipSpec({required this.label, required this.value});
}

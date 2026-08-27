import 'package:material_ui/material_ui.dart';
import 'skema_detail_summary.dart';
import 'asesmen_header_cards.dart';

class AsesmenMandiriForm extends StatefulWidget {
  final String selectedSkema;
  /// Each unit: `kode`, `judul`, `kuk_count` (label), `elemen` (list)
  final List<Map<String, dynamic>> unitKompetensi;
  final bool isLoading;
  /// true when skema not chosen yet (no skema id).
  final bool skemaBelumDipilih;
  /// true when the last kompetensi fetch failed (network / server error).
  final bool loadFailed;
  final VoidCallback? onRetry;
  final Function(int index) onUnitTap;
  final VoidCallback? onBuktiTap;

  const AsesmenMandiriForm({
    super.key,
    required this.selectedSkema,
    required this.unitKompetensi,
    required this.onUnitTap,
    this.isLoading = false,
    this.skemaBelumDipilih = false,
    this.loadFailed = false,
    this.onRetry,
    this.onBuktiTap,
  });

  @override
  State<AsesmenMandiriForm> createState() => _AsesmenMandiriFormState();
}

class _AsesmenMandiriFormState extends State<AsesmenMandiriForm> {
  bool _showAllUnits = false;
  static const int _unitPreviewLimit = 4;

  int get _totalElemen {
    var n = 0;
    for (final u in widget.unitKompetensi) {
      final el = u['elemen'];
      if (el is List) n += el.length;
    }
    return n;
  }

  int get _totalKuk {
    var n = 0;
    for (final u in widget.unitKompetensi) {
      final groups = u['elemen'];
      if (groups is! List) continue;
      for (final g in groups) {
        if (g is Map) {
          final items = g['items'];
          if (items is List) {
            n += items.length;
          } else {
            n += 1;
          }
        }
      }
    }
    return n;
  }

  Widget _buildEmptyState() {
    // Skema belum dipilih → arahkan balik ke Data Pengajuan.
    if (widget.skemaBelumDipilih || widget.selectedSkema.trim().isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Anda belum memilih skema. Kembali ke langkah Data Pengajuan dan '
          'pilih skema sertifikasi terlebih dahulu.',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      );
    }
    // API gagal → pesan jujur + tombol coba lagi.
    if (widget.loadFailed) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cloud_off_rounded,
                    color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal memuat unit/elemen/KUK dari server. '
                    'Periksa koneksi Anda lalu coba lagi.',
                    style: TextStyle(fontSize: 13, color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF378CE7),
                    side: const BorderSide(color: Color(0xFF378CE7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
    // Skema dipilih tapi unit kosong (jarang) → arahkan pilih ulang.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Unit/elemen/KUK skema "${widget.selectedSkema}" belum termuat. '
        'Kembali ke Data Pengajuan lalu pilih ulang skema.',
        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.unitKompetensi;
    final unitCount = units.length;
    final elemenCount = _totalElemen;
    final kukCount = _totalKuk;
    final visibleCount = _showAllUnits
        ? unitCount
        : unitCount.clamp(0, _unitPreviewLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AsesmenHeaderCards(onBuktiTap: widget.onBuktiTap),
        const SizedBox(height: 20),
        SkemaDetailSummary(
          selectedSkema: widget.selectedSkema,
          unitCount: unitCount,
          elemenCount: elemenCount,
          kukCount: kukCount,
        ),
        const SizedBox(height: 24),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (units.isEmpty)
          _buildEmptyState()
        else ...[
          ...List.generate(visibleCount, (index) {
            final unit = units[index];
            final kode = unit['kode'] as String? ?? '';
            final judul = unit['judul'] as String? ?? '';
            final kukLabel = unit['kuk_count'] as String? ??
                '${(unit['elemen'] as List?)?.length ?? 0} item';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: InkWell(
                onTap: () => widget.onUnitTap(index),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kode,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              judul,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              kukLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Color(0xFF378CE7),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (unitCount > _unitPreviewLimit)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: InkWell(
                onTap: () => setState(() => _showAllUnits = !_showAllUnits),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _showAllUnits
                              ? Icons.unfold_less_rounded
                              : Icons.folder_open_rounded,
                          color: const Color(0xFF378CE7),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _showAllUnits
                                  ? 'Sembunyikan Unit Kompetensi'
                                  : 'Lihat Semua Unit Kompetensi',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F4C81),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$unitCount Unit · $elemenCount elemen · $kukCount KUK',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _showAllUnits
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF378CE7),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.folder_open_rounded,
                        color: Color(0xFF378CE7),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Semua Unit Kompetensi',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F4C81),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$unitCount Unit · $elemenCount elemen · $kukCount KUK',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

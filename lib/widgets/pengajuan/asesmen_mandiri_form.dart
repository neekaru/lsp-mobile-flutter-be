import 'package:material_ui/material_ui.dart';
import 'skema_detail_summary.dart';
import 'asesmen_header_cards.dart';

class AsesmenMandiriForm extends StatefulWidget {
  final String selectedSkema;
  /// Each unit: `kode`, `judul`, `kuk_count` (label), `elemen` (list)
  final List<Map<String, dynamic>> unitKompetensi;
  final Map<String, bool?> kukAssessments;
  final VoidCallback? onCheckAllK;
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
    required this.kukAssessments,
    required this.onUnitTap,
    this.onCheckAllK,
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

  bool _isUnitComplete(Map<String, dynamic> unit) {
    final groups = unit['elemen'];
    if (groups is! List || groups.isEmpty) return false;
    for (final group in groups) {
      if (group is! Map) continue;
      final items = group['items'];
      if (items is List && items.isNotEmpty) {
        for (final item in items) {
          if (item is Map) {
            final key = item['key']?.toString() ?? '';
            if (key.isNotEmpty && widget.kukAssessments[key] != true) {
              return false;
            }
          }
        }
      } else {
        final idElemen = group['id_elemen']?.toString() ?? '';
        if (idElemen.isNotEmpty && widget.kukAssessments['e:$idElemen'] != true) {
          return false;
        }
      }
    }
    return true;
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
        if (widget.onCheckAllK != null && units.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.playlist_add_check_rounded,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asesmen Mandiri (APL.02)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      Text(
                        'Semua unit harus dinilai Kompeten (K)',
                        style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onCheckAllK,
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Pilih Semua K',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            final isComplete = _isUnitComplete(unit);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isComplete ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isComplete ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                  width: isComplete ? 1.2 : 1.0,
                ),
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
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? const Color(0xFF15803D) : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kode,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isComplete ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              judul,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isComplete ? const Color(0xFF14532D) : const Color(0xFF1E293B),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  kukLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isComplete ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                                  ),
                                ),
                                if (isComplete) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Kompeten (K)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          isComplete ? Icons.check_circle_rounded : Icons.keyboard_arrow_right_rounded,
                          color: isComplete ? const Color(0xFF16A34A) : const Color(0xFF378CE7),
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

import 'package:material_ui/material_ui.dart';
import 'asesmen_header_cards.dart';
import 'skema_detail_summary.dart';

class DokumenPortofolioForm extends StatelessWidget {
  final String selectedSkema;
  /// From GET pra-asesmen kompetensi — same shape as AsesmenMandiriForm.
  final List<Map<String, dynamic>> unitKompetensi;
  final bool isLoading;
  /// true when skema not chosen yet (no skema id).
  final bool skemaBelumDipilih;
  /// true when the last kompetensi fetch failed (network / server error).
  final bool loadFailed;
  final VoidCallback? onRetry;
  final VoidCallback? onBuktiTap;
  final VoidCallback? onUnitTap;

  const DokumenPortofolioForm({
    super.key,
    required this.selectedSkema,
    this.unitKompetensi = const [],
    this.isLoading = false,
    this.skemaBelumDipilih = false,
    this.loadFailed = false,
    this.onRetry,
    this.onBuktiTap,
    this.onUnitTap,
  });

  int get _totalElemen {
    var n = 0;
    for (final u in unitKompetensi) {
      final el = u['elemen'];
      if (el is List) n += el.length;
    }
    return n;
  }

  int get _totalKuk {
    var n = 0;
    for (final u in unitKompetensi) {
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

  @override
  Widget build(BuildContext context) {
    final unitCount = unitKompetensi.length;
    final elemenCount = _totalElemen;
    final kukCount = _totalKuk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AsesmenHeaderCards(onBuktiTap: onBuktiTap),
        const SizedBox(height: 20),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          SkemaDetailSummary(
            selectedSkema: selectedSkema,
            unitCount: unitCount,
            elemenCount: elemenCount,
            kukCount: kukCount,
            onUnitTap: onUnitTap,
          ),
          if (unitCount == 0 || (elemenCount == 0 && kukCount == 0))
            _buildEmptyState(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    // Skema belum dipilih → arahkan balik ke Data Pengajuan (bukan "0").
    if (skemaBelumDipilih || selectedSkema.trim().isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          'Anda belum memilih skema. Kembali ke langkah Data Pengajuan dan '
          'pilih skema sertifikasi terlebih dahulu agar unit/elemen/KUK tampil.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
        ),
      );
    }
    // API gagal → pesan jujur + tombol coba lagi.
    if (loadFailed) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
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
                    style: TextStyle(fontSize: 12.5, color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
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
    // Skema dipilih tapi elemen/KUK 0 (data detail sedang dimuat / kosong).
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text(
        'Elemen/KUK masih 0 — data detail sedang dimuat. Jika tetap 0, '
        'kembali ke Data Pengajuan lalu pilih ulang skema.',
        style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

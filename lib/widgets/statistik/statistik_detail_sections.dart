// ============================================================================
// Statistik Detail Sections
//
// Konten per menu di StatistikDetailScreen. Diekstrak dari
// statistik_detail_screen.dart agar screen hanya berisi state + navigasi.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/dashboard_models.dart';
import '../../models/sertifikat_models.dart';
import '../../screens/statistik/kompetensi_teknis_detail_screen.dart';
import '../../screens/statistik/muk_detail_screen.dart';
import 'statistik_kpi_widgets.dart';
import 'statistik_location_cards.dart';
import 'statistik_status_cards.dart';

// ── Field pencarian standar (dipakai banyak section) ──────────────────────
class StatistikSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final bool hasQuery;
  final VoidCallback onClear;

  const StatistikSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.hasQuery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          if (hasQuery)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

// ── Chip filter status (Semua / Aktif / Tenggang / Expired) ───────────────
class StatusFilterCards extends StatelessWidget {
  final int totalAll;
  final int totalAktif;
  final int totalTenggang;
  final int totalExpired;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  const StatusFilterCards({
    super.key,
    required this.totalAll,
    required this.totalAktif,
    required this.totalTenggang,
    required this.totalExpired,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Semua', 'key': 'Semua', 'count': totalAll, 'color': const Color(0xFF2563EB), 'icon': Icons.apps_rounded},
      {'label': 'Aktif', 'key': 'Aktif', 'count': totalAktif, 'color': const Color(0xFF16A34A), 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Tenggang', 'key': 'Tenggang', 'count': totalTenggang, 'color': const Color(0xFFD97706), 'icon': Icons.warning_amber_rounded},
      {'label': 'Expired', 'key': 'Expired', 'count': totalExpired, 'color': const Color(0xFFDC2626), 'icon': Icons.cancel_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final key = f['key'] as String;
          final label = f['label'] as String;
          final count = f['count'] as int;
          final color = f['color'] as Color;
          final icon = f['icon'] as IconData;
          final isSelected = selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                onSelectFilter(isSelected && key != 'Semua' ? 'Semua' : key);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(20) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withAlpha(30),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? color : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── 1. Domisili Asesor ────────────────────────────────────────────────────
class DomisiliAsesorSection extends StatelessWidget {
  final DomisiliAsesorData? data;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const DomisiliAsesorSection({
    super.key,
    required this.data,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final items = data?.items ?? [];
    final filtered = items
        .where((i) =>
            searchQuery.isEmpty ||
            i.provinsiNama.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KpiCardGroup(
          items: [
            KpiItem('Total Asesor', '${data?.totalAsesor ?? 0}', Colors.blue),
            KpiItem('Homebase Internal', '${data?.totalInternal ?? 0}', Colors.green),
            KpiItem('Homebase External', '${data?.totalExternal ?? 0}', Colors.orange),
          ],
        ),
        const SizedBox(height: 16),
        StatistikSearchField(
          hint: 'Cari Provinsi...',
          onChanged: onSearchChanged,
          hasQuery: searchQuery.isNotEmpty,
          onClear: onClearSearch,
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          EmptyStateCard(message: 'Belum ada data sebaran domisili asesor.')
        else if (filtered.isEmpty)
          EmptyStateCard(message: 'Tidak ada provinsi yang cocok dengan pencarian.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) => DomisiliCard(item: filtered[index]),
          ),
      ],
    );
  }
}

// ── 2. Kompetensi Teknis ──────────────────────────────────────────────────
class KompetensiTeknisSection extends StatelessWidget {
  final List<KompetensiTeknisItem> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const KompetensiTeknisSection({
    super.key,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList = items
        .where((i) =>
            searchQuery.isEmpty ||
            i.namaSkema.toLowerCase().contains(searchQuery.toLowerCase()) ||
            i.kodeSkema.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KpiCardGroup(
          items: [
            KpiItem('Total Skema', '${items.length}', Colors.blue),
            KpiItem('Total Asesor', '${items.fold<int>(0, (sum, i) => sum + i.jumlahAsesor)}', Colors.indigo),
          ],
        ),
        const SizedBox(height: 16),
        StatistikSearchField(
          hint: 'Cari Skema / Kode...',
          onChanged: onSearchChanged,
          hasQuery: searchQuery.isNotEmpty,
          onClear: onClearSearch,
        ),
        const SizedBox(height: 12),
        if (filteredList.isEmpty)
          EmptyStateCard(message: 'Belum ada data kompetensi teknis asesor.')
        else
          ...filteredList.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => KompetensiTeknisDetailScreen(
                            skemaId: item.skemaId,
                            kodeSkema: item.kodeSkema,
                            namaSkema: item.namaSkema,
                            jumlahAsesor: item.jumlahAsesor,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.build_outlined, color: Color(0xFF2563EB), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaSkema,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kode: ${item.kodeSkema}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.jumlahAsesor}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
                              ),
                              const Text('Asesor', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

// ── 3. Masa Berlaku ───────────────────────────────────────────────────────
class MasaBerlakuSection extends StatelessWidget {
  final MasaBerlakuAsesorData? data;

  const MasaBerlakuSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data?.totalAsesor ?? ((data?.aktif ?? 0) + (data?.tenggang ?? 0) + (data?.expired ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Masa Berlaku Sertifikat Asesor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Terdaftar: $total Asesor',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StatusCard(
          title: 'Sertifikat Aktif',
          count: '${data?.aktif ?? 0}',
          desc: 'Masa berlaku masih aktif',
          color: const Color(0xFF16A34A),
          icon: Icons.check_circle_outline,
          statusKey: null,
          numericCount: data?.aktif ?? 0,
        ),
        const SizedBox(height: 10),
        StatusCard(
          title: 'Masa Tenggang',
          count: '${data?.tenggang ?? 0}',
          desc: 'Kurang dari 3 bulan menuju expired',
          color: const Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
          statusKey: 'tenggang',
          numericCount: data?.tenggang ?? 0,
        ),
        const SizedBox(height: 10),
        StatusCard(
          title: 'Expired / Kadaluarsa',
          count: '${data?.expired ?? 0}',
          desc: 'Sertifikat sudah habis masa berlaku',
          color: const Color(0xFFDC2626),
          icon: Icons.cancel_outlined,
          statusKey: 'expired',
          numericCount: data?.expired ?? 0,
        ),
      ],
    );
  }
}

// ── 3b. Masa Tenggang Sertifikat ──────────────────────────────────────────
class MasaTenggangSection extends StatelessWidget {
  final MasaTenggangSertifikatData? data;

  const MasaTenggangSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sertifikat Akan Expired',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${data?.totalSertifikatAkanExpired ?? 0} sertifikat (${data?.periodeAwal ?? '-'} s/d ${data?.periodeAkhir ?? '-'})',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...?data?.data.expand((bulanItem) => [
          BulanTenggangCard(item: bulanItem),
          const SizedBox(height: 10),
        ]),
      ],
    );
  }
}

// ── 4. Jenis Skema ────────────────────────────────────────────────────────
class JenisSkemaSection extends StatelessWidget {
  final List<JenisSkemaItem> items;

  const JenisSkemaSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KpiCardGroup(
          items: [
            KpiItem('Total Kategori', '${items.length}', Colors.blue),
            KpiItem('Total Skema', '${items.fold<int>(0, (sum, i) => sum + i.jumlahSkema)}', Colors.indigo),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          EmptyStateCard(message: 'Belum ada data kategori jenis skema.')
        else
          ...items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schema_outlined, color: Color(0xFF2563EB), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.kategori,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.jumlahSkema} Skema',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}

// ── 5. MUK ────────────────────────────────────────────────────────────────
class MUKSection extends StatelessWidget {
  final List<MUKDistribusiItem> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const MUKSection({
    super.key,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  static DateTime _lastMukDetailNavTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    final filteredList = items
        .where((i) =>
            searchQuery.isEmpty ||
            i.namaSkema.toLowerCase().contains(searchQuery.toLowerCase()) ||
            i.kodeSkema.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KpiCardGroup(
          items: [
            KpiItem('Total Skema', '${items.length}', Colors.blue),
            KpiItem('Total MUK/MAPA', '${items.fold<int>(0, (sum, i) => sum + i.jumlahMuk)}', Colors.teal),
          ],
        ),
        const SizedBox(height: 16),
        StatistikSearchField(
          hint: 'Cari Skema MUK...',
          onChanged: onSearchChanged,
          hasQuery: searchQuery.isNotEmpty,
          onClear: onClearSearch,
        ),
        const SizedBox(height: 12),
        if (filteredList.isEmpty)
          EmptyStateCard(message: 'Belum ada data distribusi MUK per skema.')
        else
          ...filteredList.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final now = DateTime.now();
                      if (now.difference(_lastMukDetailNavTime).inMilliseconds < 600) return;
                      _lastMukDetailNavTime = now;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MUKDetailScreen(
                            skemaId: item.skemaId,
                            kodeSkema: item.kodeSkema,
                            namaSkema: item.namaSkema,
                            totalMuk: item.jumlahMuk,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_open_outlined, color: Color(0xFF0D9488), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.namaSkema, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('Kode: ${item.kodeSkema}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Text('${item.jumlahMuk} MUK', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D9488))),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

// ── 6. Praktisi ───────────────────────────────────────────────────────────
class PraktisiSection extends StatelessWidget {
  const PraktisiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF2563EB)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tabel Praktisi Skema (praktisi_skema) dikelompokkan berdasarkan skema sertifikasi.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EmptyStateCard(message: 'Belum ada data praktisi skema terdaftar.'),
      ],
    );
  }
}

// ── 7. Tahun 2026 ─────────────────────────────────────────────────────────
class Tahun2026Section extends StatelessWidget {
  final List<MonthlyAssessment> list;

  const Tahun2026Section({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah Asesi Setiap Bulan Tahun 2026',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          EmptyStateCard(message: 'Belum ada data grafik asesi tahun 2026.')
        else
          ...list.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(m.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (m.total / 100).clamp(0.05, 1.0),
                          minHeight: 10,
                          color: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${m.total} Asesi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              )),
      ],
    );
  }
}

// ── 8. Tiga Tahun (2024 - 2026) ───────────────────────────────────────────
class TigaTahunSection extends StatelessWidget {
  const TigaTahunSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grafik Asesi Pertahun (2024 - 2026)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        YearCard(year: 'Tahun 2024', total: '1,240 Asesi', progress: 0.6, color: Colors.blue),
        const SizedBox(height: 10),
        YearCard(year: 'Tahun 2025', total: '1,890 Asesi', progress: 0.85, color: Colors.indigo),
        const SizedBox(height: 10),
        YearCard(year: 'Tahun 2026', total: '2,150 Asesi', progress: 1.0, color: Colors.teal),
      ],
    );
  }
}

// ── 9. Kompetensi ─────────────────────────────────────────────────────────
class KompetensiSection extends StatelessWidget {
  final List<SertifikatDistribusi> list;

  const KompetensiSection({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kompetensi Berdasarkan Skema (3 Tahun Terakhir)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          EmptyStateCard(message: 'Belum ada data kompetensi per skema.')
        else
          ...list.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Color(0xFF16A34A), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item.skema, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Text('${item.totalPemegang} Kompeten', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF16A34A))),
                  ],
                ),
              )),
      ],
    );
  }
}


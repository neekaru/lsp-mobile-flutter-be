// ============================================================================
// Statistik Detail Sliver Sections
//
// Section berbasis CustomScrollView + SliverList (SPT 2026 & Asesi 2026) agar
// list besar tetap tervirtualisasi. Dipisah dari statistik_detail_sections.dart
// supaya ukuran tiap file tetap terkendali.
// ============================================================================

import 'package:flutter/material.dart';

import '../../models/dashboard_models.dart';
import 'statistik_kpi_widgets.dart';
import 'statistik_monthly_cards.dart';
import 'statistik_detail_sections.dart';

// ── SPT 2026 ── CustomScrollView + SliverList for virtualization ──────────
class Spt2026Section extends StatelessWidget {
  final SptAsesorData? data;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onFilterChanged;

  const Spt2026Section({
    super.key,
    required this.data,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = data?.items ?? [];
    final filtered = items.where((i) {
      final matchesSearch = searchQuery.isEmpty ||
          i.namaAsesor.toLowerCase().contains(searchQuery.toLowerCase());
      final statusLower = i.statusMasaBerlaku.toLowerCase();
      final filterLower = statusFilter.toLowerCase();
      bool matchesStatus = true;
      if (filterLower == 'aktif') {
        matchesStatus = statusLower == 'aktif';
      } else if (filterLower == 'tenggang') {
        matchesStatus = statusLower == 'tenggang';
      } else if (filterLower == 'expired') {
        matchesStatus = statusLower == 'expired' || statusLower == 'kadaluarsa';
      }
      return matchesSearch && matchesStatus;
    }).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KpiCardGroup(
                  items: [
                    KpiItem('Total Asesor', '${data?.totalAsesor ?? items.length}', Colors.blue),
                    KpiItem('Total Penugasan', '${data?.totalJadwal ?? items.fold<int>(0, (sum, i) => sum + i.total)}', Colors.indigo),
                  ],
                ),
                const SizedBox(height: 16),
                StatistikSearchField(
                  hint: 'Cari Nama Asesor...',
                  onChanged: onSearchChanged,
                  hasQuery: searchQuery.isNotEmpty,
                  onClear: onClearSearch,
                ),
                const SizedBox(height: 12),
                StatusFilterCards(
                  totalAll: items.length,
                  totalAktif: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'aktif').length,
                  totalTenggang: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'tenggang').length,
                  totalExpired: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'expired' || i.statusMasaBerlaku.toLowerCase() == 'kadaluarsa').length,
                  selectedFilter: statusFilter,
                  onSelectFilter: onFilterChanged,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text('Belum ada data penugasan asesor (SPT) 2026.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SptAsesorCard(item: filtered[index]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Asesi 2026 ── CustomScrollView + SliverList for virtualization ────────
class Asesi2026Section extends StatelessWidget {
  final Asesi2026Data? data;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onFilterChanged;

  const Asesi2026Section({
    super.key,
    required this.data,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = data?.items ?? [];
    final filtered = items.where((i) {
      final matchesSearch = searchQuery.isEmpty ||
          i.namaAsesor.toLowerCase().contains(searchQuery.toLowerCase());
      final statusLower = i.statusMasaBerlaku.toLowerCase();
      final filterLower = statusFilter.toLowerCase();
      bool matchesStatus = true;
      if (filterLower == 'aktif') {
        matchesStatus = statusLower == 'aktif';
      } else if (filterLower == 'tenggang') {
        matchesStatus = statusLower == 'tenggang';
      } else if (filterLower == 'expired') {
        matchesStatus = statusLower == 'expired' || statusLower == 'kadaluarsa';
      }
      return matchesSearch && matchesStatus;
    }).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KpiCardGroup(
                  items: [
                    KpiItem('Total Asesor', '${data?.totalAsesor ?? items.length}', Colors.blue),
                    KpiItem('Total Asesi', '${data?.totalAsesi ?? items.fold<int>(0, (sum, i) => sum + i.totalAsesi)}', const Color(0xFF16A34A)),
                    KpiItem('Total Jadwal', '${data?.totalJadwal ?? items.fold<int>(0, (sum, i) => sum + i.totalJadwal)}', Colors.indigo),
                  ],
                ),
                const SizedBox(height: 16),
                StatistikSearchField(
                  hint: 'Cari Nama Asesor...',
                  onChanged: onSearchChanged,
                  hasQuery: searchQuery.isNotEmpty,
                  onClear: onClearSearch,
                ),
                const SizedBox(height: 12),
                StatusFilterCards(
                  totalAll: items.length,
                  totalAktif: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'aktif').length,
                  totalTenggang: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'tenggang').length,
                  totalExpired: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'expired' || i.statusMasaBerlaku.toLowerCase() == 'kadaluarsa').length,
                  selectedFilter: statusFilter,
                  onSelectFilter: onFilterChanged,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text('Belum ada data penugasan asesi 2026.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Asesi2026Card(item: filtered[index]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

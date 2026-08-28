// ============================================================================
// Widget bagian atas Lead Generator: KPI header, quick explore Maps,
// search & filter kategori, dan empty state.
// Diekstrak dari lead_generator_screen.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../models/lead_model.dart';

// ── 1. KPI SUMMARY HEADER ──────────────────────────────────────────────────
class LeadKpiSummaryHeader extends StatelessWidget {
  final List<LeadModel> leads;
  final String kabupaten;

  const LeadKpiSummaryHeader({
    super.key,
    required this.leads,
    required this.kabupaten,
  });

  @override
  Widget build(BuildContext context) {
    final total = leads.length;
    final prospek = leads.where((e) => e.leadStatus == 'prospek').length;
    final interest = leads.where((e) => e.leadStatus == 'interest').length;
    final sales = leads.where((e) => e.leadStatus == 'sales').length;
    final totalSiswa = leads.fold<int>(0, (sum, item) => sum + item.estimasiSiswa);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.map_pin, color: Colors.white, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    'Peta Potensi: $kabupaten',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '±$totalSiswa Siswa/Thn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildKpiItem('Total Leads', total.toString(), Colors.white),
              _buildKpiItem('Prospek', prospek.toString(), const Color(0xFFFDE047)),
              _buildKpiItem('Interest', interest.toString(), const Color(0xFF93C5FD)),
              _buildKpiItem('Sales', sales.toString(), const Color(0xFF86EFAC)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String title, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── 2. GOOGLE MAPS QUICK EXPLORE ───────────────────────────────────────────
const List<Map<String, dynamic>> kQuickGmapsKeywords = [
  {
    'label': 'SMK Terdekat',
    'keyword': 'SMK terdekat',
    'kategori': 'SMK',
    'icon': LucideIcons.graduation_cap,
    'color': Color(0xFF2563EB),
  },
  {
    'label': 'Kampus Terdekat',
    'keyword': 'Kampus Universitas terdekat',
    'kategori': 'Kampus',
    'icon': LucideIcons.building,
    'color': Color(0xFF7C3AED),
  },
  {
    'label': 'LPK Terdekat',
    'keyword': 'LPK Lembaga Pelatihan Kerja terdekat',
    'kategori': 'LPK',
    'icon': LucideIcons.award,
    'color': Color(0xFF0D9488),
  },
  {
    'label': 'LKP Terdekat',
    'keyword': 'LKP Lembaga Kursus dan Pelatihan terdekat',
    'kategori': 'LKP',
    'icon': LucideIcons.book_open,
    'color': Color(0xFF0284C7),
  },
  {
    'label': 'BLK Terdekat',
    'keyword': 'BLK Balai Latihan Kerja terdekat',
    'kategori': 'BLK',
    'icon': LucideIcons.hammer,
    'color': Color(0xFFEA580C),
  },
  {
    'label': 'Dinas Pemda',
    'keyword': 'Dinas Pemerintah Daerah terdekat',
    'kategori': 'Dinas Pemda',
    'icon': LucideIcons.landmark,
    'color': Color(0xFF059669),
  },
  {
    'label': 'Perusahaan Swasta',
    'keyword': 'Perusahaan Kawasan Industri terdekat',
    'kategori': 'Perusahaan Swasta',
    'icon': LucideIcons.briefcase,
    'color': Color(0xFF4F46E5),
  },
];

class LeadQuickExplore extends StatelessWidget {
  final void Function(String keyword) onOpenKeyword;

  const LeadQuickExplore({super.key, required this.onOpenKeyword});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.map, size: 14, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              const Text(
                'Jelajah Google Maps Terdekat:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                'Klik untuk buka Maps ↗',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kQuickGmapsKeywords.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: Icon(item['icon'] as IconData, size: 14, color: item['color'] as Color),
                    label: Text(
                      item['label'].toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item['color'] as Color,
                      ),
                    ),
                    backgroundColor: (item['color'] as Color).withValues(alpha: 0.08),
                    side: BorderSide(color: (item['color'] as Color).withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () {
                      onOpenKeyword(item['keyword'].toString());
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3. SEARCH BAR + FILTER KATEGORI ────────────────────────────────────────
class LeadSearchAndFilters extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final List<String> kategoriList;
  final String selectedKategori;
  final ValueChanged<String> onSelectKategori;

  const LeadSearchAndFilters({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.kategoriList,
    required this.selectedKategori,
    required this.onSelectKategori,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => onSearchChanged(),
                    style: const TextStyle(fontSize: 12.5),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama institusi atau alamat...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      onSearchChanged();
                    },
                    child: const Icon(Icons.close_rounded, size: 15, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
        ),

        // Category Filter Chips
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kategoriList.length,
            separatorBuilder: (context, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final cat = kategoriList[index];
              final isSel = selectedKategori == cat;
              return ChoiceChip(
                label: Text(cat),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? Colors.white : const Color(0xFF334155),
                ),
                selected: isSel,
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                ),
                showCheckmark: false,
                onSelected: (_) {
                  onSelectKategori(cat);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 4. EMPTY STATE ─────────────────────────────────────────────────────────
class LeadEmptyState extends StatelessWidget {
  final VoidCallback onAddLead;

  const LeadEmptyState({super.key, required this.onAddLead});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.map_pin_off, size: 44, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada lead ditemukan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gunakan tombol pencarian Maps di atas atau tambah lead baru',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddLead,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Simpan Lead Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

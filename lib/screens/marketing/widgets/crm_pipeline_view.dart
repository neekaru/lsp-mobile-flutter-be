import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';
import '../../../services/marketing/lead_storage_service.dart';
import 'lead_crm_card.dart';
import 'marketing_kpi_header.dart';

class MarketingModeSwitcher extends StatelessWidget {
  final int selectedMode;
  final int savedCount;
  final ValueChanged<int> onSelect;

  const MarketingModeSwitcher({
    super.key,
    required this.selectedMode,
    required this.savedCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              icon: Icons.map_rounded,
              label: 'Peta Lead Generator',
              active: selectedMode == 0,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _Tab(
              icon: Icons.view_kanban_rounded,
              label: 'Prospek Saya ($savedCount)',
              active: selectedMode == 1,
              onTap: () => onSelect(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CrmPipelineView extends StatelessWidget {
  final bool isLoading;
  final List<LeadModel> savedLeads;
  final LeadSummaryStats stats;
  final String filterStatus;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onSelectStatus;
  final ValueChanged<String> onToggleKpiTab;
  final VoidCallback onOpenMap;
  final void Function(LeadModel) onTapLead;
  final void Function(LeadModel) onOpenProposal;
  final Future<void> Function() onRefresh;
  final int idAsesor;

  const CrmPipelineView({
    super.key,
    required this.isLoading,
    required this.savedLeads,
    required this.stats,
    required this.filterStatus,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectStatus,
    required this.onToggleKpiTab,
    required this.onOpenMap,
    required this.onTapLead,
    required this.onOpenProposal,
    required this.onRefresh,
    required this.idAsesor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final q = searchController.text.trim().toLowerCase();
    final filteredLeads = savedLeads.where((l) {
      final matchesStatus = filterStatus == 'all' ||
          l.leadStatus.toLowerCase() == filterStatus.toLowerCase();
      final matchesQuery = q.isEmpty ||
          l.namaInstitusi.toLowerCase().contains(q) ||
          l.leadLocation.toLowerCase().contains(q) ||
          l.leadKategori.toLowerCase().contains(q);
      return matchesStatus && matchesQuery;
    }).toList();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          MarketingKpiHeader(
            stats: stats,
            activeTab: filterStatus,
            onSelectStatusTab: onToggleKpiTab,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) => onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Cari di daftar prospek saya...',
                hintStyle:
                    const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: Color(0xFF64748B)),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: onClearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _StatusChip(
                    statusKey: 'all',
                    label: 'Semua (${savedLeads.length})',
                    selected: filterStatus == 'all',
                    onTap: () => onSelectStatus('all')),
                _StatusChip(
                    statusKey: 'lead',
                    label: 'Lead (${stats.countLead})',
                    selected: filterStatus == 'lead',
                    onTap: () => onSelectStatus('lead')),
                _StatusChip(
                    statusKey: 'prospek',
                    label: 'Proposal (${stats.countProspek})',
                    selected: filterStatus == 'prospek',
                    onTap: () => onSelectStatus('prospek')),
                _StatusChip(
                    statusKey: 'interest',
                    label: 'Follow Up (${stats.countInterest})',
                    selected: filterStatus == 'interest',
                    onTap: () => onSelectStatus('interest')),
                _StatusChip(
                    statusKey: 'sales',
                    label: 'Deal / MoU (${stats.countSales})',
                    selected: filterStatus == 'sales',
                    onTap: () => onSelectStatus('sales')),
              ],
            ),
          ),
          if (filteredLeads.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.folder_open_rounded,
                        size: 48, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada data prospek pada filter ini',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gunakan tab "Peta Lead Generator" untuk menemukan calon mitra uji kompetensi terdekat.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onOpenMap,
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: const Text('Buka Peta Generator'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredLeads.map((lead) {
              return LeadCrmCard(
                lead: lead,
                onTap: () => onTapLead(lead),
                onWhatsApp: () => onOpenProposal(lead),
                onProposal: () => onOpenProposal(lead),
                onStatusChange: (newStatus) async {
                  await LeadStorageService.updateLeadStatus(
                      idAsesor, lead.id, newStatus);
                  await onRefresh();
                },
              );
            }),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String statusKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.statusKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
        selected: selected,
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

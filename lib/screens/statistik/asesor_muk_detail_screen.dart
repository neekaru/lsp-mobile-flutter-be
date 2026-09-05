import 'package:material_ui/material_ui.dart';

import '../../models/dashboard_models.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class AsesorMUKDetailScreen extends StatelessWidget {
  const AsesorMUKDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          CustomAppBar(
            title: 'Detail MUK / MAPA',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: FutureBuilder<List<AsesorMUKItem>>(
              future: DashboardService.getAsesorMUK(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat data MUK.'));
                }
                final items = snapshot.data ?? const <AsesorMUKItem>[];
                if (items.isEmpty) {
                  return const Center(child: Text('Belum ada MUK / MAPA.'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await DashboardService.getAsesorMUK();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _MUKCard(item: items[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MUKCard extends StatelessWidget {
  final AsesorMUKItem item;

  const _MUKCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.namaMapa,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _MUKField(label: 'Tanggal dibuat', value: item.tanggalPembuatan),
          _MUKField(label: 'Validator', value: item.validator),
          _MUKField(label: 'Status', value: item.status),
        ],
      ),
    );
  }
}

class _MUKField extends StatelessWidget {
  final String label;
  final String value;

  const _MUKField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

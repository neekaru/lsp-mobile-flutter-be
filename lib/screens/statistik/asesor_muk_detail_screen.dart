import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/dashboard_models.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class AsesorMUKDetailScreen extends StatefulWidget {
  const AsesorMUKDetailScreen({super.key});

  @override
  State<AsesorMUKDetailScreen> createState() => _AsesorMUKDetailScreenState();
}

class _AsesorMUKDetailScreenState extends State<AsesorMUKDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<List<AsesorMUKItem>> _mukFuture;

  @override
  void initState() {
    super.initState();
    _mukFuture = DashboardService.getAsesorMUK();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama MUK atau validator...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 20, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AsesorMUKItem>>(
              future: _mukFuture,
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

                final filteredItems = _searchQuery.isEmpty
                    ? items
                    : items.where((item) {
                        final title = item.namaMapa.toLowerCase();
                        final validator = item.validator.toLowerCase();
                        return title.contains(_searchQuery) ||
                            validator.contains(_searchQuery);
                      }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ditemukan MUK untuk "$_searchQuery"',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _mukFuture = DashboardService.getAsesorMUK();
                    });
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _MUKCard(item: filteredItems[index]),
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: item.hasDownloadLink
                  ? () async {
                      final uri = Uri.tryParse(item.linkMukManual);
                      if (uri != null) {
                        try {
                          if (!await launchUrl(uri,
                              mode: LaunchMode.externalApplication)) {
                            await launchUrl(uri,
                                mode: LaunchMode.platformDefault);
                          }
                        } catch (_) {
                          try {
                            await launchUrl(uri,
                                mode: LaunchMode.inAppBrowserView);
                          } catch (_) {}
                        }
                      }
                    }
                  : null,
              icon: Icon(
                item.hasDownloadLink
                    ? Icons.open_in_new_rounded
                    : Icons.link_off_rounded,
                size: 16,
              ),
              label: Text(
                item.hasDownloadLink
                    ? 'Buka / Download Link MUK'
                    : 'Link Belum Tersedia',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF1F5F9),
                disabledForegroundColor: const Color(0xFF94A3B8),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: item.hasDownloadLink
                      ? BorderSide.none
                      : const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                elevation: 0,
              ),
            ),
          ),
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

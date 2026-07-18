import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';

class AsesorHomebaseScreen extends StatefulWidget {
  const AsesorHomebaseScreen({super.key});

  @override
  State<AsesorHomebaseScreen> createState() => _AsesorHomebaseScreenState();
}

class _AsesorHomebaseScreenState extends State<AsesorHomebaseScreen> {
  List<_HomebaseGroup> _groups = const [];
  int _totalAsesor = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final list = await ApiService.getAsesorHomebase();
      if (!mounted) return;

      // Group on a local map first (cheap for typical sizes)
      final Map<String, List<AsesorHomebase>> grouped = {};
      for (final item in list) {
        final key =
            item.homebase.trim().isEmpty ? 'Tidak diketahui' : item.homebase.trim();
        (grouped[key] ??= <AsesorHomebase>[]).add(item);
      }

      final groups = <_HomebaseGroup>[];
      for (final entry in grouped.entries) {
        final items = entry.value
          ..sort((a, b) => b.assessments.compareTo(a.assessments));
        var totalAssessments = 0;
        for (final i in items) {
          totalAssessments += i.assessments;
        }
        groups.add(
          _HomebaseGroup(
            homebase: entry.key,
            items: items,
            totalAssessments: totalAssessments,
          ),
        );
      }

      groups.sort((a, b) {
        final byCount = b.items.length.compareTo(a.items.length);
        if (byCount != 0) return byCount;
        return a.homebase.toLowerCase().compareTo(b.homebase.toLowerCase());
      });

      setState(() {
        _groups = groups;
        _totalAsesor = list.length;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Asessor Berdasarkan Homebase',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data Asesor',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_groups.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Tidak ada data asesor berdasarkan homebase.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _groups.length + 1,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Header(
              daerahCount: _groups.length,
              totalAsesor: _totalAsesor,
            );
          }

          final group = _groups[index - 1];
          return RepaintBoundary(
            key: ValueKey(group.homebase),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HomebaseGroupCard(group: group),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int daerahCount;
  final int totalAsesor;

  const _Header({
    required this.daerahCount,
    required this.totalAsesor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dikelompokkan per Daerah ($daerahCount daerah)',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total $totalAsesor asesor',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomebaseGroup {
  final String homebase;
  final List<AsesorHomebase> items;
  final int totalAssessments;

  const _HomebaseGroup({
    required this.homebase,
    required this.items,
    required this.totalAssessments,
  });
}

/// Own state → toggle only rebuilds this card, not the whole list.
class _HomebaseGroupCard extends StatefulWidget {
  final _HomebaseGroup group;

  const _HomebaseGroupCard({required this.group});

  @override
  State<_HomebaseGroupCard> createState() => _HomebaseGroupCardState();
}

class _HomebaseGroupCardState extends State<_HomebaseGroupCard> {
  static const int _previewLimit = 15;

  bool _expanded = false;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final visibleCount = !_expanded
        ? 0
        : (_showAll
            ? group.items.length
            : group.items.length.clamp(0, _previewLimit));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() {
              _expanded = !_expanded;
              if (!_expanded) _showAll = false;
            }),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.homebase,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${group.items.length} asesor · ${group.totalAssessments} asesmen',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${group.items.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            for (var i = 0; i < visibleCount; i++)
              _AsesorHomebaseTile(item: group.items[i]),
            if (!_showAll && group.items.length > _previewLimit)
              TextButton(
                onPressed: () => setState(() => _showAll = true),
                child: Text(
                  'Tampilkan semua (${group.items.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AsesorHomebaseTile extends StatelessWidget {
  final AsesorHomebase item;

  const _AsesorHomebaseTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = item.scheme.isNotEmpty ? item.scheme : '-';
    final name = item.name.isNotEmpty ? item.name : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.domain, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scheme,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.assessments} Asesmen',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

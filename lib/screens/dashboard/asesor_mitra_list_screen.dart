import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/asesor_dashboard_models.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../services/marketing/places_service.dart';
import '../../utils/date_format_helper.dart';
import '../../utils/url_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

Future<void> _openExternalUrl(String rawUrl) async {
  final resolved = UrlHelper.resolveUrl(rawUrl);
  final uri = Uri.tryParse(resolved);
  if (uri != null) {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
  }
}

class AsesorMitraListScreen extends StatefulWidget {
  final List<AsesorMitra>? mitra;

  const AsesorMitraListScreen({super.key, this.mitra});

  @override
  State<AsesorMitraListScreen> createState() => _AsesorMitraListScreenState();
}

class _AsesorMitraListScreenState extends State<AsesorMitraListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AsesorMitra> _allMitra = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'Semua'; // 'Semua', 'Aktif', 'Menunggu', 'Selesai'

  @override
  void initState() {
    super.initState();
    if (widget.mitra != null) {
      _allMitra = List<AsesorMitra>.from(widget.mitra!);
    } else {
      _fetchMitraData();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _fetchMitraData() async {
    setState(() => _isLoading = true);
    try {
      final dashboardData = await DashboardService.getAsesorDashboard();
      if (mounted) {
        setState(() {
          _allMitra = dashboardData.mitra;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error fetching asesor mitra data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AsesorMitra> get _filteredMitra {
    return _allMitra.where((item) {
      // 1. Status Filter
      if (_selectedStatus != 'Semua') {
        if (item.statusLabel.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // 2. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final nama = item.namaTuk.toLowerCase();
        final kota = item.kota.toLowerCase();
        final alamat = item.alamat.toLowerCase();
        final deskripsi = item.deskripsiMitra.toLowerCase();
        final proyeksi = item.proyeksiMitra.toLowerCase();
        final idStr = item.idTuk.toString();

        final match = nama.contains(_searchQuery) ||
            kota.contains(_searchQuery) ||
            alamat.contains(_searchQuery) ||
            deskripsi.contains(_searchQuery) ||
            proyeksi.contains(_searchQuery) ||
            idStr.contains(_searchQuery);

        if (!match) return false;
      }

      return true;
    }).toList();
  }

  int get _totalMitraCount => _allMitra.length;
  int get _activeMitraCount => _allMitra.where((m) => m.isAktif).length;
  int get _waitingMitraCount => _allMitra.where((m) => m.statusMitra == 0).length;
  int get _finishedMitraCount => _allMitra.where((m) => m.statusMitra == 2).length;

  int get _uniqueKotaCount {
    final kotas = _allMitra
        .map((m) => m.kota.trim().toLowerCase())
        .where((k) => k.isNotEmpty && k != '-')
        .toSet();
    return kotas.length;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final filtered = _filteredMitra;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Daftar Mitra',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchMitraData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryBanner(),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 12),
                          _buildFilterChips(),
                          const SizedBox(height: 16),
                          _buildListHeader(filtered.length),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _MitraCard(mitra: filtered[index]);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x202563EB),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jaringan Kemitraan TUK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola kemitraan Tempat Uji Kompetensi strategis',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBannerMetricItem(
                    label: 'Total Mitra',
                    value: '$_totalMitraCount',
                    icon: Icons.domain_rounded,
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0x26FFFFFF)),
                Expanded(
                  child: _buildBannerMetricItem(
                    label: 'Mitra Aktif',
                    value: '$_activeMitraCount',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0x26FFFFFF)),
                Expanded(
                  child: _buildBannerMetricItem(
                    label: 'Kota/Wilayah',
                    value: '$_uniqueKotaCount',
                    icon: Icons.location_city_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMetricItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF93C5FD)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFDBEAFE),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
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
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari mitra, TUK, kota, alamat...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () {
                  _searchController.clear();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'Semua', 'label': 'Semua', 'count': _totalMitraCount},
      {'key': 'Aktif', 'label': 'Aktif', 'count': _activeMitraCount},
      {'key': 'Menunggu', 'label': 'Menunggu', 'count': _waitingMitraCount},
      if (_finishedMitraCount > 0)
        {'key': 'Selesai', 'label': 'Selesai', 'count': _finishedMitraCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStatus == f['key'];
          final count = f['count'] as int;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStatus = f['key'] as String;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  ),
                  boxShadow: [
                    if (isSelected)
                      const BoxShadow(
                        color: Color(0x202563EB),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f['label'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0x33FFFFFF) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
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

  Widget _buildListHeader(int displayedCount) {
    final isFiltered = _searchQuery.isNotEmpty || _selectedStatus != 'Semua';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Daftar Mitra',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$displayedCount',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
        if (isFiltered)
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _selectedStatus = 'Semua';
              });
            },
            child: const Text(
              'Reset Filter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _searchQuery.isNotEmpty || _selectedStatus != 'Semua';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.handshake_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isFiltered ? 'Mitra Tidak Ditemukan' : 'Belum Ada Mitra Terdaftar',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFiltered
                ? 'Tidak ada mitra yang cocok dengan filter atau kata kunci pencarian "$_searchQuery".'
                : 'Daftar Tempat Uji Kompetensi yang bermitra dengan Anda akan muncul di sini.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedStatus = 'Semua';
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reset Pencarian'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MitraCard extends StatelessWidget {
  final AsesorMitra mitra;

  const _MitraCard({required this.mitra});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (mitra.statusMitra) {
      case 1:
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFDCFCE7);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 2:
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
        statusIcon = Icons.history_rounded;
        break;
      case 0:
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.access_time_rounded;
        break;
    }

    final formattedTanggal = mitra.tanggalBermitra.isNotEmpty
        ? DateFormatHelper.formatToIndonesian(mitra.tanggalBermitra)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AsesorMitraDetailScreen(mitra: mitra)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Title & ID + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mitra.namaTuk.isNotEmpty ? mitra.namaTuk : 'Mitra Kerjasama',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (mitra.idTuk > 0)
                            Text(
                              'ID TUK: #${mitra.idTuk}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            mitra.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Info Rows
                if (mitra.kota.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mitra.kota,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (mitra.alamat.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place_outlined, size: 15, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mitra.alamat,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      'Bermitra sejak: $formattedTanggal',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                // Proyeksi or Deskripsi Preview Snippet
                if (mitra.proyeksiMitra.isNotEmpty || mitra.deskripsiMitra.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          mitra.proyeksiMitra.isNotEmpty
                              ? Icons.trending_up_rounded
                              : Icons.info_outline_rounded,
                          size: 14,
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            mitra.proyeksiMitra.isNotEmpty
                                ? 'Target: ${mitra.proyeksiMitra}'
                                : mitra.deskripsiMitra,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Footer Row: Badges & Chevron Button
                Row(
                  children: [
                    // MoU Tag
                    if (mitra.hasMou)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description_outlined, size: 12, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text(
                              'MoU Siap',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link_off_rounded, size: 12, color: Color(0xFF94A3B8)),
                            SizedBox(width: 4),
                            Text(
                              'Belum Ada MoU',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 6),

                    // Map Status Tag
                    if (mitra.hasCoordinates)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined, size: 12, color: Color(0xFF059669)),
                            SizedBox(width: 4),
                            Text(
                              'Peta Siap',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Detail',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AsesorMitraDetailScreen extends StatefulWidget {
  final AsesorMitra mitra;

  const AsesorMitraDetailScreen({super.key, required this.mitra});

  @override
  State<AsesorMitraDetailScreen> createState() => _AsesorMitraDetailScreenState();
}

class _AsesorMitraDetailScreenState extends State<AsesorMitraDetailScreen> {
  double? _resolvedLat;
  double? _resolvedLng;
  String? _resolvedAddress;
  bool _isResolvingLocation = false;

  @override
  void initState() {
    super.initState();
    _initCoordinates();
  }

  void _initCoordinates() {
    if (widget.mitra.hasCoordinates) {
      _resolvedLat = widget.mitra.latitude;
      _resolvedLng = widget.mitra.longitude;
    } else {
      _resolveLocationFromAddress();
    }
  }

  Future<void> _resolveLocationFromAddress() async {
    final query = [
      if (widget.mitra.namaTuk.isNotEmpty) widget.mitra.namaTuk,
      if (widget.mitra.alamat.isNotEmpty) widget.mitra.alamat,
      if (widget.mitra.kota.isNotEmpty) widget.mitra.kota,
    ].join(', ').trim();

    if (query.isEmpty) return;

    setState(() => _isResolvingLocation = true);

    try {
      final results = await PlacesService.searchPlaces(
        query: query,
        filterRetail: false,
      );

      if (results.isNotEmpty && mounted) {
        final p = results.first;
        if (p.latitude != 0.0 && p.longitude != 0.0) {
          setState(() {
            _resolvedLat = p.latitude;
            _resolvedLng = p.longitude;
            _resolvedAddress = p.formattedAddress;
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error resolving location for mitra: $e');
    } finally {
      if (mounted) {
        setState(() => _isResolvingLocation = false);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final mitra = widget.mitra;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Detail Mitra Kerjasama',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderProfileCard(mitra),
                  const SizedBox(height: 14),
                  _buildInfoLembagaCard(mitra),
                  const SizedBox(height: 14),
                  _buildDetailKerjasamaCard(mitra),
                  const SizedBox(height: 14),
                  _buildDokumenMouCard(mitra),
                  const SizedBox(height: 14),
                  _buildPetaLokasiCard(mitra),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderProfileCard(AsesorMitra mitra) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (mitra.statusMitra) {
      case 1:
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFDCFCE7);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 2:
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
        statusIcon = Icons.history_rounded;
        break;
      case 0:
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.access_time_rounded;
        break;
    }

    final formattedTanggal = mitra.tanggalBermitra.isNotEmpty
        ? DateFormatHelper.formatToIndonesian(mitra.tanggalBermitra)
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mitra.namaTuk.isNotEmpty ? mitra.namaTuk : 'Mitra Kerjasama',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                mitra.statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (mitra.idTuk > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ID TUK: #${mitra.idTuk}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                'Terdaftar Bermitra: $formattedTanggal',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLembagaCard(AsesorMitra mitra) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.domain_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Informasi Lembaga & TUK',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailItem(
            label: 'Nama Tempat Uji (TUK)',
            value: mitra.namaTuk.isNotEmpty ? mitra.namaTuk : '-',
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Kota / Kabupaten',
            value: mitra.kota.isNotEmpty ? mitra.kota : '-',
            icon: Icons.location_city_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Alamat Lengkap',
            value: mitra.alamat.isNotEmpty ? mitra.alamat : '-',
            icon: Icons.place_rounded,
            onCopy: mitra.alamat.isNotEmpty
                ? () => _copyToClipboard(mitra.alamat, 'Alamat')
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailKerjasamaCard(AsesorMitra mitra) {
    final formattedTanggal = mitra.tanggalBermitra.isNotEmpty
        ? DateFormatHelper.formatToIndonesian(mitra.tanggalBermitra)
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Detail Kerjasama & Proyeksi',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailItem(
            label: 'Tanggal Mulai Kerjasama',
            value: formattedTanggal,
            icon: Icons.event_available_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Status Kemitraan',
            value: mitra.statusLabel,
            icon: Icons.verified_user_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Deskripsi Kemitraan',
            value: mitra.deskripsiMitra.isNotEmpty ? mitra.deskripsiMitra : '-',
            icon: Icons.notes_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Proyeksi & Potensi Asesi',
            value: mitra.proyeksiMitra.isNotEmpty ? mitra.proyeksiMitra : '-',
            icon: Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenMouCard(AsesorMitra mitra) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Dokumen Perjanjian (MoU)',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          if (mitra.hasMou) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nota Kesepahaman (MoU) Resmi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dokumen perjanjian kemitraan TUK & Asesor',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openExternalUrl(mitra.linkMouMitra),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text(
                  'Buka Dokumen MoU',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tautan dokumen MoU belum diunggah untuk kemitraan ini.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetaLokasiCard(AsesorMitra mitra) {
    final lat = _resolvedLat;
    final lng = _resolvedLng;
    final hasValidCoordinates = lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded, size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lokasi & Peta TUK',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (_isResolvingLocation)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Navigasi dan titik lokasi tempat uji kompetensi mitra.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          if (_isResolvingLocation)
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Menemukan lokasi berdasarkan alamat...',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else if (hasValidCoordinates) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('mitra-${mitra.id}'),
                      position: LatLng(lat, lng),
                      infoWindow: InfoWindow(
                        title: mitra.namaTuk.isNotEmpty ? mitra.namaTuk : 'TUK Mitra',
                        snippet: _resolvedAddress ?? mitra.alamat,
                      ),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openExternalUrl('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
                    icon: const Icon(Icons.map_outlined, size: 15),
                    label: const Text('Buka Maps', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openExternalUrl('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
                    icon: const Icon(Icons.directions_rounded, size: 15),
                    label: const Text('Petunjuk Arah', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_off_rounded, color: Color(0xFF94A3B8), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Koordinat peta belum tersimpan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Anda dapat mencari dan membuka lokasi secara manual melalui Google Maps menggunakan nama dan alamat mitra.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final searchQuery = [
                          if (mitra.namaTuk.isNotEmpty) mitra.namaTuk,
                          if (mitra.alamat.isNotEmpty) mitra.alamat,
                          if (mitra.kota.isNotEmpty) mitra.kota,
                        ].join(' ');
                        _openExternalUrl(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}',
                        );
                      },
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: const Text('Cari Alamat di Google Maps', style: TextStyle(fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF475569)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
            onPressed: onCopy,
            tooltip: 'Salin',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../services/asesi/permohonan_service.dart';
import '../../utils/date_format_helper.dart';
import 'detail_permohonan_screen.dart';

class PermohonanPendaftaranScreen extends StatefulWidget {
  const PermohonanPendaftaranScreen({super.key});

  @override
  State<PermohonanPendaftaranScreen> createState() =>
      _PermohonanPendaftaranScreenState();
}

class _PermohonanPendaftaranScreenState
    extends State<PermohonanPendaftaranScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> _allData = [];
  List<Map<String, String>> _filteredData = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: Semua, 1: Terverifikasi, 2: Menunggu

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final realData = await PermohonanService.getPermohonanList();
      if (!mounted) return;
      setState(() {
        _allData = realData;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredData = _allData.where((item) {
        final status = (item['status'] ?? '').toLowerCase();
        final isVerified =
            status.contains('terverifikasi') || status.contains('terferivikasi');

        // Check filter tab
        if (_selectedFilterIndex == 1 && !isVerified) return false;
        if (_selectedFilterIndex == 2 && isVerified) return false;

        // Check search query
        if (query.isNotEmpty) {
          final nama = (item['nama'] ?? '').toLowerCase();
          final skema = (item['skema'] ?? '').toLowerCase();
          final tanggal = (item['tanggal'] ?? '').toLowerCase();
          final tuk = (item['tuk'] ?? '').toLowerCase();
          return nama.contains(query) ||
              skema.contains(query) ||
              tanggal.contains(query) ||
              tuk.contains(query);
        }
        return true;
      }).toList();
    });
  }

  int get _verifiedCount => _allData
      .where((e) =>
          (e['status'] ?? '').toLowerCase().contains('terverifikasi') ||
          (e['status'] ?? '').toLowerCase().contains('terferivikasi'))
      .length;

  int get _pendingCount => _allData.length - _verifiedCount;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Permohonan Pendaftaran',
              onBack: () => Navigator.pop(context),
            ),
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari nama, skema, atau TUK...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 18,
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Pill Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterPill(
                          index: 0,
                          label: 'Semua',
                          count: _allData.length,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          index: 1,
                          label: 'Terverifikasi',
                          count: _verifiedCount,
                          badgeColor: const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          index: 2,
                          label: 'Menunggu',
                          count: _pendingCount,
                          badgeColor: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Main List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF2563EB),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFF2563EB),
                      child: _filteredData.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.45,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.assignment_outlined,
                                            size: 32,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Tidak ada data permohonan',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Coba gunakan kata kunci pencarian yang lain',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                              itemCount: _filteredData.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _filteredData[index];
                                return _buildPermohonanCard(context, item);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required int index,
    required String label,
    required int count,
    Color? badgeColor,
  }) {
    final isSelected = _selectedFilterIndex == index;
    final containerColor =
        isSelected ? const Color(0xFF2563EB) : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFF64748B);
    final borderColor =
        isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilterIndex = index);
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1A2563EB),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (badgeColor ?? const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (badgeColor != null
                          ? Colors.white
                          : const Color(0xFF475569)),
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermohonanCard(BuildContext context, Map<String, String> item) {
    final nama = item['nama'] ?? '-';
    final skema = item['skema'] ?? '-';
    final tuk = (item['tuk'] != null && item['tuk']!.isNotEmpty)
        ? item['tuk']!
        : '-';
    final rawDate = item['tanggal'] ?? '';
    final rawJam = item['jam'] ?? '';
    final status = (item['status'] ?? '').toLowerCase();
    final isVerified =
        status.contains('terverifikasi') || status.contains('terferivikasi');

    String formattedDate = '-';
    if (rawDate.isNotEmpty) {
      formattedDate = DateFormatHelper.formatToIndonesian(rawDate);
      if (formattedDate == '-') formattedDate = rawDate;
    }
    final dateTimeString = rawJam.isNotEmpty
        ? '$formattedDate • $rawJam WIB'
        : formattedDate;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPermohonanScreen(itemData: item),
            ),
          );
          _loadData();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Avatar + Nama + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(nama),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item['id'] != null && item['id']!.isNotEmpty)
                          Text(
                            'ID Permohonan: #${item['id']}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isVerified
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVerified
                              ? Icons.check_circle_outline_rounded
                              : Icons.hourglass_empty_rounded,
                          size: 12,
                          color: isVerified
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVerified ? 'Terverifikasi' : 'Menunggu',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isVerified
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Skema Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 15,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      skema,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // TUK Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TUK: $tuk',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Footer: Tanggal + Action CTA
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF8FAFC)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dateTimeString,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 15,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

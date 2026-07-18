import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/jadwal/custom_tab_bar.dart';
import '../../widgets/penugasan/penugasan_list_item.dart';
import '../../models/jadwal_models.dart';
import '../../services/auth_repository.dart';
import '../../services/api_service.dart';
import '../../helpers/api_routes.dart';
import 'penugasan_detail_screen.dart';

class PenugasanScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const PenugasanScreen({super.key, this.onBackToHome});

  @override
  State<PenugasanScreen> createState() => _PenugasanScreenState();
}

class _PenugasanScreenState extends State<PenugasanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMonthYear = 'Mei 2025';
  bool _isLoading = true;
  String _errorMessage = '';

  // List of Indonesian months for the month picker dialog
  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final List<String> _years = ['2025', '2026', '2027'];

  // All schedules loaded from the API
  List<JadwalItem> _allAssignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    // Set default month & year to current month & year
    final now = DateTime.now();
    final currentMonthName = _months[now.month - 1];
    final shortMonth = currentMonthName == 'Mei' ? 'Mei' : currentMonthName.substring(0, 3);
    _selectedMonthYear = '$shortMonth ${now.year}';

    _loadPenugasanData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPenugasanData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch in parallel for Menunggu (0), Selesai/Pelaporan (1,4), and Dibatalkan (2)
      final results = await Future.wait([
        ApiService.getJadwalList(
          limit: 100,
          statusJadwal: '0', // Menunggu
          customRoutePath: ApiRoutes.asesorJadwal,
        ),
        ApiService.getJadwalList(
          limit: 100,
          statusJadwal: '1,4', // Selesai / Pelaporan
          customRoutePath: ApiRoutes.asesorJadwal,
        ),
        ApiService.getJadwalList(
          limit: 100,
          statusJadwal: '2', // Dibatalkan
          customRoutePath: ApiRoutes.asesorJadwal,
        ),
      ]);

      // Merge and sort all results
      final merged = [...results[0], ...results[1], ...results[2]];
      
      // Sort: latest date first
      merged.sort((a, b) => b.tanggalMulai.compareTo(a.tanggalMulai));

      setState(() {
        _allAssignments = merged;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading penugasan data: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data penugasan.';
        _isLoading = false;
      });
    }
  }

  bool _matchesMonthYear(String dateStr) {
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return true;

      final parts = _selectedMonthYear.split(' ');
      if (parts.length < 2) return true;

      final selectedMonthName = parts[0].toLowerCase();
      final selectedYear = int.tryParse(parts[1]) ?? dt.year;

      int monthNum = -1;
      for (int i = 0; i < _months.length; i++) {
        final mLower = _months[i].toLowerCase();
        if (mLower.startsWith(selectedMonthName) || selectedMonthName.startsWith(mLower.substring(0, 3))) {
          monthNum = i + 1;
          break;
        }
      }

      return dt.month == monthNum && dt.year == selectedYear;
    } catch (e) {
      return true;
    }
  }

  // Filter list based on the active tab index and selected month-year
  List<JadwalItem> _getFilteredAssignments() {
    List<JadwalItem> filteredByTab;
    switch (_tabController.index) {
      case 1: // Menunggu
        filteredByTab = _allAssignments
            .where((item) => item.status == 'draft' || item.status == 'waiting')
            .toList();
        break;
      case 2: // Selesai
        filteredByTab = _allAssignments
            .where(
              (item) => item.status == 'completed' || item.status == 'canceled' || item.status == 'pelaporan',
            )
            .toList();
        break;
      case 0: // Semua
      default:
        filteredByTab = _allAssignments;
        break;
    }

    // Apply month & year filter
    return filteredByTab.where((item) => _matchesMonthYear(item.tanggalMulai)).toList();
  }

  // Opens a custom premium month/year picker bottom sheet
  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempMonth = _selectedMonthYear.split(' ')[0];
        String tempYear = _selectedMonthYear.split(' ')[1];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Periode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      children: [
                        // Months Scroll
                        Expanded(
                          child: ListWheelScrollView(
                            itemExtent: 40,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempMonth = _months[index].substring(0, 3);
                                if (_months[index] == 'Mei') tempMonth = 'Mei';
                              });
                            },
                            controller: FixedExtentScrollController(
                              initialItem: _months.indexWhere(
                                (m) =>
                                    m.toLowerCase().startsWith(tempMonth.toLowerCase()) || m == tempMonth,
                              ),
                            ),
                            children: _months.map((m) {
                              final isSel =
                                  m.toLowerCase().startsWith(tempMonth.toLowerCase()) || m == tempMonth;
                              return Center(
                                child: Text(
                                  m,
                                  style: TextStyle(
                                    fontSize: isSel ? 16 : 14,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSel
                                        ? const Color(0xFF2C6C9C)
                                        : Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Years Scroll
                        Expanded(
                          child: ListWheelScrollView(
                            itemExtent: 40,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempYear = _years[index];
                              });
                            },
                            controller: FixedExtentScrollController(
                              initialItem: _years.indexOf(tempYear),
                            ),
                            children: _years.map((y) {
                              final isSel = y == tempYear;
                              return Center(
                                child: Text(
                                  y,
                                  style: TextStyle(
                                    fontSize: isSel ? 16 : 14,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSel
                                        ? const Color(0xFF2C6C9C)
                                        : Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C6C9C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedMonthYear = '$tempMonth $tempYear';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE5F1FC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_late_outlined,
                color: Color(0xFF2C6C9C),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tidak ada penugasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada jadwal penugasan ditemukan pada periode $_selectedMonthYear.',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPenugasanData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C6C9C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final filteredList = _getFilteredAssignments();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Custom Header
          CustomAppBar(
            title: 'Penugasan',
            onBack: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),

          // Custom TabBar Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TabItem(
                    label: 'Semua',
                    isSelected: _tabController.index == 0,
                    onTap: () => _tabController.animateTo(0),
                    usePillStyle: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TabItem(
                    label: 'Menunggu',
                    isSelected: _tabController.index == 1,
                    onTap: () => _tabController.animateTo(1),
                    usePillStyle: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TabItem(
                    label: 'Selesai',
                    isSelected: _tabController.index == 2,
                    onTap: () => _tabController.animateTo(2),
                    usePillStyle: true,
                  ),
                ),
              ],
            ),
          ),

          // Month Selection Button Container
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: GestureDetector(
              onTap: _showMonthYearPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFF2C6C9C),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedMonthYear,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // List content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : RefreshIndicator(
                        onRefresh: _loadPenugasanData,
                        child: filteredList.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final item = filteredList[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: PenugasanListItem(
                                      item: item,
                                      onTap: () => _navigateToDetail(item),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  // Handles clicking "Lihat Detail"
  void _navigateToDetail(JadwalItem item) {
    final user = AuthRepository.currentUserInstance;
    final role = UserRole(
      role: user?.role ?? 'asesor',
      name: user?.name ?? 'Eko Setiabudi',
      email: user?.email ?? 'eko.setiabudi@lsp.com',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PenugasanDetailScreen(jadwal: item, userRole: role),
      ),
    );
  }
}

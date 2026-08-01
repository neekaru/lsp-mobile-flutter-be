import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/asesor_service.dart';
import 'detail_honor_screen.dart';

class HonorAsesorScreen extends StatefulWidget {
  const HonorAsesorScreen({super.key});

  @override
  State<HonorAsesorScreen> createState() => _HonorAsesorScreenState();
}

class _HonorAsesorScreenState extends State<HonorAsesorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedMonth = 'Juli 2026';
  bool _isLoading = false;
  final List<String> _availableMonths = ['Semua', 'Juli 2026', 'Juni 2026', 'Mei 2026'];
  List<Map<String, dynamic>> _honorItems = [];

  // Default Mock Data matching user reference design
  final List<Map<String, dynamic>> _defaultHonorItems = [
    {
      'id': 1,
      'nama_asesor': 'Karina',
      'tipe_asesor': 'Asessor Internal',
      'judul_asesmen': 'Sertifikasi Software Development',
      'skema': 'Skema Programmer',
      'honor': 'Rp 2.250.000',
      'status': 'Selesai',
      'tanggal': '20 Juli 2026',
      'tuk': 'TUK Sewaktu',
      'jumlah_asesi': 15,
      'metode_pembayaran': 'Transfer Bank',
      'tanggal_pembayaran': '20 Juli 2026',
      'no_transfer': 'PAY-20260720-001',
    },
    {
      'id': 2,
      'nama_asesor': 'Eko Setiabudi',
      'tipe_asesor': 'Asessor Internal',
      'judul_asesmen': 'Sertifikasi Data Science',
      'skema': 'Skema Data Science',
      'honor': 'Rp 2.250.000',
      'status': 'Selesai',
      'tanggal': '19 Juli 2026',
      'tuk': 'TUK Sewaktu',
      'jumlah_asesi': 12,
      'metode_pembayaran': 'Transfer Bank',
      'tanggal_pembayaran': '19 Juli 2026',
      'no_transfer': 'PAY-20260719-002',
    },
    {
      'id': 3,
      'nama_asesor': 'Sintia Alia',
      'tipe_asesor': 'Asessor Eksternal',
      'judul_asesmen': 'Sertifikasi Cyber Security',
      'skema': 'Skema Cyber Security',
      'honor': 'Rp 2.250.000',
      'status': 'Selesai',
      'tanggal': '18 Juli 2026',
      'tuk': 'TUK Tempat Kerja',
      'jumlah_asesi': 10,
      'metode_pembayaran': 'Transfer Bank',
      'tanggal_pembayaran': '18 Juli 2026',
      'no_transfer': 'PAY-20260718-003',
    },
    {
      'id': 4,
      'nama_asesor': 'Santirya',
      'tipe_asesor': 'Asessor Eksternal',
      'judul_asesmen': 'Sertifikasi Network Administrator',
      'skema': 'Skema Network Administrator',
      'honor': 'Rp 2.250.000',
      'status': 'Selesai',
      'tanggal': '17 Juli 2026',
      'tuk': 'TUK Tempat Kerja',
      'jumlah_asesi': 14,
      'metode_pembayaran': 'Transfer Bank',
      'tanggal_pembayaran': '17 Juli 2026',
      'no_transfer': 'PAY-20260717-004',
    },
    {
      'id': 5,
      'nama_asesor': 'Ahmad Hidayat',
      'tipe_asesor': 'Asessor Internal',
      'judul_asesmen': 'Sertifikasi Digital Marketing',
      'skema': 'Skema Digital Marketing',
      'honor': 'Rp 1.800.000',
      'status': 'Menunggu',
      'tanggal': '22 Juli 2026',
      'tuk': 'TUK Mandiri',
      'jumlah_asesi': 8,
      'metode_pembayaran': 'Transfer Bank',
      'tanggal_pembayaran': 'Pending',
      'no_transfer': '-',
    },
    {
      'id': 6,
      'nama_asesor': 'Dewi Lestari',
      'tipe_asesor': 'Asessor Eksternal',
      'judul_asesmen': 'Sertifikasi UI/UX Designer',
      'skema': 'Skema UI/UX Designer',
      'honor': 'Rp 2.500.000',
      'status': 'Menunggu',
      'tanggal': '23 Juli 2026',
      'tuk': 'TUK Pusat',
      'jumlah_asesi': 16,
      'metode_pembayaran': 'Transfer Bank',
      'tanggal_pembayaran': 'Pending',
      'no_transfer': '-',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _honorItems = List.from(_defaultHonorItems);
    _fetchHonorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHonorData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = _selectedMonth == 'Semua'
          ? await AsesorService.getHonorList()
          : await AsesorService.getHonorList(_selectedMonth);
      if (mounted && res != null && res['rincian'] != null) {
        final List<dynamic> list = res['rincian'];
        if (list.isNotEmpty) {
          setState(() {
            _honorItems = list.map((item) {
              final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map);
              return {
                ...map,
                'nama_asesor': map['nama_asesor'] ?? map['judul_asesmen'] ?? 'Asesor',
                'tipe_asesor': map['tipe_asesor'] ?? map['skema'] ?? 'Asessor Internal',
                'honor': map['honor'] ?? 'Rp 0',
                'status': map['status'] ?? 'Selesai',
              };
            }).toList();
          });
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Periode Bulan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  ..._availableMonths.map((monthName) {
                    final isSelected = monthName == _selectedMonth;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                      ),
                      title: Text(
                        monthName,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF0F172A),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF3B82F6),
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedMonth = monthName;
                        });
                        Navigator.pop(context);
                        _fetchHonorData();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    List<Map<String, dynamic>> result = List.from(_honorItems);

    // Filter by tab index (0: Semua, 1: Menunggu, 2: Selesai)
    if (_tabController.index == 1) {
      result = result.where((item) {
        final st = (item['status'] ?? '').toString().toLowerCase();
        return st == 'menunggu' || st == 'pending';
      }).toList();
    } else if (_tabController.index == 2) {
      result = result.where((item) {
        final st = (item['status'] ?? '').toString().toLowerCase();
        return st == 'selesai' || st == 'complete';
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((item) {
        final nama = (item['nama_asesor'] ?? '').toString().toLowerCase();
        final tipe = (item['tipe_asesor'] ?? '').toString().toLowerCase();
        final skema = (item['skema'] ?? item['judul_asesmen'] ?? '').toString().toLowerCase();
        return nama.contains(q) || tipe.contains(q) || skema.contains(q);
      }).toList();
    }

    return result;
  }

  void _navigateToHonorDetail(Map<String, dynamic> item) {
    final String status = item['status'] ?? 'Selesai';
    final String metodePembayaran = item['metode_pembayaran'] ?? 'Transfer Bank';
    final String tanggalPembayaran =
        item['tanggal_pembayaran'] ?? item['tanggal'] ?? '20 Juli 2026';
    final String noTransfer = item['no_transfer'] ?? 'PAY-20260720-001';
    final int jumlahAsesmen = item['jumlah_asesi'] ?? item['jumlah_asesmen'] ?? 4;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHonorScreen(
          detail: item,
          status: status,
          metodePembayaran: metodePembayaran,
          tanggalPembayaran: tanggalPembayaran,
          noTransfer: noTransfer,
          jumlahAsesmen: jumlahAsesmen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final filteredList = _getFilteredItems();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Header
          CustomAppBar(
            title: 'Honor Asessor',
            onBack: () => Navigator.of(context).pop(),
            rightWidget: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
              onSelected: (val) {
                if (val == 'refresh') {
                  _fetchHonorData();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Text('Refresh Data', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs Row (Matching Jadwal Pill Style)
          _buildPillTabs(),

          // Search & Date Filter Row
          _buildSearchAndFilterRow(),
          const SizedBox(height: 12),

          // Loading bar or List Content
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchHonorData,
              color: const Color(0xFF378CE7),
              child: filteredList.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Data honor tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildHonorCard(item);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPillTab(index: 0, label: 'Semua'),
          const SizedBox(width: 8),
          _buildPillTab(index: 1, label: 'Menunggu'),
          const SizedBox(width: 8),
          _buildPillTab(index: 2, label: 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildPillTab({required int index, required String label}) {
    final isSelected = _tabController.index == index;
    final containerColor = isSelected ? const Color(0xFF6C8BB4) : const Color(0xFFD2E3F4);
    final textColor = isSelected ? Colors.white : const Color(0xFF5A7EAA);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Search TextField
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari nama asesor/skema',
                  hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Month Picker Button
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF475569),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedMonth,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
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

  Widget _buildHonorCard(Map<String, dynamic> item) {
    final String nama = item['nama_asesor'] ?? item['judul_asesmen'] ?? 'Asesor';
    final String tipe = item['tipe_asesor'] ?? item['skema'] ?? 'Asessor Internal';
    final String honor = item['honor'] ?? 'Rp 0';
    final String status = item['status'] ?? 'Selesai';
    final bool isSelesai = status.toLowerCase() == 'selesai' || status.toLowerCase() == 'complete';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _navigateToHonorDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name & Type
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
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tipe,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Honor Amount & Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      honor,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelesai ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSelesai ? 'Selesai' : 'Menunggu',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelesai ? const Color(0xFF10B981) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
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
    );
  }
}

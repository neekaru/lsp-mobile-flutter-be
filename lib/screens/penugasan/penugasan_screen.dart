import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/jadwal/custom_tab_bar.dart';
import '../../widgets/jadwal/jadwal_list_item.dart';
import '../../models/jadwal_models.dart';
import '../../services/auth_repository.dart';
import '../jadwal/jadwal_detail_screen.dart';

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

  // Hardcoded dummy data matching the user's screenshot
  late final List<JadwalItem> _allAssignments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _allAssignments = [
      const JadwalItem(
        id: 101,
        skema:
            'UI/UX Design', // Professionally corrected spelling, detail screen maps to UI/UX Design
        tuk: 'LPP Cahaya Borneo',
        tanggalMulai: '2026-07-20',
        tanggalSelesai: '2026-07-20',
        status: 'waiting', // Waiting
        jumlahAsesi: 10,
        asesor: ['Eko Setiabudi'],
        totalAsesi: 10,
      ),
      const JadwalItem(
        id: 102,
        skema: 'Digital Marketing',
        tuk: 'LPP Jogja',
        tanggalMulai: '2026-07-20',
        tanggalSelesai: '2026-07-20',
        status: 'completed', // Completed
        jumlahAsesi: 10,
        asesor: ['Eko Setiabudi'],
        totalAsesi: 10,
      ),
      const JadwalItem(
        id: 103,
        skema: 'Digital Marketing',
        tuk: 'LPP Jogja',
        tanggalMulai: '2026-07-20',
        tanggalSelesai: '2026-07-20',
        status: 'canceled', // Canceled
        jumlahAsesi: 10,
        asesor: ['Eko Setiabudi'],
        totalAsesi: 10,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filter dummy list based on the active tab index
  List<JadwalItem> _getFilteredAssignments() {
    switch (_tabController.index) {
      case 1: // Menunggu
        return _allAssignments
            .where((item) => item.status == 'waiting')
            .toList();
      case 2: // Selesai
        return _allAssignments
            .where(
              (item) => item.status == 'completed' || item.status == 'canceled',
            )
            .toList();
      case 0: // Semua
      default:
        return _allAssignments;
    }
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
                                    m.startsWith(tempMonth) || m == tempMonth,
                              ),
                            ),
                            children: _months.map((m) {
                              final isSel =
                                  m.startsWith(tempMonth) || m == tempMonth;
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
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: JadwalListItem(
                    item: item,
                    onTap: () => _navigateToDetail(item),
                  ),
                );
              },
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
        builder: (context) => JadwalDetailScreen(jadwal: item, userRole: role),
      ),
    );
  }
}

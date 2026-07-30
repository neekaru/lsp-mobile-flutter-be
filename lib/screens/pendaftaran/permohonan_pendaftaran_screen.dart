import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'detail_permohonan_screen.dart';

class PermohonanPendaftaranScreen extends StatefulWidget {
  const PermohonanPendaftaranScreen({super.key});

  @override
  State<PermohonanPendaftaranScreen> createState() => _PermohonanPendaftaranScreenState();
}

class _PermohonanPendaftaranScreenState extends State<PermohonanPendaftaranScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allData = [
    {
      'tanggal': '20/07/2026',
      'jam': '09:03:54',
      'nama': 'Aldi Taher',
      'skema': 'Digital Marketing',
      'status': 'Terverifikasi',
    },
    {
      'tanggal': '20/07/2026',
      'jam': '09:03:54',
      'nama': 'Aldi Taher',
      'skema': 'Digital Marketing',
      'status': 'Terverifikasi',
    },
    {
      'tanggal': '20/07/2026',
      'jam': '09:03:54',
      'nama': 'Aldi Taher',
      'skema': 'Digital Marketing',
      'status': '',
    },
    {
      'tanggal': '20/07/2026',
      'jam': '09:03:54',
      'nama': 'Aldi Taher',
      'skema': 'Digital Marketing',
      'status': 'Terverifikasi',
    },
    {
      'tanggal': '20/07/2026',
      'jam': '09:03:54',
      'nama': 'Aldi Taher',
      'skema': 'Digital Marketing',
      'status': 'Terverifikasi',
    },
    {
      'tanggal': '20/07/2026',
      'jam': '09:03:54',
      'nama': 'Aldi Taher',
      'skema': 'Digital Marketing',
      'status': 'Terverifikasi',
    },
    {
      'tanggal': '20/07/2026',
      'jam': '09:03:54',
      'nama': 'Aldi Taher',
      'skema': 'Digital Marketing',
      'status': '',
    },
  ];

  List<Map<String, String>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(_allData);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredData = List.from(_allData);
      } else {
        _filteredData = _allData.where((item) {
          final nama = item['nama']?.toLowerCase() ?? '';
          final skema = item['skema']?.toLowerCase() ?? '';
          final tanggal = item['tanggal']?.toLowerCase() ?? '';
          return nama.contains(query) || skema.contains(query) || tanggal.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Permohonan',
              onBack: () => Navigator.pop(context),
            ),

          // Main Body Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // Search Bar
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Cari data peserta',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Table Header Row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Tanggal Daftar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Nama',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Skema',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // List of Items
                  Expanded(
                    child: _filteredData.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada data peserta',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filteredData.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _filteredData[index];
                              final isVerified = item['status'] == 'Terverifikasi';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPermohonanScreen(itemData: item),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Tanggal & Jam
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              item['tanggal'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['jam'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      // Nama
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          item['nama'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      // Skema
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          item['skema'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      // Status Badge
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: isVerified
                                              ? Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFD1FAE5),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Text(
                                                    'Terverifikasi',
                                                    style: TextStyle(
                                                      color: Color(0xFF10B981),
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

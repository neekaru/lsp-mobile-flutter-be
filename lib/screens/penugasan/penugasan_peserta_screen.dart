import 'package:flutter/material.dart';
import '../../models/jadwal_models.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'penugasan_detail_peserta_screen.dart';

class PenugasanPesertaScreen extends StatefulWidget {
  final int jadwalId;
  final String jadwalTitle;
  final String? tanggal;
  final String? waktu;
  final String? tuk;

  const PenugasanPesertaScreen({
    super.key,
    required this.jadwalId,
    required this.jadwalTitle,
    this.tanggal,
    this.waktu,
    this.tuk,
  });

  @override
  State<PenugasanPesertaScreen> createState() => _PenugasanPesertaScreenState();
}

class _PenugasanPesertaScreenState extends State<PenugasanPesertaScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  AsesiListResponse? _response;
  List<AsesiItem> _filteredAsesi = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAsesiData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAsesiData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await ApiService.getAsesiList(widget.jadwalId);
      setState(() {
        _response = data;
        _filteredAsesi = data.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data asesi. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (_response == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredAsesi = _response!.data;
      } else {
        _filteredAsesi = _response!.data
            .where((asesi) => asesi.namaLengkap.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Color _getBadgeBgColor(String? status) {
    if (status == 'K') {
      return const Color(0xFFE8F5E9); // Green light
    } else if (status == 'BK') {
      return const Color(0xFFFFEBEE); // Red light
    } else {
      return const Color(0xFFFFF8E1); // Amber light
    }
  }

  Color _getBadgeTextColor(String? status) {
    if (status == 'K') {
      return const Color(0xFF2E7D32); // Green dark
    } else if (status == 'BK') {
      return const Color(0xFFC62828); // Red dark
    } else {
      return const Color(0xFFF57F17); // Amber dark
    }
  }

  String _getBadgeText(String? status) {
    if (status == 'K') {
      return 'Kompeten';
    } else if (status == 'BK') {
      return 'Belum Kompeten';
    } else {
      return 'Belum Dinilai';
    }
  }

  String _formatIndonesianDayAndDate(String yyyymmdd) {
    try {
      final dt = DateTime.tryParse(yyyymmdd);
      if (dt == null) return yyyymmdd;
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    } catch (e) {
      return yyyymmdd;
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light grey matching mockup search bar
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: 'Cari nama peserta',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    // Format the date/time beautifully
    final String dateStr = widget.tanggal != null && widget.tanggal!.isNotEmpty
        ? _formatIndonesianDayAndDate(widget.tanggal!)
        : '24 Juli 2026';
    final String timeStr = widget.waktu ?? '09:00 - 12:00 WIB';
    final String displayDateTime = '$dateStr, $timeStr';
    final String displayTuk = widget.tuk ?? 'LPP Cahaya Borneo';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Blue illustration image/container
            Container(
              width: 70,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5F1FC), Color(0xFFCBE0F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.assignment_rounded,
                color: Color(0xFF2C6C9C),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            
            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jadwalTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayDateTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          displayTuk,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsesiItem(AsesiItem item) {
    final hasRec = item.hasilRekomendasi;
    // API list asesi belum expose kota; jangan hardcode mock city
    final city = item.kota?.trim().isNotEmpty == true
        ? item.kota!.trim()
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Grey Circle Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9), // Light grey circle background
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF94A3B8), // Grey user silhouette
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Name and Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaLengkap,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      city,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Recommendation badge
          if (hasRec != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getBadgeBgColor(hasRec),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getBadgeText(hasRec),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: _getBadgeTextColor(hasRec),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Blue Chevron Right matching mockup
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF3B82F6), // Blue arrow
            size: 24,
          ),
        ],
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
              onPressed: _fetchAsesiData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FD8),
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

  Widget _buildEmptyWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F1FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: Color(0xFF2C6C9C),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada asesi ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pastikan kata kunci pencarian Anda benar.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          CustomAppBar(
            title: 'Daftar Peserta',
            rightWidget: const SizedBox(width: 32),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : RefreshIndicator(
                        onRefresh: _fetchAsesiData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Bar
                              _buildSearchBar(),
                              
                              const SizedBox(height: 12),

                              // Scheme Header Card
                              _buildHeaderCard(),

                              const SizedBox(height: 16),

                              // List of candidates
                              if (_filteredAsesi.isEmpty)
                                _buildEmptyWidget()
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: _filteredAsesi.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredAsesi[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PenugasanDetailPesertaScreen(
                                              asesi: item,
                                              jadwalTitle: widget.jadwalTitle,
                                              jadwalId: widget.jadwalId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildAsesiItem(item),
                                    );
                                  },
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

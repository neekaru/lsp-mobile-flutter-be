import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/jadwal_models.dart';
import '../../services/api_service.dart';
import '../asesi/asesor_detail_asesi_screen.dart';

class AsesiListScreen extends StatefulWidget {
  final int jadwalId;
  final String jadwalTitle;
  final String? tanggal;
  final String? waktu;
  final String? tuk;

  const AsesiListScreen({
    super.key,
    required this.jadwalId,
    required this.jadwalTitle,
    this.tanggal,
    this.waktu,
    this.tuk,
  });

  @override
  State<AsesiListScreen> createState() => _AsesiListScreenState();
}

class _AsesiListScreenState extends State<AsesiListScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  AsesiListResponse? _response;
  List<AsesiItem> _filteredAsesi = [];
  final Map<int, String> _rekomendasiMap = {};
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
        _rekomendasiMap.clear();
        for (final asesi in data.data) {
          final code = asesi.rekomendasiAsesor ??
              (asesi.hasilRekomendasi == 'K'
                  ? '1'
                  : (asesi.hasilRekomendasi == 'BK' ? '2' : '0'));
          _rekomendasiMap[asesi.id] = code;
        }
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
            .where((asesi) =>
                asesi.namaLengkap.toLowerCase().contains(query) ||
                (asesi.nik != null && asesi.nik!.contains(query)) ||
                (asesi.noPeserta != null && asesi.noPeserta!.contains(query)))
            .toList();
      }
    });
  }

  Future<void> _saveRekomendasiKolektif() async {
    if (_rekomendasiMap.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final List<Map<String, dynamic>> pesertaPayload = [];
      _rekomendasiMap.forEach((asesiId, rekom) {
        pesertaPayload.add({
          'asesi_id': asesiId,
          'rekomendasi': rekom,
        });
      });

      final success = await ApiService.updateRekomendasiKolektif(
        jadwalId: widget.jadwalId,
        peserta: pesertaPayload,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rekomendasi kolektif berhasil disimpan!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        _fetchAsesiData();
      } else {
        throw Exception('Gagal menyimpan rekomendasi');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          // Premium Gradient Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5B9FD8), Color(0xFF4FA8E8)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Daftar Peserta & Rekomendasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : RefreshIndicator(
                        onRefresh: _fetchAsesiData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Schedule details reference
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1FC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFB3D7F4),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jadwal Sertifikasi',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF2C6C9C),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.jadwalTitle,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B4D70),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Summary statistics card
                              if (_response != null)
                                _buildSummaryCard(_response!.meta),

                              const SizedBox(height: 16),

                              // Search Bar
                              _buildSearchBar(),

                              const SizedBox(height: 16),

                              // List header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Peserta (${_filteredAsesi.length})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    Text(
                                      'Hasil filter: ${_filteredAsesi.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),

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
                                    return _buildAsesiItem(item);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading || _filteredAsesi.isEmpty
          ? null
          : Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveRekomendasiKolektif,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded,
                          size: 20, color: Colors.white),
                  label: Text(
                    _isSaving
                        ? 'Menyimpan Rekomendasi...'
                        : 'Simpan Rekomendasi Kolektif',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(AsesiMeta meta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                LucideIcons.chart_pie,
                size: 16,
                color: Color(0xFF2C6C9C),
              ),
              SizedBox(width: 8),
              Text(
                'Statistik Rekomendasi Asesmen',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Total
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${meta.totalAsesi}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Total Asesi',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Kompeten (K)
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${meta.jumlahKompeten}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Kompeten (K)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Belum Kompeten (BK)
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${meta.jumlahBelumKompeten}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Belum Komp (BK)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari nama atau NIK peserta...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon:
              const Icon(LucideIcons.search, size: 18, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child:
                      const Icon(LucideIcons.x, size: 18, color: Colors.grey),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    required bool isValid,
  }) {
    final bgColor = isValid ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final borderColor = isValid ? const Color(0xFFA5D6A7) : const Color(0xFFFFCDD2);
    final textColor = isValid ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final icon = isValid ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsesiItem(AsesiItem item) {
    final currentRekom = _rekomendasiMap[item.id] ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // Row 1: Avatar, Name & Detail Link
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F1FC),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.namaLengkap.isNotEmpty
                        ? item.namaLengkap
                            .trim()
                            .split(' ')
                            .map((s) => s.isNotEmpty ? s[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C6C9C),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaLengkap,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No. Peserta: ${item.noPeserta ?? item.id.toString()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AsesorDetailAsesiScreen(
                        asesiId: item.id,
                        namaAsesi: item.namaLengkap,
                        jadwalId: widget.jadwalId,
                        jadwal: widget.jadwalTitle,
                        tuk: widget.tuk ?? '',
                      ),
                    ),
                  ).then((_) => _fetchAsesiData());
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4FA8E8),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Color(0xFF4FA8E8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Status Validasi APL01, APL02, AK02 (Hijau/Merah)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildStatusBadge(
                label: 'APL-01: ${item.isAPL01Valid ? "Lengkap" : "Belum"}',
                isValid: item.isAPL01Valid,
              ),
              _buildStatusBadge(
                label: 'APL-02: ${item.isAPL02Valid ? "Lengkap" : "Belum"}',
                isValid: item.isAPL02Valid,
              ),
              _buildStatusBadge(
                label: 'AK-02: ${item.isAK02Valid ? "Dinilai" : "Belum"}',
                isValid: item.isAK02Valid,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          // Row 3: Dropdown Rekomendasi (K / BK / -)
          Row(
            children: [
              const Text(
                'Rekomendasi:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: currentRekom == '1'
                        ? const Color(0xFFE8F5E9)
                        : (currentRekom == '2'
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFF5F6F8)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: currentRekom == '1'
                          ? const Color(0xFFA5D6A7)
                          : (currentRekom == '2'
                              ? const Color(0xFFFFCDD2)
                              : const Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentRekom,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_rounded,
                          color: Colors.black54),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: currentRekom == '1'
                            ? const Color(0xFF2E7D32)
                            : (currentRekom == '2'
                                ? const Color(0xFFC62828)
                                : Colors.black87),
                      ),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() {
                            _rekomendasiMap[item.id] = newVal;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: '1',
                          child: Text('K (Kompeten)'),
                        ),
                        DropdownMenuItem(
                          value: '2',
                          child: Text('BK (Belum Kompeten)'),
                        ),
                        DropdownMenuItem(
                          value: '0',
                          child: Text('- (Belum Rekomendasi)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
              LucideIcons.circle_alert,
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
              LucideIcons.users,
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
}

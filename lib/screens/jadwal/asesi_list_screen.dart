import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/jadwal_models.dart';
import '../../services/api_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/jadwal/transfer_asesi_sheet.dart';
import '../asesi/asesor_detail_asesi_screen.dart';

class AsesiListScreen extends StatefulWidget {
  final int jadwalId;
  final String jadwalTitle;
  final String? tanggal;
  final String? waktu;
  final String? tuk;
  final String? statusJadwal;
  final bool? isSelesai;

  const AsesiListScreen({
    super.key,
    required this.jadwalId,
    required this.jadwalTitle,
    this.tanggal,
    this.waktu,
    this.tuk,
    this.statusJadwal,
    this.isSelesai,
  });

  @override
  State<AsesiListScreen> createState() => _AsesiListScreenState();
}

class _AsesiListScreenState extends State<AsesiListScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  int _selectedTab = 0; // 0: Asesi Saya, 1: Semua Peserta, 2: Tidak Hadir
  String _errorMessage = '';
  AsesiListResponse? _response;
  List<AsesiItem> _filteredAsesi = [];
  final Map<int, String> _rekomendasiMap = {};
  final TextEditingController _searchController = TextEditingController();
  List<AsesorDetailItem> _jadwalAsesors = [];
  String _asesorErrorMessage = '';
  int? _transferringAsesiId;

  bool get _isJadwalSelesai {
    if (widget.isSelesai == true) return true;
    final s = widget.statusJadwal?.toString().trim().toLowerCase() ?? '';
    if (s == '1' || s == 'completed' || s == 'selesai') return true;
    if (_response?.isSelesai == true) return true;
    if (_response?.meta.isSelesai == true) return true;
    final rs = _response?.statusJadwal.trim().toLowerCase() ?? '';
    if (rs == '1' || rs == 'completed' || rs == 'selesai') return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _fetchAsesiData();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
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
      _applyFilter();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data asesi. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_response == null) return;
    final query = _searchController.text.toLowerCase().trim();
    final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';

    setState(() {
      _filteredAsesi = _response!.data.where((asesi) {
        if (_selectedTab == 2) {
          // Tab: Tidak Hadir
          if (!asesi.isAbsent) return false;
        } else if (_selectedTab == 0 && isAsesor) {
          // Tab: Asesi Saya (yang hadir)
          if (asesi.isAbsent || !asesi.isMyAsesi) return false;
        } else {
          // Tab: Semua Peserta (yang hadir)
          if (asesi.isAbsent) return false;
        }

        if (query.isNotEmpty) {
          final matches = asesi.namaLengkap.toLowerCase().contains(query) ||
              (asesi.nik != null && asesi.nik!.contains(query)) ||
              (asesi.noPeserta != null && asesi.noPeserta!.contains(query));
          if (!matches) return false;
        }
        return true;
      }).toList();
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
        final asesi = _filteredAsesi.firstWhere(
          (a) => a.id == asesiId,
          orElse: () => _response?.data.firstWhere(
                (a) => a.id == asesiId,
                orElse: () => AsesiItem(id: asesiId, namaLengkap: '', canEdit: false, isAPL01Valid: false),
              ) ??
              AsesiItem(id: asesiId, namaLengkap: '', canEdit: false, isAPL01Valid: false),
        );
        if (asesi.isMyAsesi && asesi.canEdit && asesi.isAPL01Valid) {
          pesertaPayload.add({
            'asesi_id': asesiId,
            'rekomendasi': rekom,
          });
        }
      });

      if (pesertaPayload.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hanya asesi Anda dengan APL-01 lengkap/terverifikasi yang dapat disimpan rekomendasi.'),
            backgroundColor: Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

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

  /// Ambil daftar asesor yang sedang bertugas pada jadwal ini.
  Future<void> _loadJadwalAsesors() async {
    try {
      final detail = await ApiService.getJadwalAsesorDetail(widget.jadwalId);
      if (!mounted) return;
      setState(() {
        _jadwalAsesors =
            detail?.data.asesor.where((a) => a.idAsesor > 0).toList() ?? [];
        _asesorErrorMessage = detail == null
            ? 'Gagal memuat daftar asesor bertugas.'
            : '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _asesorErrorMessage = 'Gagal memuat daftar asesor bertugas.';
      });
    }
  }

  /// Buka bottom sheet pemilihan asesor tujuan, lalu konfirmasi & pindahkan.
  Future<void> _openTransferSheet(AsesiItem item) async {
    if (_jadwalAsesors.isEmpty && _asesorErrorMessage.isEmpty) {
      setState(() {
        _transferringAsesiId = item.id;
      });
      await _loadJadwalAsesors();
      if (!mounted) return;
      setState(() {
        _transferringAsesiId = null;
      });
    }

    final kandidat = _jadwalAsesors
        .where((a) => a.idAsesor != item.idAsesor && a.idAsesor != 99999 && a.idAsesor != 9999)
        .toList();

    // Tambahkan opsi 'Tidak Hadir' di paling bawah jika asesi belum berstatus Tidak Hadir
    if (!item.isAbsent) {
      kandidat.add(
        const AsesorDetailItem(
          idAsesor: 99999,
          namaAsesor: 'Tidak Hadir',
          noReg: 'Tandai peserta tidak hadir',
          email: '',
          hp: '',
          jenisAsesmen: '',
          statusSpt: '',
        ),
      );
    }

    final selected = await showModalBottomSheet<AsesorDetailItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TransferAsesiSheet(
        namaAsesi: item.namaLengkap,
        asesorSaatIni: item.namaAsesor,
        kandidat: kandidat,
        errorMessage: _asesorErrorMessage,
        onRetry: () {
          Navigator.pop(sheetContext);
          setState(() {
            _asesorErrorMessage = '';
            _jadwalAsesors = [];
          });
          _openTransferSheet(item);
        },
      ),
    );

    if (selected == null || !mounted) return;

    final isTargetTidakHadir = selected.idAsesor == 99999 || selected.idAsesor == 9999;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isTargetTidakHadir ? 'Tandai Tidak Hadir' : 'Pindahkan Asesi',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isTargetTidakHadir
              ? 'Tandai ${item.namaLengkap} sebagai Tidak Hadir pada jadwal ini?'
              : 'Pindahkan ${item.namaLengkap} dari ${item.namaAsesor?.isNotEmpty == true ? item.namaAsesor : (item.isAbsent ? "status Tidak Hadir" : "asesor saat ini")} ke ${selected.namaAsesor}?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isTargetTidakHadir
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF2563EB),
            ),
            child: Text(
              isTargetTidakHadir ? 'Ya, Tidak Hadir' : 'Pindahkan',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _performTransfer(item, selected);
  }

  Future<void> _performTransfer(
    AsesiItem item,
    AsesorDetailItem target,
  ) async {
    setState(() {
      _transferringAsesiId = item.id;
    });

    final result = await ApiService.transferAsesi(
      jadwalId: widget.jadwalId,
      asesiId: item.id,
      targetAsesorId: target.idAsesor,
      expectedSourceAsesorId: item.idAsesor,
    );

    if (!mounted) return;
    setState(() {
      _transferringAsesiId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor:
            result.success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result.success) {
      await _loadJadwalAsesors();
      if (!mounted) return;
      await _fetchAsesiData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
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
                            padding: const EdgeInsets.all(16),
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

                                // Filter Tab (Asesi Saya vs Semua Peserta)
                                _buildAsesorFilterTabs(),

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

            // Persistent Footer Button
            if (!_isLoading && _filteredAsesi.isNotEmpty && _selectedTab != 2 && !_isJadwalSelesai)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
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
          ],
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

  Widget _buildAsesorFilterTabs() {
    if (_response == null) return const SizedBox.shrink();
    final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
    final totalCount = _response!.data.length;
    final tidakHadirCount = _response!.data.where((a) => a.isAbsent).length;
    final myAsesiCount = _response!.data.where((a) => a.isMyAsesi && !a.isAbsent).length;
    final presentCount = totalCount - tidakHadirCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (isAsesor)
              _buildFilterTabItem(
                label: 'Asesi Saya ($myAsesiCount)',
                isSelected: _selectedTab == 0,
                onTap: () {
                  if (_selectedTab != 0) {
                    setState(() => _selectedTab = 0);
                    _applyFilter();
                  }
                },
              ),
            _buildFilterTabItem(
              label: 'Semua Peserta ($presentCount)',
              isSelected: _selectedTab == 1,
              onTap: () {
                if (_selectedTab != 1) {
                  setState(() => _selectedTab = 1);
                  _applyFilter();
                }
              },
            ),
            _buildFilterTabItem(
              label: 'Tidak Hadir ($tidakHadirCount)',
              isSelected: _selectedTab == 2,
              activeTextColor: const Color(0xFFDC2626),
              onTap: () {
                if (_selectedTab != 2) {
                  setState(() => _selectedTab = 2);
                  _applyFilter();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeTextColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (activeTextColor ?? const Color(0xFF2C6C9C))
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
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
    final transferButton = _buildTransferButton(item);

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
                    Row(
                      children: [
                        Text(
                          'No. Peserta: ${item.noPeserta ?? item.id.toString()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        if (item.isAbsent) ...[
                          const Text(' • ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          const Icon(
                            Icons.person_off_rounded,
                            size: 11,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'Tidak Hadir',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ] else if (item.namaAsesor != null && item.namaAsesor!.isNotEmpty) ...[
                          const Text(' • ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Icon(
                            item.isMyAsesi ? LucideIcons.user_check : LucideIcons.lock,
                            size: 11,
                            color: item.isMyAsesi ? const Color(0xFF2563EB) : const Color(0xFFE11D48),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              item.namaAsesor!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: item.isMyAsesi ? const Color(0xFF2563EB) : const Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (item.isAbsent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_off_rounded,
                        size: 12,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tidak Hadir',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                )
              else if (!item.isMyAsesi)
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Akses ditolak: Asesi ini ditugaskan kepada ${item.namaAsesor ?? "asesor lain"}.',
                        ),
                        backgroundColor: const Color(0xFFE11D48),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Terkunci',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isJadwalSelesai || !item.canViewDetail)
                const SizedBox.shrink()
              else
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
                label: 'APL-01',
                isValid: item.isAPL01Valid,
              ),
              _buildStatusBadge(
                label: 'APL-02',
                isValid: item.isAPL02Valid,
              ),
              _buildStatusBadge(
                label: 'AK-02',
                isValid: item.isAK02Valid,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          // Row 3: Dropdown Rekomendasi (K / BK / -) + aksi pindah asesor
          Row(
            children: [
              Expanded(
                child: item.isAbsent
                    ? Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.block_rounded,
                              size: 14,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Peserta Tidak Hadir (Tidak Dinilai)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      )
                    : !item.isMyAsesi
                    ? Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 13,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currentRekom == '1'
                                      ? 'K (Kompeten)'
                                      : (currentRekom == '2'
                                          ? 'BK (Belum Kompeten)'
                                          : '- (Belum Rekomendasi)'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.namaAsesor != null && item.namaAsesor!.isNotEmpty
                                    ? item.namaAsesor!
                                    : 'Asesor Lain',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : (item.canEdit && item.isAPL01Valid && !_isJadwalSelesai)
                        ? Container(
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
                          )
                        : Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: currentRekom == '1'
                                  ? const Color(0xFFE8F5E9)
                                  : (currentRekom == '2'
                                      ? const Color(0xFFFFEBEE)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: currentRekom == '1'
                                    ? const Color(0xFFA5D6A7)
                                    : (currentRekom == '2'
                                        ? const Color(0xFFFFCDD2)
                                        : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      currentRekom == '1'
                                          ? Icons.check_circle_rounded
                                          : (currentRekom == '2'
                                              ? Icons.cancel_rounded
                                              : Icons.remove_circle_outline_rounded),
                                      size: 14,
                                      color: currentRekom == '1'
                                          ? const Color(0xFF2E7D32)
                                          : (currentRekom == '2'
                                              ? const Color(0xFFC62828)
                                              : const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      currentRekom == '1'
                                          ? 'K (Kompeten)'
                                          : (currentRekom == '2'
                                              ? 'BK (Belum Kompeten)'
                                              : '- (Belum Rekomendasi)'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: currentRekom == '1'
                                            ? const Color(0xFF2E7D32)
                                            : (currentRekom == '2'
                                                ? const Color(0xFFC62828)
                                                : const Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: !item.isAPL01Valid
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_outline_rounded,
                                        size: 11,
                                        color: !item.isAPL01Valid
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        !item.isAPL01Valid
                                            ? 'APL-01 Belum'
                                            : 'Hanya Lihat',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: !item.isAPL01Valid
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
              if (transferButton != null) ...[
                const SizedBox(width: 8),
                transferButton,
              ],
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

  /// Tombol pindah asesi ke asesor lain (kanan bawah card).
  /// Null bila caller bukan asesor pemilik asesi tersebut dan asesi tidak dalam status Tidak Hadir.
  Widget? _buildTransferButton(AsesiItem item) {
    final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
    final hasAsesor = (item.idAsesor ?? 0) > 0;
    final isAbsent = item.isAbsent;
    if (_isJadwalSelesai || !isAsesor || (!item.isMyAsesi && !isAbsent) || !hasAsesor) return null;

    final isFinal = !isAbsent && (item.rekomendasiAsesor == '1' ||
        item.rekomendasiAsesor == '2' ||
        item.hasilRekomendasi == 'K' ||
        item.hasilRekomendasi == 'BK');
    final isProcessing = _transferringAsesiId == item.id;
    final canTransfer = !isFinal && _transferringAsesiId == null;

    final tooltipMsg = isFinal
        ? 'Rekomendasi sudah final, asesi tidak dapat dipindahkan'
        : (isAbsent
            ? 'Pindahkan atau batalkan status tidak hadir'
            : 'Pindahkan ke asesor lain');

    return Tooltip(
      message: tooltipMsg,
      child: InkWell(
        key: ValueKey('transfer-asesi-${item.id}'),
        onTap: canTransfer ? () => _openTransferSheet(item) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: canTransfer
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: canTransfer
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Center(
            child: isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.swap_horiz_rounded,
                    size: 18,
                    color: canTransfer
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF94A3B8),
                  ),
          ),
        ),
      ),
    );
  }

}

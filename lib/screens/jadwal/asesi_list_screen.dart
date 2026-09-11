import 'package:material_ui/material_ui.dart';
import '../../models/jadwal_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/jadwal/jadwal_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/jadwal/transfer_asesi_sheet.dart';
import '../../widgets/jadwal/asesi_list_cards.dart';
import '../../widgets/jadwal/asesi_list_sections.dart';
import '../../widgets/jadwal/asesi_list_transfer.dart';

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
  int _selectedTab = 0; // 0: Asesi Saya (Asesor), 1: Semua Peserta (Admin), 2: Tidak Hadir
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
    final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
    _selectedTab = isAsesor ? 0 : 1;
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
      final data = await JadwalService.getAsesiList(widget.jadwalId);
      final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
      if (!isAsesor && _selectedTab == 0) {
        _selectedTab = 1;
      }
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
        if (asesi.canEdit) {
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
            content: Text('Hanya asesi Anda dengan APL-01, APL-02, dan AK-02 lengkap yang dapat disimpan rekomendasi.'),
            backgroundColor: Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final success = await AsesorService.updateRekomendasiKolektif(
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
      final detail = await JadwalService.getJadwalAsesorDetail(widget.jadwalId);
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

    final confirmed = await showAsesiTransferConfirmDialog(
      context,
      item: item,
      target: selected,
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

    final result = await AsesorService.transferAsesi(
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
                      ? AsesiErrorWidget(
                          message: _errorMessage,
                          onRetry: _fetchAsesiData,
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchAsesiData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Schedule details reference
                                AsesiScheduleInfoCard(
                                  jadwalTitle: widget.jadwalTitle,
                                ),
                                const SizedBox(height: 16),

                                // Summary statistics card
                                if (_response != null)
                                  AsesiSummaryCard(meta: _response!.meta),

                                const SizedBox(height: 16),

                                // Filter Tab (Asesi Saya vs Semua Peserta)
                                if (_response != null)
                                  AsesiFilterTabs(
                                    response: _response!,
                                    selectedTab: _selectedTab,
                                    onTabSelected: (tab) {
                                      setState(() => _selectedTab = tab);
                                      _applyFilter();
                                    },
                                  ),

                                // Search Bar
                                AsesiSearchBar(controller: _searchController),

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
                                  const AsesiEmptyWidget()
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: _filteredAsesi.length,
                                    itemBuilder: (context, index) {
                                      final item = _filteredAsesi[index];
                                      return AsesiListItem(
                                        item: item,
                                        currentRekom:
                                            _rekomendasiMap[item.id] ?? '0',
                                        isJadwalSelesai: _isJadwalSelesai,
                                        transferButton:
                                            buildAsesiTransferButton(
                                          item: item,
                                          isJadwalSelesai: _isJadwalSelesai,
                                          transferringAsesiId:
                                              _transferringAsesiId,
                                          onTap: () =>
                                              _openTransferSheet(item),
                                        ),
                                        onRekomChanged: (newVal) {
                                          setState(() {
                                            _rekomendasiMap[item.id] = newVal;
                                          });
                                        },
                                        jadwalId: widget.jadwalId,
                                        jadwalTitle: widget.jadwalTitle,
                                        tuk: widget.tuk ?? '',
                                        onDataChanged: _fetchAsesiData,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
            ),

            // Persistent Footer Button
            if (!_isLoading && _filteredAsesi.isNotEmpty && _selectedTab != 2 && !_isJadwalSelesai)
              AsesiSaveFooter(
                isSaving: _isSaving,
                onSave: _saveRekomendasiKolektif,
              ),
          ],
        ),
      ),
    );
  }
}

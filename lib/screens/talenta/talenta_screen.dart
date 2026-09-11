import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/talenta_models.dart';
import '../../models/master_models.dart';
import '../../services/talenta/talenta_service.dart';
import '../../services/common/master_service.dart';
import '../../services/marketing/location_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/common/custom_app_bar.dart';

class TalentaScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const TalentaScreen({super.key, this.onBackToHome});

  @override
  State<TalentaScreen> createState() => _TalentaScreenState();
}

class _TalentaScreenState extends State<TalentaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Location state
  UserGeoLocation? _currentGeo;
  String _currentLocationName = 'Mendeteksi lokasi...';
  bool _isDetectingLocation = false;

  // Filter state
  int? _selectedSkemaId;
  String _selectedSkemaName = 'Semua Skema';
  List<MasterSkema> _skemaList = [];

  // Data state
  List<TalentaItem> _talentaList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _isError = false;
  String _errorMessage = '';
  int _offset = 0;
  static const int _limit = 20;

  Timer? _searchDebounce;
  bool _isScrollThrottled = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _fetchTalenta(isRefresh: true);
      }
    });
  }

  void _onScroll() {
    if (_isScrollThrottled) return;
    _isScrollThrottled = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      _isScrollThrottled = false;
      if (!mounted) return;
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        if (!_isLoading && !_isLoadingMore && _hasMore) {
          _fetchTalenta(isRefresh: false);
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    // Fetch master skema
    try {
      final skemas = await MasterService.getMasterSkemaList();
      if (mounted) {
        setState(() {
          _skemaList = skemas;
        });
      }
    } catch (_) {}

    // Auto-detect GPS location via Google Maps Geocoding
    await _detectLocation();
  }

  Future<void> _detectLocation() async {
    if (_isDetectingLocation) return;
    setState(() {
      _isDetectingLocation = true;
      _currentLocationName = 'Mendeteksi lokasi GPS...';
    });

    try {
      final geo = await LocationService.getCurrentLocation();
      final realName = await LocationService.getRealLocationName(
        geo.latitude,
        geo.longitude,
      );

      if (mounted) {
        setState(() {
          _currentGeo = geo;
          _currentLocationName = realName.isNotEmpty ? realName : geo.locationName;
          _isDetectingLocation = false;
        });
        _fetchTalenta(isRefresh: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationName = 'Lokasi gagal dideteksi';
          _isDetectingLocation = false;
        });
        _fetchTalenta(isRefresh: true);
      }
    }
  }

  Future<void> _fetchTalenta({required bool isRefresh}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
        _offset = 0;
      });
    } else {
      if (_isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final res = await TalentaService.getTalenta(
        lat: _currentGeo?.latitude,
        lng: _currentGeo?.longitude,
        skemaId: _selectedSkemaId,
        search: _searchController.text.trim(),
        limit: _limit,
        offset: _offset,
      );

      if (!mounted) return;

      setState(() {
        if (isRefresh) {
          _talentaList = res.data;
        } else {
          _talentaList.addAll(res.data);
        }
        _offset += res.data.length;
        _hasMore = res.meta.hasMore;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _errorMessage = 'Gagal memuat data talenta. Periksa koneksi internet Anda.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _showSkemaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredSkemas = _skemaList.where((s) {
              final q = searchQuery.toLowerCase();
              return s.namaSkema.toLowerCase().contains(q) ||
                  s.kodeSkema.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Skema Sertifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (_selectedSkemaId != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSkemaId = null;
                              _selectedSkemaName = 'Semua Skema';
                            });
                            Navigator.pop(ctx);
                            _fetchTalenta(isRefresh: true);
                          },
                          child: const Text('Reset', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau kode skema...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredSkemas.length + 1,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedSkemaId == null;
                          return ListTile(
                            title: const Text('Semua Skema'),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB))
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedSkemaId = null;
                                _selectedSkemaName = 'Semua Skema';
                              });
                              Navigator.pop(ctx);
                              _fetchTalenta(isRefresh: true);
                            },
                          );
                        }

                        final skema = filteredSkemas[index - 1];
                        final isSelected = _selectedSkemaId == skema.id;

                        return ListTile(
                          title: Text(
                            skema.namaSkema,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: skema.kodeSkema.isNotEmpty
                              ? Text(skema.kodeSkema, style: const TextStyle(fontSize: 12))
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB))
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedSkemaId = skema.id;
                              _selectedSkemaName = skema.namaSkema;
                            });
                            Navigator.pop(ctx);
                            _fetchTalenta(isRefresh: true);
                          },
                        );
                      },
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Talenta Terdekat',
              onBack: widget.onBackToHome ?? () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: RefreshIndicator(
        onRefresh: () => _fetchTalenta(isRefresh: true),
        color: const Color(0xFF2563EB),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header: GPS Location Banner & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Card
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Posisi Anda Saat Ini',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentLocationName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: _isDetectingLocation ? null : _detectLocation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: _isDetectingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Row(
                                      children: const [
                                        Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF2563EB)),
                                        SizedBox(width: 4),
                                        Text(
                                          'GPS',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama pemegang sertifikat...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _fetchTalenta(isRefresh: true);
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Skema Filter Chip/Selector
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _showSkemaPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedSkemaId != null
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedSkemaId != null
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 18,
                              color: _selectedSkemaId != null
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedSkemaName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedSkemaId != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedSkemaId != null
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content: Loading / Error / Empty / List
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
              )
            else if (_isError)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchTalenta(isRefresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_talentaList.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_search_rounded,
                          size: 56,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum Ada Talenta Ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tidak ada pemegang sertifikat yang sesuai filter. Coba ubah kata kunci atau ganti skema sertifikasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _talentaList[index];
                      return _buildTalentaCard(item);
                    },
                    childCount: _talentaList.length,
                  ),
                ),
              ),

            // Pagination loader
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    ),
  ],
),
),
);
  }

  Widget _buildTalentaCard(TalentaItem item) {
    final isGuest = AuthRepository.currentUserInstance == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Distance Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.pemegang,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.skema,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.jarakLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        item.jarakLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Location & Category
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.lokasi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.isAktif
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.isAktif ? 'Aktif' : 'Kadaluarsa',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.isAktif
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Certificate info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No. Sertifikat',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.nomorSertifikat.isNotEmpty ? item.nomorSertifikat : '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Masa Berlaku',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.tanggalBerlaku.isNotEmpty ? item.tanggalBerlaku : '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Contact actions if logged in, or hint if guest
          if (!isGuest && item.hasKontak) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (item.telp.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF16A34A)),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBBF7D0)),
                        backgroundColor: const Color(0xFFF0FDF4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () async {
                        var phone = item.telp.replaceAll(RegExp(r'[^0-9]'), '');
                        if (phone.startsWith('0')) {
                          phone = '62${phone.substring(1)}';
                        }
                        final url = Uri.parse('https://wa.me/$phone');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (item.email.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.email_outlined, size: 15, color: Color(0xFF2563EB)),
                      label: const Text(
                        'Email',
                        style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        backgroundColor: const Color(0xFFEFF6FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () async {
                        final url = Uri.parse('mailto:${item.email}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ] else if (isGuest) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '🔒 Masuk ke akun Anda untuk melihat kontak pemegang sertifikat',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

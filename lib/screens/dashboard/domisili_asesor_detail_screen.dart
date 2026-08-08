import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';

class DomisiliAsesorDetailScreen extends StatefulWidget {
  final String provinsiId;
  final String provinsiNama;
  final int totalAsesor;
  final int totalInternal;
  final int totalExternal;

  const DomisiliAsesorDetailScreen({
    super.key,
    required this.provinsiId,
    required this.provinsiNama,
    required this.totalAsesor,
    required this.totalInternal,
    required this.totalExternal,
  });

  @override
  State<DomisiliAsesorDetailScreen> createState() =>
      _DomisiliAsesorDetailScreenState();
}

class _DomisiliAsesorDetailScreenState
    extends State<DomisiliAsesorDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<AsesorDomisiliItem> _asesorList = [];
  bool _isLoading = true;
  String _selectedTipe = 'Semua'; // 'Semua', 'Internal', 'External'

  late int _totalAsesor;
  late int _totalInternal;
  late int _totalExternal;

  @override
  void initState() {
    super.initState();
    _totalAsesor = widget.totalAsesor;
    _totalInternal = widget.totalInternal;
    _totalExternal = widget.totalExternal;

    _searchController.addListener(_onSearchChanged);
    _fetchData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getDomisiliAsesorDetail(
        provinsiId: widget.provinsiId,
        search: _searchController.text.trim(),
        tipe: _selectedTipe,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _asesorList = result.asesorList;
          if (result.totalAsesor > 0) _totalAsesor = result.totalAsesor;
          if (result.totalInternal > 0) _totalInternal = result.totalInternal;
          if (result.totalExternal > 0) _totalExternal = result.totalExternal;
          _isLoading = false;
        });
      } else {
        setState(() {
          _asesorList = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _asesorList = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Asesor ${widget.provinsiNama}',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKpiCardGroup(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    _buildListHeader(),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_asesorList.isEmpty)
                      _buildEmptyState()
                    else
                      ..._asesorList.map((item) => _buildAsesorCard(item)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCardGroup() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildKpiTile(
            label: 'Total Asesor',
            value: '$_totalAsesor',
            color: const Color(0xFF2563EB),
          ),
          Container(
            height: 36,
            width: 1,
            color: const Color(0xFFE2E8F0),
          ),
          _buildKpiTile(
            label: 'Internal',
            value: '$_totalInternal',
            color: const Color(0xFF16A34A),
          ),
          Container(
            height: 36,
            width: 1,
            color: const Color(0xFFE2E8F0),
          ),
          _buildKpiTile(
            label: 'Eksternal',
            value: '$_totalExternal',
            color: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari nama asesor, MET, skema, atau kota...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        _buildChip('Semua'),
        const SizedBox(width: 8),
        _buildChip('Internal'),
        const SizedBox(width: 8),
        _buildChip('External', label: 'Eksternal'),
      ],
    );
  }

  Widget _buildChip(String tipeKey, {String? label}) {
    final isSelected = _selectedTipe == tipeKey;
    final displayLabel = label ?? tipeKey;

    return InkWell(
      onTap: () {
        if (_selectedTipe != tipeKey) {
          setState(() {
            _selectedTipe = tipeKey;
          });
          _fetchData();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Asesor (${_asesorList.length})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        if (_searchController.text.isNotEmpty || _selectedTipe != 'Semua')
          GestureDetector(
            onTap: () {
              setState(() {
                _searchController.clear();
                _selectedTipe = 'Semua';
              });
              _fetchData();
            },
            child: const Text(
              'Reset Filter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAsesorCard(AsesorDomisiliItem item) {
    final bool isInternal =
        item.tipeAsesor.toLowerCase().contains('internal');
    final Color badgeBg = isInternal ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final Color badgeText = isInternal ? const Color(0xFF15803D) : const Color(0xFFB45309);

    final names = item.namaAsesor.trim().split(' ');
    String initials = 'A';
    if (names.isNotEmpty && names[0].isNotEmpty) {
      initials = names[0][0].toUpperCase();
      if (names.length > 1 && names[1].isNotEmpty) {
        initials += names[1][0].toUpperCase();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isInternal
                        ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                      item.namaAsesor,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'No. MET: ${item.noMet}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isInternal ? 'Internal' : 'Eksternal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          if (item.skemaKeahlian.isNotEmpty && item.skemaKeahlian != '-') ...[
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.skemaKeahlian,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (item.kabupatenKota.isNotEmpty || item.provinsi.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.kabupatenKota.isNotEmpty && item.provinsi.isNotEmpty
                        ? '${item.kabupatenKota}, ${item.provinsi}'
                        : (item.kabupatenKota.isNotEmpty
                            ? item.kabupatenKota
                            : item.provinsi),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if ((item.email.isNotEmpty && item.email != '-') ||
              (item.noHp.isNotEmpty && item.noHp != '-')) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (item.email.isNotEmpty && item.email != '-') ...[
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (item.noHp.isNotEmpty && item.noHp != '-') ...[
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.noHp,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_rounded,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          const Text(
            'Asesor Tidak Ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _searchController.text.isNotEmpty
                ? 'Tidak ada asesor yang cocok dengan "${_searchController.text}".'
                : 'Belum ada data asesor untuk filter ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          if (_searchController.text.isNotEmpty || _selectedTipe != 'Semua') ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedTipe = 'Semua';
                });
                _fetchData();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset Pencarian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

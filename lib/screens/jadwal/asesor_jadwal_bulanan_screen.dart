import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../utils/date_format_helper.dart';
import 'jadwal_detail_screen.dart';

class AsesorJadwalBulananScreen extends StatefulWidget {
  final int tahun;
  final int bulan;
  final String namaBulan;
  final int initialSptCount;
  final int initialAsesiCount;

  const AsesorJadwalBulananScreen({
    super.key,
    required this.tahun,
    required this.bulan,
    required this.namaBulan,
    this.initialSptCount = 0,
    this.initialAsesiCount = 0,
  });

  @override
  State<AsesorJadwalBulananScreen> createState() =>
      _AsesorJadwalBulananScreenState();
}

class _AsesorJadwalBulananScreenState extends State<AsesorJadwalBulananScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<JadwalItem> _allJadwal = [];
  List<JadwalItem> _filteredJadwal = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJadwalBulanan();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredJadwal = List.from(_allJadwal);
      });
    } else {
      setState(() {
        _filteredJadwal = _allJadwal.where((j) {
          final skema = j.skema.toLowerCase();
          final tuk = j.tuk.toLowerCase();
          final status = j.statusJadwal.toLowerCase();
          return skema.contains(query) ||
              tuk.contains(query) ||
              status.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _fetchJadwalBulanan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final list = await AsesorService.getAsesorJadwalBulanan(
        tahun: widget.tahun,
        bulan: widget.bulan,
      );

      if (!mounted) return;
      setState(() {
        _allJadwal = list;
        _filteredJadwal = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat daftar jadwal: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case '1':
      case 'selesai':
      case 'completed':
        return const Color(0xFF10B981); // Emerald
      case '3':
      case 'sedang berjalan':
      case 'active':
      case 'running':
        return const Color(0xFF2563EB); // Blue
      case '0':
      case 'draft':
      case 'menunggu verifikasi':
      case 'menunggu':
      case 'waiting':
        return const Color(0xFFD97706); // Amber
      case '2':
      case 'dibatalkan':
      case 'cancelled':
        return const Color(0xFFDC2626); // Red
      case '4':
      case 'pelaporan':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case '1':
      case 'selesai':
      case 'completed':
        return const Color(0xFFD1FAE5);
      case '3':
      case 'sedang berjalan':
      case 'active':
      case 'running':
        return const Color(0xFFDBEAFE);
      case '0':
      case 'draft':
      case 'menunggu verifikasi':
      case 'menunggu':
      case 'waiting':
        return const Color(0xFFFEF3C7);
      case '2':
      case 'dibatalkan':
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      case '4':
      case 'pelaporan':
        return const Color(0xFFEDE9FE);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Widget _buildStatusChip({
    required String title,
    required String value,
    required IconData icon,
  }) {
    Color textColor = const Color(0xFF64748B);
    Color bgColor = const Color(0xFFF1F5F9);
    Color iconColor = const Color(0xFF64748B);

    final vLower = value.toLowerCase();
    if (vLower == 'selesai' || vLower == 'diterima' || vLower == 'terkirim') {
      textColor = const Color(0xFF059669);
      bgColor = const Color(0xFFD1FAE5);
      iconColor = const Color(0xFF059669);
    } else if (vLower == 'sebagian' || vLower == 'proses') {
      textColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
    } else if (vLower == 'dibatalkan' || vLower == 'batal') {
      textColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEE2E2);
      iconColor = const Color(0xFFDC2626);
    }

    final displayText = value.isNotEmpty ? value : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 4),
          Text(
            '$title: $displayText',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final int totalSpt = _allJadwal.isNotEmpty ? _allJadwal.length : widget.initialSptCount;
    final int totalAsesi = _allJadwal.isNotEmpty
        ? _allJadwal.fold<int>(0, (sum, item) => sum + item.jumlahAsesi)
        : widget.initialAsesiCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Jadwal ${widget.namaBulan} ${widget.tahun}',
            rightWidget: const SizedBox(width: 32),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchJadwalBulanan,
              color: const Color(0xFF2563EB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Summary Banner
                    _buildTopBanner(totalSpt, totalAsesi),

                    const SizedBox(height: 14),

                    // 2. Search Box
                    _buildSearchBox(),

                    const SizedBox(height: 14),

                    // 3. Content List
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                        ),
                      )
                    else if (_errorMessage.isNotEmpty)
                      _buildErrorState()
                    else if (_filteredJadwal.isEmpty)
                      _buildEmptyState()
                    else
                      ..._filteredJadwal.map((j) => _buildJadwalCard(j)),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner(int totalSpt, int totalAsesi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode ${widget.namaBulan} ${widget.tahun}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Daftar jadwal penugasan asesmen Anda',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.file_text, size: 16, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Surat Tugas',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                          Text(
                            '$totalSpt Jadwal',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF99F6E4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.users, size: 16, color: Color(0xFF0D9488)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Asesi',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                          Text(
                            '$totalAsesi Peserta',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ],
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

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari nama jadwal, TUK, atau skema...',
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(LucideIcons.search, size: 18, color: Color(0xFF64748B)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildJadwalCard(JadwalItem j) {
    final statusColor = _getStatusColor(j.statusJadwalLabel.isNotEmpty ? j.statusJadwalLabel : j.statusJadwal);
    final statusBgColor = _getStatusBgColor(j.statusJadwalLabel.isNotEmpty ? j.statusJadwalLabel : j.statusJadwal);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final user = AuthRepository.currentUserInstance;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JadwalDetailScreen(
                  jadwal: j,
                  userRole: UserRole(
                    role: user?.role ?? 'asesor',
                    name: user?.name ?? 'Asesor',
                    email: user?.email ?? '',
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Status Utama & 3 Status Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        j.statusJadwalLabel.isNotEmpty
                            ? j.statusJadwalLabel
                            : (j.statusLabel.isNotEmpty ? j.statusLabel : (j.statusJadwal.isNotEmpty ? j.statusJadwal : 'Aktif')),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3 Status Badges: Status Rekaman, Status Blanko, Status Pengiriman Sertifikat
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildStatusChip(
                      title: 'Rekaman',
                      value: j.statusRekaman.isNotEmpty ? j.statusRekaman : 'Belum',
                      icon: LucideIcons.mic,
                    ),
                    _buildStatusChip(
                      title: 'Blanko',
                      value: j.statusBlanko.isNotEmpty ? j.statusBlanko : 'Belum',
                      icon: LucideIcons.file_text,
                    ),
                    _buildStatusChip(
                      title: 'Pengiriman',
                      value: j.statusPengiriman.isNotEmpty ? j.statusPengiriman : 'Belum',
                      icon: LucideIcons.truck,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Nama Jadwal (Skema)
                Text(
                  j.skema,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Info Rows: Tanggal, TUK, Asesi
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        j.tanggalMulai.isNotEmpty
                            ? DateFormatHelper.formatToIndonesian(j.tanggalMulai)
                            : '-',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.building, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        j.tuk.isNotEmpty ? j.tuk : 'TUK Mandiri',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.users, size: 14, color: Color(0xFF0D9488)),
                    const SizedBox(width: 6),
                    Text(
                      '${j.jumlahAsesi} Asesi Terdaftar',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Detail Jadwal',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.calendar_x,
              size: 36,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _searchController.text.isNotEmpty
                ? 'Tidak ada jadwal yang cocok'
                : 'Tidak ada jadwal di ${widget.namaBulan} ${widget.tahun}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _searchController.text.isNotEmpty
                ? 'Coba ganti kata kunci pencarian Anda'
                : 'Belum ada jadwal asesmen yang ditugaskan pada bulan ini',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFDC2626)),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchJadwalBulanan,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

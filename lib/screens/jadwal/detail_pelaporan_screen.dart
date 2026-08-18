import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/admin/laporan_service.dart';
import '../../models/admin_laporan_models.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/jadwal/detail_pelaporan_sections.dart';

class DetailPelaporanScreen extends StatefulWidget {
  final int laporanId;

  const DetailPelaporanScreen({
    super.key,
    required this.laporanId,
  });

  @override
  State<DetailPelaporanScreen> createState() => _DetailPelaporanScreenState();
}

class _DetailPelaporanScreenState extends State<DetailPelaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _catatanController;
  late TextEditingController _asesiSearchController;
  final LaporanService _service = LaporanService();

  bool _isLoading = true;
  String? _errorMessage;
  AdminLaporanDetailData? _detail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _catatanController = TextEditingController();
    _asesiSearchController = TextEditingController();
    _asesiSearchController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadDetailLaporan();
  }

  Future<void> _loadDetailLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.getLaporanDetail(widget.laporanId);
      if (mounted) {
        setState(() {
          _detail = response.data;
          _isLoading = false;
          _catatanController.text = _detail?.catatan ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _catatanController.clear();
        });
      }
    }
  }

  Future<void> _handleApprove() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Laporan'),
        content: const Text('Apakah Anda yakin ingin menyetujui laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _service.approveLaporan(
          widget.laporanId,
          catatan: _catatanController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil disetujui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyetujui laporan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReject() async {
    final note = _catatanController.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi Catatan Revisi Admin terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minta Revisi'),
        content: Text(
            'Apakah Anda yakin ingin mengembalikan laporan ini untuk revisi?\n\nCatatan:\n"$note"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Kirim Revisi'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _service.rejectLaporan(widget.laporanId, alasan: note);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan telah dikembalikan untuk revisi'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal meminta revisi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleDownloadLampiran() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengunduh seluruh berkas lampiran laporan...'),
        backgroundColor: Color(0xFF3B82F6),
      ),
    );
  }

  Future<void> _openLink(String link) async {
    final uri = Uri.tryParse(link.trim());
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link tidak dapat dibuka')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _catatanController.dispose();
    _asesiSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Standard App Heading matching app-wide CustomAppBar
          CustomAppBar(
            title: 'Detail Laporan',
            onBack: () => Navigator.of(context).pop(),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDetailLaporan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _buildDetailBody(),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading || _detail == null
          ? null
          : _buildBottomActions(),
    );
  }

  Widget _buildDetailBody() {
    final detail = _detail!;
    final bool isApproved =
        detail.status == 'Lengkap' || detail.status == 'Disetujui' || detail.status.toLowerCase() == 'completed';

    final String skema = detail.skemaSertifikasi.isNotEmpty
        ? detail.skemaSertifikasi
        : 'Digital Marketing';
    final String tuk = detail.tuk.isNotEmpty
        ? detail.tuk
        : 'LPK Digital Center';
    final String tanggal = detail.tanggalPelaksanaan.isNotEmpty
        ? detail.tanggalPelaksanaan
        : '20 Juli 2026';
    final String statusText = detail.status == 'Revisi'
        ? 'Belum Lengkap'
        : (detail.status == 'Disetujui' ? 'Lengkap' : (detail.status.isNotEmpty ? detail.status : 'Belum Lengkap'));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // 1. Top Summary Header Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Soft Blue document icon box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Color(0xFF3B82F6),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skema,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tuk : $tuk',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tanggal $tanggal',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status Pill Badge (Top Right)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFFDCFCE7) // Soft Green
                        : const Color(0xFFFDE6D2), // Soft Peach/Amber
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isApproved
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFF97316),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Main Content Card with 3 Sub-Tabs
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sub-TabBar (Lampiran, Asessi, Informasi)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSubTabItem(
                          index: 0,
                          icon: Icons.attach_file_rounded,
                          label: 'Lampiran',
                        ),
                      ),
                      Expanded(
                        child: _buildSubTabItem(
                          index: 1,
                          icon: Icons.people_outline_rounded,
                          label: 'Asessi',
                        ),
                      ),
                      Expanded(
                        child: _buildSubTabItem(
                          index: 2,
                          icon: Icons.article_outlined,
                          label: 'Informasi',
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _tabController.index == 0
                        ? LampiranContent(
                            detail: detail,
                            isApproved: isApproved,
                            catatanController: _catatanController,
                            onOpenLink: _openLink,
                          )
                        : _tabController.index == 1
                            ? AsesiContent(
                                detail: detail,
                                isApproved: isApproved,
                                asesiSearchController: _asesiSearchController,
                              )
                            : InformasiContent(detail: detail, isApproved: isApproved),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _tabController.index == index;
    const Color activeColor = Color(0xFF2563EB);
    const Color inactiveColor = Color(0xFF475569);
    final Color currentColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: currentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: currentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2.5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Informasi Tab Content


  /// - If Belum Disetujui: Two side-by-side buttons "Minta Revisi" & "Disetujui"
  Widget _buildBottomActions() {
    final detail = _detail!;
    final bool isApproved =
        detail.status == 'Lengkap' || detail.status == 'Disetujui' || detail.status.toLowerCase() == 'completed';

    return Container(
      color: const Color(0xFFF5F6F8),
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: isApproved
            ? SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53A6ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _handleDownloadLampiran,
                  icon: const Icon(Icons.file_download_outlined, size: 22),
                  label: const Text(
                    'Unduh Lampiran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCBD5E1),
                          foregroundColor: const Color(0xFF334155),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _handleReject,
                        child: const Text(
                          'Minta Revisi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF53A6ED),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _handleApprove,
                        child: const Text(
                          'Setujui (Lengkap)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

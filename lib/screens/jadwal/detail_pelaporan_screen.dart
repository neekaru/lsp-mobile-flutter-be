import 'package:flutter/material.dart';
import '../../services/admin_laporan_service.dart';
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
  final AdminLaporanService _service = AdminLaporanService();

  bool _isLoading = true;
  String? _errorMessage;
  AdminLaporanDetailData? _detail;
  String _asesiSearchQuery = '';

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
      if (mounted) {
        setState(() {
          _asesiSearchQuery = _asesiSearchController.text.trim().toLowerCase();
        });
      }
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
          _catatanController.text = _detail?.catatan.isNotEmpty == true
              ? _detail!.catatan
              : 'Mohon lengkapi dokumen daftar hadir dan FR.APL.01 sesuai dengan ketentuan yang berlaku';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _catatanController.text =
              'Mohon lengkapi dokumen daftar hadir dan FR.APL.01 sesuai dengan ketentuan yang berlaku';
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
        detail.status == 'Disetujui' || detail.status.toLowerCase() == 'completed';

    final String skema = detail.skemaSertifikasi.isNotEmpty
        ? detail.skemaSertifikasi
        : 'Digital Marketing';
    final String tuk = detail.tuk.isNotEmpty
        ? detail.tuk
        : 'LPK Digital Center';
    final String tanggal = detail.tanggalPelaksanaan.isNotEmpty
        ? detail.tanggalPelaksanaan
        : '20 Juli 2026';
    final String statusText = detail.status.isNotEmpty ? detail.status : 'Revisi';

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
                        ? _buildLampiranContent(detail, isApproved)
                        : _tabController.index == 1
                            ? _buildAsesiContent(detail, isApproved)
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

  /// 1. Lampiran Tab Content
  Widget _buildLampiranContent(AdminLaporanDetailData detail, bool isApproved) {
    final List<Map<String, dynamic>> items = detail.lampiranPendukung.map((item) {
      return {
        'title': item.title.isNotEmpty ? item.title : item.fileName,
        'file': item.fileName.isNotEmpty ? item.fileName : item.fileUrl,
        'size': item.fileSize,
        'isValid': item.isValid,
      };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            final bool isValid = item['isValid'] == true;

            return Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'].toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['file'].toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  item['size'].toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isValid
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isValid ? Icons.check : Icons.close,
                    color: isValid
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    size: 14,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 14),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 14),

        if (!isApproved) ...[
          const Text(
            'Catatan Revisi Admin',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: TextField(
              controller: _catatanController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF334155),
                height: 1.4,
              ),
              decoration: const InputDecoration(
                hintText: 'Masukkan catatan revisi...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ] else ...[
          const GreenStatusBanner(),
        ],
      ],
    );
  }

  /// 2. Asessi Tab Content (Gap above list removed & compact header layout)
  Widget _buildAsesiContent(AdminLaporanDetailData detail, bool isApproved) {
    final List<Map<String, String>> rawAsesiList = detail.daftarAsesiDinilai.map((a) {
      return {
        'nama': a.nama,
        'noReg': a.nim,
        'hasil': a.penilaian.toLowerCase().contains('kompeten') || a.penilaian == 'K'
            ? 'Kompeten'
            : 'Belum Kompeten',
      };
    }).toList();

    final filteredList = rawAsesiList.where((a) {
      if (_asesiSearchQuery.isEmpty) return true;
      final nama = a['nama']?.toLowerCase() ?? '';
      final noReg = a['noReg']?.toLowerCase() ?? '';
      return nama.contains(_asesiSearchQuery) || noReg.contains(_asesiSearchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Box: "Cari nama/no registrasi peserta"
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _asesiSearchController,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama/no registrasi peserta',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Table Header Box (Nama | No Registrasi | Hasil)
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'No Registrasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Hasil',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // List of Asesi Cards without top gap
        if (filteredList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Tidak ada peserta yang cocok.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: filteredList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = filteredList[index];
              final String nama = item['nama'] ?? '';
              final String noReg = item['noReg'] ?? '';
              final String hasil = item['hasil'] ?? 'Kompeten';
              final bool isKompeten = hasil == 'Kompeten';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        noReg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isKompeten
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hasil,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isKompeten
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        // Status Banner ONLY shown if Disetujui
        if (isApproved) ...[
          const SizedBox(height: 12),
          const GreenStatusBanner(),
        ],
      ],
    );
  }

  /// 3. Informasi Tab Content


  /// - If Belum Disetujui: Two side-by-side buttons "Minta Revisi" & "Disetujui"
  Widget _buildBottomActions() {
    final detail = _detail!;
    final bool isApproved =
        detail.status == 'Disetujui' || detail.status.toLowerCase() == 'completed';

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
                          'Disetujui',
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

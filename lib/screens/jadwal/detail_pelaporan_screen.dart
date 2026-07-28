import 'package:flutter/material.dart';
import '../../services/admin_laporan_service.dart';
import '../../models/admin_laporan_models.dart';

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
  final AdminLaporanService _service = AdminLaporanService();

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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _service.approveLaporan(widget.laporanId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil disetujui')),
          );
          _loadDetailLaporan();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyetujui laporan: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleReject() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Laporan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan alasan penolakan:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Daftar hadir belum lengkap',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      try {
        await _service.rejectLaporan(widget.laporanId, alasan: result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan dikembalikan untuk revisi')),
          );
          _loadDetailLaporan();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menolak laporan: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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

          // Top Bar Header: "< Detail Laporan"
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E293B),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF1E293B),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Detail Laporan',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

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
                    : _detail == null
                        ? const Center(
                            child: Text(
                              'Data laporan tidak ditemukan.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : _buildDetailBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBody() {
    final detail = _detail!;
    final bool isApproved =
        detail.status == 'Disetujui' || detail.status.toLowerCase() == 'completed';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Top Summary Header Card from Real API Data
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
              children: [
                // Left Blue Document Icon
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
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Title & Subtitle Info from Real API Data
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.skemaSertifikasi,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Kode : ${detail.kodeLaporan}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tanggal ${detail.tanggalPelaksanaan}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right Status Badge from Real API Data
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    detail.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isApproved
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Content Card with 3 Sub-Tabs
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sub-TabBar (Lampiran, Asessi, Informasi)
                Row(
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

                const Divider(
                  height: 24,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),

                // Active Tab Content
                if (_tabController.index == 0)
                  _buildLampiranContent(detail, isApproved)
                else if (_tabController.index == 1)
                  _buildAsesiContent(detail)
                else
                  _buildInformasiContent(detail),
              ],
            ),
          ),

          // Action buttons for Admin when report status is pending/waiting/revisi
          if (detail.status.toLowerCase() == 'waiting' ||
              detail.status.toLowerCase() == 'pending' ||
              detail.status == 'Revisi') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Minta Revisi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Setujui Laporan'),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),
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
    const Color activeColor = Color(0xFF3B82F6);
    const Color inactiveColor = Color(0xFF64748B);
    final Color currentColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: currentColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: currentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            color: isSelected ? activeColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildLampiranContent(AdminLaporanDetailData detail, bool isApproved) {
    final lampiranList = detail.lampiranPendukung;

    return Column(
      children: [
        if (lampiranList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Tidak ada lampiran pendukung.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lampiranList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = lampiranList[index];
              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
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
                          item.fileName,
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
                          item.fileUrl,
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
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: 20),

        // Bottom Status Banner Box
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isApproved
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isApproved
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFFDE68A),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD97706),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApproved ? Icons.check : Icons.priority_high,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isApproved
                          ? 'Laporan Telah Disetujui'
                          : 'Laporan Memerlukan Revisi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isApproved
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isApproved
                          ? 'Tidak ada dokumen yang perlu direvisi. Laporan dinyatakan lengkap.'
                          : 'Harap periksa dokumen lampiran yang memerlukan perbaikan.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isApproved
                            ? const Color(0xFF166534)
                            : const Color(0xFF92400E),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAsesiContent(AdminLaporanDetailData detail) {
    final asesiList = detail.daftarAsesiDinilai;

    if (asesiList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'Belum ada data asesi dinilai.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: asesiList.length,
      separatorBuilder: (context, index) => const Divider(
        height: 16,
        color: Color(0xFFF1F5F9),
      ),
      itemBuilder: (context, index) {
        final asesi = asesiList[index];
        final bool isKompeten = asesi.penilaian == 'K' ||
            asesi.penilaian.toLowerCase().contains('kompeten');

        return Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asesi.nama,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NIM/NIK: ${asesi.nim}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isKompeten
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isKompeten ? 'Kompeten' : 'Belum Kompeten',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isKompeten
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInformasiContent(AdminLaporanDetailData detail) {
    return Column(
      children: [
        _buildInfoRow('Kode Laporan', detail.kodeLaporan),
        _buildInfoRow('Skema Sertifikasi', detail.skemaSertifikasi),
        _buildInfoRow('Nama Asesor', detail.namaAsesor),
        _buildInfoRow('Tanggal Pelaksanaan', detail.tanggalPelaksanaan),
        _buildInfoRow('Link Dokumentasi',
            detail.linkDokumentasi.isNotEmpty ? detail.linkDokumentasi : '-'),
        _buildInfoRow('Catatan',
            detail.catatan.isNotEmpty ? detail.catatan : 'Tidak ada catatan.'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

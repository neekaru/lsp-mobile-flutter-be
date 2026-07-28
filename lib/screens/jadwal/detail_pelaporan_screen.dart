import 'package:flutter/material.dart';

class DetailPelaporanScreen extends StatefulWidget {
  final String skema;
  final String tuk;
  final String asesorName;
  final String tanggalStatus;
  final String status;

  const DetailPelaporanScreen({
    super.key,
    this.skema = 'Digital Marketing',
    this.tuk = 'LPK Digital Center',
    this.asesorName = 'Karina',
    this.tanggalStatus = '20 Juli 2026',
    this.status = 'Disetujui',
  });

  @override
  State<DetailPelaporanScreen> createState() => _DetailPelaporanScreenState();
}

class _DetailPelaporanScreenState extends State<DetailPelaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _attachments = [
    {
      'title': 'Berita Acara',
      'fileName': 'berita_acara.pdf',
      'size': '136KB',
    },
    {
      'title': 'Daftar Hadir',
      'fileName': 'daftar_hadir.pdf',
      'size': '136KB',
    },
    {
      'title': 'FR.APL.01',
      'fileName': 'fr.apl.01.pdf',
      'size': '136KB',
    },
    {
      'title': 'FR.AK.01',
      'fileName': 'fr.ak.01.pdf',
      'size': '136KB',
    },
    {
      'title': 'Rekaman Vidio',
      'fileName': 'drive.google.com',
      'size': '136KB',
    },
  ];

  final List<Map<String, String>> _asesiList = [
    {
      'nama': 'Karina',
      'nik': '3201234567890001',
      'status': 'Kompeten',
    },
    {
      'nama': 'Ahmad Subagja',
      'nik': '3201234567890002',
      'status': 'Kompeten',
    },
    {
      'nama': 'Dewi Lestari',
      'nik': '3201234567890003',
      'status': 'Belum Kompeten',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final bool isApproved = widget.status == 'Disetujui';

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Top Summary Header Card
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

                        // Title & Subtitle Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.skema,
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
                                'Tuk : ${widget.tuk}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tanggal ${widget.tanggalStatus}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Right Status Badge
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
                            widget.status,
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

                  // Main Content Card with 3 Tabs
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
                          _buildLampiranContent(isApproved)
                        else if (_tabController.index == 1)
                          _buildAsesiContent()
                        else
                          _buildInformasiContent(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
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

  Widget _buildLampiranContent(bool isApproved) {
    return Column(
      children: [
        // List of Attachments
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _attachments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _attachments[index];
            return Row(
              children: [
                // Light Blue Document Icon
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

                // Title & Subtitle PDF Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['fileName']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Size info
                Text(
                  item['size']!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),

                const SizedBox(width: 10),

                // Green Checked Box Icon matching mockup
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
              // Icon Circle Checkmark
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

              // Title and Description
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

  Widget _buildAsesiContent() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _asesiList.length,
      separatorBuilder: (context, index) => const Divider(
        height: 16,
        color: Color(0xFFF1F5F9),
      ),
      itemBuilder: (context, index) {
        final asesi = _asesiList[index];
        final bool isKompeten = asesi['status'] == 'Kompeten';

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
                    asesi['nama']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NIK: ${asesi['nik']}',
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
                asesi['status']!,
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

  Widget _buildInformasiContent() {
    return Column(
      children: [
        _buildInfoRow('Skema Sertifikasi', widget.skema),
        _buildInfoRow('Tempat Uji (TUK)', widget.tuk),
        _buildInfoRow('Nama Asesor', widget.asesorName),
        _buildInfoRow('Tanggal Status', widget.tanggalStatus),
        _buildInfoRow('Catatan', 'Dokumen laporan lengkap & terverifikasi.'),
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

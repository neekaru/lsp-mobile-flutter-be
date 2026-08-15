import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class AsesorDetailAsesiScreen extends StatefulWidget {
  final int asesiId;
  final String namaAsesi;
  final String skema;
  final String tuk;
  final String jadwal;

  const AsesorDetailAsesiScreen({
    super.key,
    required this.asesiId,
    required this.namaAsesi,
    this.skema = '',
    this.tuk = '',
    this.jadwal = '',
  });

  @override
  State<AsesorDetailAsesiScreen> createState() => _AsesorDetailAsesiScreenState();
}

class _AsesorDetailAsesiScreenState extends State<AsesorDetailAsesiScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  AsesorAsesiDetailData? _detailData;

  // Selected assessment form: 'APL01', 'APL02', 'AK01', 'AK02', 'AK03', 'AK04', 'AK05'
  String _selectedForm = 'APL01';

  final List<Map<String, String>> _formList = [
    {'id': 'APL01', 'title': '1. APL-01', 'subtitle': 'Permohonan Sertifikasi'},
    {'id': 'APL02', 'title': '2. APL-02', 'subtitle': 'Asesmen Mandiri'},
    {'id': 'AK01', 'title': '3. AK-01', 'subtitle': 'Persetujuan Asesmen'},
    {'id': 'AK02', 'title': '4. AK-02', 'subtitle': 'Rekaman Asesmen'},
    {'id': 'AK03', 'title': '5. AK-03', 'subtitle': 'Umpan Balik Asesi'},
    {'id': 'AK04', 'title': '6. AK-04', 'subtitle': 'Banding Asesmen'},
    {'id': 'AK05', 'title': '7. AK-05', 'subtitle': 'Laporan Asesmen'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await AsesorService.getAsesiDetail(widget.asesiId);
      if (res != null) {
        setState(() {
          _detailData = res;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat detail asesi.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final String nama = _detailData?.namaLengkap ?? widget.namaAsesi;
    final String skema = _detailData?.skemaSertifikat.isNotEmpty == true
        ? _detailData!.skemaSertifikat
        : (widget.skema.isNotEmpty ? widget.skema : 'Skema Sertifikasi');
    final String tuk = _detailData?.tukNama.isNotEmpty == true
        ? _detailData!.tukNama
        : (widget.tuk.isNotEmpty ? widget.tuk : 'TUK');
    final String jadwal = _detailData?.jadwalNama.isNotEmpty == true
        ? _detailData!.jadwalNama
        : (widget.jadwal.isNotEmpty ? widget.jadwal : 'Jadwal Asesmen');
    final String noPeserta = _detailData?.noPeserta.isNotEmpty == true
        ? _detailData!.noPeserta
        : 'PES-${widget.asesiId.toString().padLeft(4, '0')}';
    final String nik = _detailData?.nik ?? '-';
    final String rekomendasi = _detailData?.rekomendasiAsesor ?? 'Belum Dinilai';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Detail Asesi',
            rightWidget: SizedBox(width: 32),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : RefreshIndicator(
                        onRefresh: _fetchDetail,
                        color: const Color(0xFF2563EB),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Top Header Card
                              _buildHeaderCard(
                                nama: nama,
                                noPeserta: noPeserta,
                                nik: nik,
                                skema: skema,
                                tuk: tuk,
                                jadwal: jadwal,
                                rekomendasi: rekomendasi,
                              ),

                              const SizedBox(height: 16),

                              // 2. Info Utama Asesi Card
                              _buildInfoUtamaCard(),

                              const SizedBox(height: 20),

                              // 3. Dropdown Menu / Form Selector Section
                              _buildFormSelector(),

                              const SizedBox(height: 16),

                              // 4. Form Content Area
                              _buildActiveFormContent(),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
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
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _fetchDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard({
    required String nama,
    required String noPeserta,
    required String nik,
    required String skema,
    required String tuk,
    required String jadwal,
    required String rekomendasi,
  }) {
    Color badgeBg = const Color(0xFFEFF6FF);
    Color badgeText = const Color(0xFF2563EB);

    if (rekomendasi.toLowerCase().contains('kompeten') &&
        !rekomendasi.toLowerCase().contains('belum')) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF059669);
    } else if (rekomendasi.toLowerCase().contains('belum')) {
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = const Color(0xFFDC2626);
    }

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF2563EB),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. Peserta: $noPeserta',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rekomendasi,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildInfoPill(Icons.badge_outlined, 'NIK: $nik'),
          const SizedBox(height: 6),
          _buildInfoPill(LucideIcons.award, skema),
          const SizedBox(height: 6),
          _buildInfoPill(LucideIcons.building, tuk),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoUtamaCard() {
    final d = _detailData;
    if (d == null) return const SizedBox.shrink();

    final ttl = '${d.tempatLahir.isNotEmpty ? d.tempatLahir : "-"}'
        '${d.tanggalLahir.isNotEmpty ? ", ${d.tanggalLahir}" : ""}';
    final jenisKel = d.jenisKelamin == '1' || d.jenisKelamin.toLowerCase().contains('laki')
        ? 'Laki-Laki'
        : (d.jenisKelamin == '2' || d.jenisKelamin.toLowerCase().contains('perempuan')
            ? 'Perempuan'
            : (d.jenisKelamin.isNotEmpty ? d.jenisKelamin : '-'));

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Informasi Utama Asesi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDetailRow('Tempat, Tanggal Lahir', ttl),
          _buildDetailRow('Jenis Kelamin', jenisKel),
          _buildDetailRow('Alamat', d.alamat.isNotEmpty ? d.alamat : '-'),
          _buildDetailRow('No. Telepon / HP', d.noTelepon.isNotEmpty ? d.noTelepon : '-'),
          _buildDetailRow('Email', d.email.isNotEmpty ? d.email : '-'),
          _buildDetailRow('Institusi / Sekolah', d.institusi.isNotEmpty ? d.institusi : '-'),
          _buildDetailRow('Jadwal Asesmen', d.jadwalNama.isNotEmpty ? d.jadwalNama : '-'),
          _buildDetailRow('Tanggal Jadwal', d.jadwalTanggal.isNotEmpty ? d.jadwalTanggal : '-'),
          _buildDetailRow('TUK', d.tukNama.isNotEmpty ? d.tukNama : '-'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Formulir Asesmen',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedForm,
                  isDense: true,
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                  items: _formList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['id'],
                      child: Text(item['title']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedForm = val;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Horizontal Chip Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _formList.map((item) {
              final isSelected = _selectedForm == item['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(item['title']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedForm = item['id']!;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFormContent() {
    switch (_selectedForm) {
      case 'APL01':
        return _buildAPL01Section();
      case 'APL02':
        return _buildAPL02Section();
      case 'AK01':
        return _buildAK01Section();
      case 'AK02':
        return _buildAK02Section();
      case 'AK03':
        return _buildAK03Section();
      case 'AK04':
        return _buildAK04Section();
      case 'AK05':
        return _buildAK05Section();
      default:
        return _buildAPL01Section();
    }
  }

  // --- 1. APL-01 Section ---
  Widget _buildAPL01Section() {
    final apl01 = _detailData?.apl01;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FR-APL.01 Permohonan Sertifikasi',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apl01?.status ?? 'Terverifikasi',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailRow('Rekomendasi Admin', apl01?.rekomendasi ?? 'Diterima Sebagai Peserta Asesmen'),
          if (apl01?.catatan.isNotEmpty == true)
            _buildDetailRow('Catatan', apl01!.catatan),
          if (apl01?.tanggalValidasi.isNotEmpty == true)
            _buildDetailRow('Tanggal Validasi', apl01!.tanggalValidasi),
          const SizedBox(height: 14),
          const Text(
            'Bukti Kelengkapan Pemohon:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (apl01 != null && apl01.buktiDokumen.isNotEmpty)
            ...apl01.buktiDokumen.map((doc) => _buildDocItem(doc.nama, doc.jenis, doc.ada))
          else ...[
            _buildDocItem('Pas Foto 3x4 Background Merah', 'Wajib', true),
            _buildDocItem('Kartu Tanda Penduduk (KTP)', 'Wajib', true),
            _buildDocItem('Ijazah Terakhir / Transkrip', 'Wajib', true),
            _buildDocItem('Curriculum Vitae (CV)', 'Wajib', true),
            _buildDocItem('Portofolio / Sertifikat Terkait', 'Tambahan', true),
          ],
        ],
      ),
    );
  }

  Widget _buildDocItem(String name, String jenis, bool ada) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            ada ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: ada ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: jenis == 'Wajib' ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              jenis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: jenis == 'Wajib' ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. APL-02 Section ---
  Widget _buildAPL02Section() {
    final apl02 = _detailData?.apl02;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FR-APL.02 Asesmen Mandiri',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apl02?.status ?? 'Lengkap',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
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
                child: _buildMiniStat(
                  'Total Unit',
                  '${apl02?.totalUnit ?? 0}',
                  const Color(0xFF2563EB),
                  const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  'Kompeten [K]',
                  '${apl02?.totalK ?? 0}',
                  const Color(0xFF059669),
                  const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  'Belum [BK]',
                  '${apl02?.totalBK ?? 0}',
                  const Color(0xFFDC2626),
                  const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Daftar Unit Kompetensi:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (apl02 != null && apl02.units.isNotEmpty)
            ...apl02.units.map((u) => _buildUnitItem(u))
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Data unit kompetensi telah terverifikasi kompeten pada skema sertifikasi.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color textCol, Color bgCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitItem(APL02UnitItem unit) {
    final isK = unit.statusKompeten == 'K';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isK ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              unit.statusKompeten,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isK ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unit.kodeUnit.isNotEmpty)
                  Text(
                    unit.kodeUnit,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                Text(
                  unit.judulUnit,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. AK-01 Section ---
  Widget _buildAK01Section() {
    final ak01 = _detailData?.ak01;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FR-AK.01 Persetujuan & Kerahasiaan',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ak01?.status ?? 'Disetujui',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailRow('Pernyataan Asesi', ak01?.persetujuan ?? 'Asesi Menyetujui Pelaksanaan Asesmen Sesuai Prosedur LSP'),
          _buildDetailRow('TUK Pelaksanaan', ak01?.tuk ?? _detailData?.tukNama ?? '-'),
          _buildDetailRow('Tanggal Asesmen', ak01?.tglAsesmen ?? _detailData?.jadwalTanggal ?? '-'),
          _buildDetailRow('Status Tanda Tangan', ak01?.tandaTangan == true ? 'Sudah Ditandatangani' : 'Belum Ditandatangani'),
        ],
      ),
    );
  }

  // --- 4. AK-02 Section ---
  Widget _buildAK02Section() {
    final ak02 = _detailData?.ak02;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FR-AK.02 Rekaman Asesmen',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ak02?.status ?? 'Selesai',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailRow('Hasil Observasi Langsung', ak02?.hasilObservasi ?? 'Kompeten'),
          _buildDetailRow('Hasil Uji Praktik / Demonstrasi', ak02?.hasilPraktik ?? 'Kompeten'),
          _buildDetailRow('Hasil Pertanyaan Lisan', ak02?.hasilLisan ?? 'Kompeten'),
          _buildDetailRow('Hasil Tes Tertulis / Esai', ak02?.hasilEsai ?? 'Kompeten'),
          if (ak02?.komentarObservasi.isNotEmpty == true)
            _buildDetailRow('Komentar Asesor', ak02!.komentarObservasi),
        ],
      ),
    );
  }

  // --- 5. AK-03 Section ---
  Widget _buildAK03Section() {
    final ak03 = _detailData?.ak03;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FR-AK.03 Umpan Balik Asesi',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ak03?.status ?? 'Telah Diisi',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailRow('Umpan Balik Asesi', ak03?.umpanBalik ?? 'Proses asesmen berjalan sangat baik, objektif dan kondusif.'),
          if (ak03?.catatan.isNotEmpty == true)
            _buildDetailRow('Catatan Tambahan', ak03!.catatan),
        ],
      ),
    );
  }

  // --- 6. AK-04 Section ---
  Widget _buildAK04Section() {
    final ak04 = _detailData?.ak04;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FR-AK.04 Banding Asesmen',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ak04?.status ?? 'Tidak Ada Banding',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailRow('Permohonan Banding', ak04?.adaBanding == true ? 'Ada Pengajuan Banding' : 'Tidak Ada Pengajuan Banding'),
          if (ak04?.alasanBanding.isNotEmpty == true && ak04!.alasanBanding != '-')
            _buildDetailRow('Alasan Banding', ak04.alasanBanding),
        ],
      ),
    );
  }

  // --- 7. AK-05 Section ---
  Widget _buildAK05Section() {
    final ak05 = _detailData?.ak05;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FR-AK.05 Laporan Asesmen',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ak05?.status ?? 'Selesai',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailRow('Rekomendasi Akhir Asesor', ak05?.rekomendasi ?? _detailData?.rekomendasiAsesor ?? 'Kompeten'),
          if (ak05?.tanggalRekomendasi.isNotEmpty == true)
            _buildDetailRow('Tanggal Rekomendasi', ak05!.tanggalRekomendasi),
          _buildDetailRow('Pencapaian Unjuk Kerja', ak05?.pencapaian ?? 'Semua kriteria unjuk kerja telah terpenuhi'),
          _buildDetailRow('Unit yang Belum Kompeten', ak05?.unitBk ?? '-'),
          _buildDetailRow('Saran Tindak Lanjut', ak05?.saranTindakLanjut ?? 'Pertahankan kompetensi di bidang terkait'),
          _buildDetailRow('Pemeliharaan Kompetensi', ak05?.peliharaKompetensi ?? 'Mengikuti pelatihan berkelanjutan dan sertifikasi ulang'),
        ],
      ),
    );
  }
}

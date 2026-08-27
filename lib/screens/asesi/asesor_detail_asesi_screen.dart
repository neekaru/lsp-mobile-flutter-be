import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/asesi/asesi_ak_sections.dart';
import '../../widgets/asesi/asesi_apl_sections.dart';
import '../../widgets/asesi/asesi_info_cards.dart';

class AsesorDetailAsesiScreen extends StatefulWidget {
  final int asesiId;
  final String namaAsesi;
  final String skema;
  final String tuk;
  final String jadwal;
  final int? jadwalId;

  const AsesorDetailAsesiScreen({
    super.key,
    required this.asesiId,
    this.namaAsesi = '',
    this.skema = '',
    this.tuk = '',
    this.jadwal = '',
    this.jadwalId,
  });

  @override
  State<AsesorDetailAsesiScreen> createState() => _AsesorDetailAsesiScreenState();
}

class _AsesorDetailAsesiScreenState extends State<AsesorDetailAsesiScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  AsesorAsesiDetailData? _detailData;

  // Selected assessment form: default is 'APL01' as requested
  String _selectedForm = 'APL01';
  bool _isInfoUtamaExpanded = false;

  final List<Map<String, String>> _formList = [
    {
      'id': 'APL01',
      'code': 'FR-APL.01',
      'title': '1. FR-APL.01 Permohonan Sertifikasi',
      'short': '1. APL-01',
      'desc': 'Permohonan Sertifikasi & Dokumen',
    },
    {
      'id': 'APL02',
      'code': 'FR-APL.02',
      'title': '2. FR-APL.02 Asesmen Mandiri',
      'short': '2. APL-02',
      'desc': 'Daftar Unit Kompetensi Mandiri',
    },
    {
      'id': 'AK07',
      'code': 'FR-AK.07',
      'title': '3. FR-AK.07 Penyesuaian Wajar Beralasan',
      'short': '3. AK-07',
      'desc': 'Penyesuaian Wajar & Beralasan',
    },
    {
      'id': 'AK01',
      'code': 'FR-AK.01',
      'title': '4. FR-AK.01 Persetujuan Asesmen',
      'short': '4. AK-01',
      'desc': 'Persetujuan & Kerahasiaan',
    },
    {
      'id': 'AK02',
      'code': 'FR-AK.02',
      'title': '5. FR-AK.02 Rekaman Asesmen',
      'short': '5. AK-02',
      'desc': 'Hasil Observasi, Praktik, Lisan & Esai',
    },
    {
      'id': 'AK03',
      'code': 'FR-AK.03',
      'title': '6. FR-AK.03 Umpan Balik Asesi',
      'short': '6. AK-03',
      'desc': 'Umpan Balik & Catatan Asesi',
    },
    {
      'id': 'AK04A',
      'code': 'FR-AK.04A',
      'title': '7. FR-AK.04A Permohonan Banding',
      'short': '7. AK-04A',
      'desc': 'Pengajuan Permohonan Banding Asesi',
    },
    {
      'id': 'AK04B',
      'code': 'FR-AK.04B',
      'title': '8. FR-AK.04B Keputusan Banding',
      'short': '8. AK-04B',
      'desc': 'Keputusan Banding oleh Komite / Tim',
    },
  ];

  bool isFormUnlocked(String formId) {
    if (_detailData == null) return formId == 'APL01';

    switch (formId) {
      case 'APL01':
        return true;
      case 'APL02':
        // Unlocked if APL-01 is complete / reviewed
        return _detailData!.apl01.isApproved ||
            _detailData!.apl01.status == 'Diterima' ||
            _detailData!.apl01.status == 'Lengkap' ||
            _detailData!.apl01.status != 'Belum Diverifikasi' ||
            _detailData!.apl02.isApproved;
      case 'AK07':
        // Unlocked if APL-02 has recommendation / approved
        return _detailData!.apl02.isApproved ||
            _detailData!.apl02.rekomendasi != 'Belum Diverifikasi' ||
            _detailData!.ak01.isApproved;
      case 'AK01':
        // Unlocked if APL-02 and AK-07 are completed
        return _detailData!.apl02.isApproved ||
            _detailData!.apl02.rekomendasi != 'Belum Diverifikasi' ||
            _detailData!.ak01.isApproved;
      case 'AK02':
        // Unlocked if AK-01 is agreed / approved
        return _detailData!.ak01.isApproved ||
            _detailData!.ak01.status == 'Disetujui' ||
            _detailData!.rekomendasiAsesorCode == '1' ||
            _detailData!.rekomendasiAsesorCode == '2';
      case 'AK03':
        // Unlocked if AK-02 has recommendation
        return _detailData!.rekomendasiAsesorCode == '1' ||
            _detailData!.rekomendasiAsesorCode == '2' ||
            _detailData!.ak02.isApproved;
      case 'AK04':
      case 'AK04A':
      case 'AK04B':
        // Unlocked if AK-03 is completed
        return _detailData!.ak03.isApproved ||
            _detailData!.ak03.status == 'Lengkap' ||
            _detailData!.rekomendasiAsesorCode == '1' ||
            _detailData!.rekomendasiAsesorCode == '2';
      default:
        return true;
    }
  }

  String getLockReason(String formId) {
    switch (formId) {
      case 'APL02':
        return 'Selesaikan dan verifikasi FR-APL.01 terlebih dahulu.';
      case 'AK07':
        return 'Selesaikan dan simpan rekomendasi FR-APL.02 terlebih dahulu.';
      case 'AK01':
        return 'Selesaikan FR-APL.02 dan FR-AK.07 terlebih dahulu.';
      case 'AK02':
        return 'Selesaikan dan setujui formulir FR-AK.01 terlebih dahulu.';
      case 'AK03':
        return 'Selesaikan dan simpan rekomendasi FR-AK.02 terlebih dahulu.';
      case 'AK04':
      case 'AK04A':
      case 'AK04B':
        return 'Selesaikan pengisian FR-AK.03 terlebih dahulu.';
      default:
        return 'Formulir belum dapat diakses.';
    }
  }

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
    final String rekomendasi = _detailData?.rekomendasiAsesor ?? 'Belum Rekomendasi';

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
                              AsesiHeaderCard(
                                nama: nama,
                                noPeserta: noPeserta,
                                nik: nik,
                                skema: skema,
                                tuk: tuk,
                                jadwal: jadwal,
                                rekomendasi: rekomendasi,
                              ),

                              const SizedBox(height: 12),

                              // 2. Dropdown Menu Form Selector (Ditaruh Di Atas Sesuai Instruksi)
                              _buildTopDropdownMenu(),

                              const SizedBox(height: 10),

                              // 3. Quick Form Tabs (Pills)
                              _buildQuickFormPills(),

                              const SizedBox(height: 12),

                              // 4. Collapsible Info Utama Asesi (Bisa dibuka-tutup agar layar fokus ke form)
                              _buildCollapsibleInfoUtama(),

                              const SizedBox(height: 14),

                              // 5. Active Form Content Area (Hanya fokus menampilkan satu form yang dipilih)
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

  /// Dropdown Menu Utama di Bagian Atas
  Widget _buildTopDropdownMenu() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x062563EB),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.file_text,
              size: 20,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Formulir Asesmen:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedForm,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF2563EB),
                      size: 22,
                    ),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    items: _formList.map((item) {
                      final unlocked = isFormUnlocked(item['id']!);
                      return DropdownMenuItem<String>(
                        value: item['id'],
                        child: Row(
                          children: [
                            if (!unlocked) ...[
                              const Icon(LucideIcons.lock, size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                item['title']!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: unlocked ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                  fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        if (!isFormUnlocked(val)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(LucideIcons.lock, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(getLockReason(val))),
                                ],
                              ),
                              backgroundColor: const Color(0xFFE11D48),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _selectedForm = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Form Pills
  Widget _buildQuickFormPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _formList.map((item) {
          final formId = item['id']!;
          final isSelected = _selectedForm == formId;
          final unlocked = isFormUnlocked(formId);

          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (!unlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(LucideIcons.lock, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(getLockReason(formId))),
                        ],
                      ),
                      backgroundColor: const Color(0xFFE11D48),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                setState(() {
                  _selectedForm = formId;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (unlocked ? Colors.white : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (unlocked ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1)),
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x142563EB),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!unlocked) ...[
                      const Icon(LucideIcons.lock, size: 11, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      item['short']!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (unlocked ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Collapsible Info Utama Asesi Card (Agar tidak memakan tempat saat membaca form panjang)
  Widget _buildCollapsibleInfoUtama() {
    if (_detailData == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _isInfoUtamaExpanded = !_isInfoUtamaExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 17,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Informasi Utama Asesi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _isInfoUtamaExpanded ? 'Tutup' : 'Lihat Detail',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isInfoUtamaExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isInfoUtamaExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: AsesiInfoUtamaCard(detailData: _detailData),
            ),
          ],
        ],
      ),
    );
  }

  /// Menampilkan SATU form yang aktif secara fokus
  Widget _buildActiveFormContent() {
    if (!isFormUnlocked(_selectedForm)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Icon(LucideIcons.lock, size: 28, color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Formulir Masih Terkunci',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                getLockReason(_selectedForm),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    switch (_selectedForm) {
      case 'APL01':
        return APL01Section(detailData: _detailData);
      case 'APL02':
        return APL02Section(
          detailData: _detailData,
          onSaveSuccess: _fetchDetail,
        );
      case 'AK07':
        return AK07Section(detailData: _detailData);
      case 'AK01':
        return AK01Section(detailData: _detailData);
      case 'AK02':
        return AK02Section(
          detailData: _detailData,
          onSaveSuccess: _fetchDetail,
        );
      case 'AK03':
        return AK03Section(detailData: _detailData);
      case 'AK04A':
        return AK04ASection(detailData: _detailData);
      case 'AK04B':
        return AK04BSection(detailData: _detailData);
      case 'AK04':
        return AK04Section(detailData: _detailData);
      default:
        return APL01Section(detailData: _detailData);
    }
  }
}

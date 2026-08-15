import 'package:flutter/material.dart';
import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/asesi/asesi_form_sections.dart';

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
                              AsesiHeaderCard(
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
                              AsesiInfoUtamaCard(detailData: _detailData),

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
        return APL01Section(detailData: _detailData);
      case 'APL02':
        return APL02Section(detailData: _detailData);
      case 'AK01':
        return AK01Section(detailData: _detailData);
      case 'AK02':
        return AK02Section(detailData: _detailData);
      case 'AK03':
        return AK03Section(detailData: _detailData);
      case 'AK04':
        return AK04Section(detailData: _detailData);
      case 'AK05':
        return AK05Section(detailData: _detailData);
      default:
        return APL01Section(detailData: _detailData);
    }
  }
}

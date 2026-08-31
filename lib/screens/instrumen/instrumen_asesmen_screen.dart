import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/instrumen/ia01_observasi_widget.dart';
import '../../widgets/instrumen/ia02_tugas_praktik_widget.dart';
import '../../widgets/instrumen/ia03_pertanyaan_lisan_widget.dart';
import '../../widgets/instrumen/ia04a_instruksi_terstruktur_widget.dart';
import '../../widgets/instrumen/ia04b_penilaian_proyek_widget.dart';
import '../../widgets/instrumen/ia05_pertanyaan_tertulis_widget.dart';

import '../../services/asesor/asesor_service.dart';

class InstrumenAsesmenScreen extends StatefulWidget {
  final int asesiId;
  final String namaAsesi;
  final String skema;
  final String tuk;
  final String jadwal;
  final String initialForm; // 'IA01', 'IA02', 'IA03', 'IA04A', 'IA04B', 'IA05'

  const InstrumenAsesmenScreen({
    super.key,
    required this.asesiId,
    required this.namaAsesi,
    this.skema = 'Pemrogram Web Pratama',
    this.tuk = 'SMKN 5 MALANG',
    this.jadwal = '26 Agustus 2026',
    this.initialForm = 'IA01',
  });

  @override
  State<InstrumenAsesmenScreen> createState() => _InstrumenAsesmenScreenState();
}

class _InstrumenAsesmenScreenState extends State<InstrumenAsesmenScreen> {
  late String _selectedForm;
  bool _isLoading = true;
  List<IA01UnitKompetensi> _ia01Units = [];
  IA02TugasPraktikData? _ia02Data;
  IA03Data? _ia03Data;
  IA04AData? _ia04aData;
  IA04BData? _ia04bData;
  IA05Data? _ia05Data;

  final List<Map<String, String>> _iaForms = [
    {
      'id': 'IA01',
      'code': 'FR.IA.01',
      'title': 'FR.IA.01 Ceklis Observasi',
      'desc': 'Observasi Aktivitas Tempat Kerja / Simulasi',
      'status': 'Aktif',
    },
    {
      'id': 'IA02',
      'code': 'FR.IA.02',
      'title': 'FR.IA.02 Tugas Praktik',
      'desc': 'Tugas Praktik Demonstrasi Peserta',
      'status': 'Aktif',
    },
    {
      'id': 'IA04A',
      'code': 'FR.IA.04A',
      'title': 'FR.IA.04A Instruksi Terstruktur (DIT)',
      'desc': 'Skenario Kasus STAR & Instruksi Presentasi',
      'status': 'Aktif',
    },
    {
      'id': 'IA04B',
      'code': 'FR.IA.04B',
      'title': 'FR.IA.04B Penilaian Proyek',
      'desc': 'Rubrik Penilaian Aspek Proyek Terstruktur',
      'status': 'Aktif',
    },
    {
      'id': 'IA03',
      'code': 'FR.IA.03',
      'title': 'FR.IA.03 Pertanyaan Mendukung Observasi',
      'desc': 'Pertanyaan Untuk Mendukung Observasi',
      'status': 'Aktif',
    },
    {
      'id': 'IA05',
      'code': 'FR.IA.05',
      'title': 'FR.IA.05 Pertanyaan Tertulis',
      'desc': 'Pilihan Ganda / Esai & Lembar Jawaban',
      'status': 'Aktif',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedForm = widget.initialForm;
    _loadInstrumentData();
  }

  Future<void> _loadInstrumentData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        AsesorService.getIA01(widget.asesiId),
        AsesorService.getIA02(widget.asesiId),
        AsesorService.getIA03(widget.asesiId),
        AsesorService.getIA04A(widget.asesiId),
        AsesorService.getIA04B(widget.asesiId),
        AsesorService.getIA05(widget.asesiId),
      ]);

      final res01 = futures[0];
      final res02 = futures[1];
      final res03 = futures[2];
      final res04a = futures[3];
      final res04b = futures[4];
      final res05 = futures[5];

      if (mounted) {
        setState(() {
          if (res01 != null && res01['data'] != null && res01['data']['units'] != null) {
            final rawUnits = res01['data']['units'] as List;
            _ia01Units = rawUnits.map((u) => IA01UnitKompetensi.fromJson(u as Map<String, dynamic>)).toList();
          }

          if (res02 != null && res02['data'] != null) {
            _ia02Data = IA02TugasPraktikData.fromJson(res02['data'] as Map<String, dynamic>);
          }

          if (res03 != null && res03['data'] != null) {
            _ia03Data = IA03Data.fromJson(res03['data'] as Map<String, dynamic>);
          }

          if (res04a != null && res04a['data'] != null) {
            _ia04aData = IA04AData.fromJson(res04a['data'] as Map<String, dynamic>);
          }

          if (res04b != null && res04b['data'] != null) {
            _ia04bData = IA04BData.fromJson(res04b['data'] as Map<String, dynamic>);
          }

          if (res05 != null && res05['data'] != null) {
            _ia05Data = IA05Data.fromJson(res05['data'] as Map<String, dynamic>);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error loading instrument data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveIA01({
    String? rekomendasiKeseluruhan,
    String? catatanKeseluruhan,
    String? buktiTambahanPmo,
    String? buktiTambahan,
    String? alasanPmo,
  }) async {
    final payload = {
      'units': _ia01Units.map((u) => u.toJson()).toList(),
      'rekomendasi_keseluruhan': rekomendasiKeseluruhan ?? 'K',
      'catatan_keseluruhan': catatanKeseluruhan ?? '',
      'bukti_tambahan_pmo': buktiTambahanPmo ?? '0',
      'bukti_tambahan': buktiTambahan ?? '0',
      'alasan_pmo': alasanPmo ?? 'Sudah terpenuhi saat TPD',
    };
    final res = await AsesorService.saveIA01(asesiId: widget.asesiId, data: payload);
    if (!mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ FR.IA.01 Ceklis Observasi & Rekomendasi berhasil disimpan ke database'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Gagal menyimpan FR.IA.01, silakan periksa koneksi'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _saveIA02() async {
    if (_ia02Data == null) return;
    final res = await AsesorService.saveIA02(asesiId: widget.asesiId, data: _ia02Data!.toJson());
    if (!mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ FR.IA.02 Tugas Praktik berhasil disimpan ke database'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  Future<void> _saveIA03() async {
    if (_ia03Data == null) return;
    final res = await AsesorService.saveIA03(asesiId: widget.asesiId, data: _ia03Data!.toJson());
    if (!mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ FR.IA.03 Pertanyaan Lisan berhasil disimpan ke database'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  Future<void> _saveIA04A(String umpanBalik) async {
    final payload = {'umpan_balik_dit': umpanBalik};
    final res = await AsesorService.saveIA04A(asesiId: widget.asesiId, data: payload);
    if (!mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ FR.IA.04A Umpan Balik DIT berhasil disimpan ke database'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      if (_ia04aData != null) {
        setState(() => _ia04aData!.umpanBalikDit = umpanBalik);
      }
    }
  }

  Future<void> _saveIA04B(IA04BData updatedData) async {
    final res = await AsesorService.saveIA04B(asesiId: widget.asesiId, data: updatedData.toJson());
    if (!mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ FR.IA.04B Penilaian Proyek berhasil disimpan ke database'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      setState(() => _ia04bData = updatedData);
    }
  }

  Future<void> _saveIA05() async {
    if (_ia05Data == null) return;
    final res = await AsesorService.saveIA05(asesiId: widget.asesiId, data: _ia05Data!.toJson());
    if (!mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ FR.IA.05 Pertanyaan Tertulis berhasil disimpan ke database'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Instrumen Asesmen (FR.IA)',
            rightWidget: SizedBox(width: 32),
          ),

          // Header Info Peserta
          _buildAsesiHeaderBanner(),

          // Form Selector Tabs (IA.01, IA.02, IA.03, IA.05)
          _buildFormTabs(),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body Active Form
          Expanded(
            child: _buildActiveFormContent(),
          ),
        ],
      ),
    );
  }

  /// Banner informasi ringkas asesi
  Widget _buildAsesiHeaderBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.user_check,
              size: 20,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaAsesi,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.skema} • ${widget.tuk}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Form Tab Pills (IA.01, IA.02, IA.03, IA.05)
  Widget _buildFormTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Row(
        children: _iaForms.map((item) {
          final isSelected = _selectedForm == item['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _selectedForm = item['id']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x182563EB),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      item['code']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                    if (item['status'] == 'Segera') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.file_text,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan konten form instrumen asesmen yang dipilih
  Widget _buildActiveFormContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Memuat data instrumen dari database...',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_selectedForm) {
      case 'IA01':
        if (_ia01Units.isEmpty) {
          return _buildEmptyState('Belum ada unit kompetensi observasi yang terdaftar pada skema ini di database.');
        }
        return IA01ObservasiWidget(
          units: _ia01Units,
          onFinished: _saveIA01,
          onFinishedWithRekom: (rekom, catatan, {alasanPmo, buktiTambahan, buktiTambahanPmo}) => _saveIA01(
            rekomendasiKeseluruhan: rekom,
            catatanKeseluruhan: catatan,
            buktiTambahanPmo: buktiTambahanPmo,
            buktiTambahan: buktiTambahan,
            alasanPmo: alasanPmo,
          ),
        );
      case 'IA02':
        if (_ia02Data == null) {
          return _buildEmptyState('Belum ada skenario tugas praktik demonstrasi di database untuk skema ini.');
        }
        return IA02TugasPraktikWidget(
          data: _ia02Data!,
          onSaved: _saveIA02,
        );
      case 'IA04A':
        if (_ia04aData == null) {
          return _buildEmptyState('Belum ada instruksi proyek terstruktur (DIT) di database untuk skema ini.');
        }
        return IA04AInstruksiTerstrukturWidget(
          data: _ia04aData,
          onSave: _saveIA04A,
        );
      case 'IA04B':
        if (_ia04bData == null || _ia04bData!.items.isEmpty) {
          return _buildEmptyState('Belum ada rubrik penilaian proyek terstruktur di database untuk skema ini.');
        }
        return IA04BPenilaianProyekWidget(
          data: _ia04bData,
          onSave: _saveIA04B,
        );
      case 'IA03':
        if (_ia03Data == null || _ia03Data!.items.isEmpty) {
          return _buildEmptyState('Belum ada daftar pertanyaan lisan pendukung observasi di database untuk skema ini.');
        }
        return IA03PertanyaanLisanWidget(
          data: _ia03Data!,
          onSaved: _saveIA03,
        );
      case 'IA05':
        if (_ia05Data == null || _ia05Data!.items.isEmpty) {
          return _buildEmptyState('Belum ada soal pertanyaan tertulis di database untuk skema ini.');
        }
        return IA05PertanyaanTertulisWidget(
          data: _ia05Data!,
          onSaved: _saveIA05,
        );
      default:
        return _buildEmptyState('Form tidak ditemukan.');
    }
  }
}

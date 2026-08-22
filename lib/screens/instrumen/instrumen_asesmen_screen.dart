import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/instrumen_asesmen_models.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/instrumen/ia01_observasi_widget.dart';
import '../../widgets/instrumen/ia02_tugas_praktik_widget.dart';
import '../../widgets/instrumen/ia03_pertanyaan_lisan_widget.dart';
import '../../widgets/instrumen/ia05_pertanyaan_tertulis_widget.dart';

class InstrumenAsesmenScreen extends StatefulWidget {
  final int asesiId;
  final String namaAsesi;
  final String skema;
  final String tuk;
  final String jadwal;
  final String initialForm; // 'IA01', 'IA02', 'IA03', 'IA05'

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
  late List<IA01UnitKompetensi> _ia01Units;
  late IA02TugasPraktikData _ia02Data;
  late IA03Data _ia03Data;
  late IA05Data _ia05Data;

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
      'id': 'IA03',
      'code': 'FR.IA.03',
      'title': 'FR.IA.03 Pertanyaan Lisan',
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
    _ia01Units = InstrumenAsesmenMock.generateDefaultIA01Units();
    _ia02Data = InstrumenAsesmenMock.generateDefaultIA02Data(namaAsesi: widget.namaAsesi);
    _ia03Data = InstrumenAsesmenMock.generateDefaultIA03Data(namaAsesi: widget.namaAsesi);
    _ia05Data = InstrumenAsesmenMock.generateDefaultIA05Data(namaAsesi: widget.namaAsesi);
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

  /// Menampilkan konten form instrumen asesmen yang dipilih
  Widget _buildActiveFormContent() {
    switch (_selectedForm) {
      case 'IA01':
        return IA01ObservasiWidget(
          units: _ia01Units,
          onFinished: () {
            // Bisa diarahkan ke IA02 berikutnya jika ingin alur berurutan
          },
        );
      case 'IA02':
        return IA02TugasPraktikWidget(
          data: _ia02Data,
          onSaved: () {
            // Callback when IA02 is saved
          },
        );
      case 'IA03':
        return IA03PertanyaanLisanWidget(
          data: _ia03Data,
          onSaved: () {
            // Callback when IA03 is saved
          },
        );
      case 'IA05':
        return IA05PertanyaanTertulisWidget(
          data: _ia05Data,
          onSaved: () {
            // Callback when IA05 is saved
          },
        );
      default:
        return IA01ObservasiWidget(units: _ia01Units);
    }
  }

  /// Placeholder UI untuk IA.02, IA.03, IA.05
  Widget _buildPlaceholderForm({
    required String code,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              code,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedForm = 'IA01';
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.arrow_left, size: 16),
              label: const Text('Kembali ke FR.IA.01 (Ceklis Observasi)'),
            ),
          ],
        ),
      ),
    );
  }
}

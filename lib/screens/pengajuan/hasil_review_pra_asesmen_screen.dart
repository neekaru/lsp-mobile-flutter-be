import 'package:flutter/material.dart';
import '../../services/sertifikat_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'tes_tertulis_screen.dart';

class HasilReviewPraAsesmenScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;
  final String tuk;
  final String tanggalAsesmen;
  final String namaAsesor;

  const HasilReviewPraAsesmenScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
    this.tuk = '',
    this.tanggalAsesmen = '',
    this.namaAsesor = '',
  });

  @override
  State<HasilReviewPraAsesmenScreen> createState() =>
      _HasilReviewPraAsesmenScreenState();
}

class _HasilReviewPraAsesmenScreenState
    extends State<HasilReviewPraAsesmenScreen> {
  late String _title;
  late String _kodeSkema;
  String _tuk = '';
  String _tanggalAsesmen = '';
  String _namaAsesor = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _kodeSkema = widget.kodeSkema;
    _tuk = widget.tuk;
    _tanggalAsesmen = widget.tanggalAsesmen;
    _namaAsesor = widget.namaAsesor;
    if (_tuk.isEmpty || _tanggalAsesmen.isEmpty || _namaAsesor.isEmpty) {
      _loadInfo();
    }
  }

  Future<void> _loadInfo() async {
    setState(() => _loading = true);
    try {
      final info = await SertifikatService.getPraAsesmenInfo(
        widget.skemaId,
        widget.title,
        widget.kodeSkema,
      );
      if (!mounted) return;
      setState(() {
        if (info.namaSkema.isNotEmpty) _title = info.namaSkema;
        if (info.kodeSkema.isNotEmpty) _kodeSkema = info.kodeSkema;
        if (info.tuk.isNotEmpty) _tuk = info.tuk;
        if (info.tanggalAsesmen.isNotEmpty) {
          _tanggalAsesmen = info.tanggalAsesmen;
        }
        if (info.namaAsesor.isNotEmpty) _namaAsesor = info.namaAsesor;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _orDash(String v) => v.trim().isEmpty ? '—' : v.trim();

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(context),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5B9FD8),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      children: [
                        _buildStatusBanner(),
                        const SizedBox(height: 20),
                        _buildDetailCard(),
                        const SizedBox(height: 16),
                        _buildMetaCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return const CustomAppBar(
      title: 'Hasil Review Pra-Asessmen',
      rightWidget: SizedBox(width: 32),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF22C55E),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Status Review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14532D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Anda memenuhi persyaratan untuk mengikuti Tes Tertulis.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF166534),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (_kodeSkema.isNotEmpty)
                      Text(
                        _kodeSkema,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          _buildChecklistItem('Portofolio Lengkap'),
          const SizedBox(height: 12),
          _buildChecklistItem('Bukti Kompetensi Valid'),
          const SizedBox(height: 12),
          _buildChecklistItem('Pra Asesmen Disetujui'),
        ],
      ),
    );
  }

  Widget _buildMetaCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetaRow('TUK', _orDash(_tuk)),
          const SizedBox(height: 12),
          _buildMetaRow('Tanggal Asesmen', _orDash(_tanggalAsesmen)),
          const SizedBox(height: 12),
          _buildMetaRow('Asesor', _orDash(_namaAsesor)),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Color(0xFF16A34A),
              size: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TesTertulisScreen(
                    skemaId: widget.skemaId,
                    title: _title,
                    kodeSkema: _kodeSkema,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9FD8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Mulai Tes Tertulis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

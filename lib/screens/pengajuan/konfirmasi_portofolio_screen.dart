import 'package:flutter/material.dart';
import '../../services/asesi_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'konfirmasi_persetujuan_screen.dart';

class KonfirmasiPortofolioScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;
  final int? sertifikasiId;

  const KonfirmasiPortofolioScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
    this.sertifikasiId,
  });

  @override
  State<KonfirmasiPortofolioScreen> createState() =>
      _KonfirmasiPortofolioScreenState();
}

class _KonfirmasiPortofolioScreenState
    extends State<KonfirmasiPortofolioScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadPortofolio();
  }

  Future<void> _loadPortofolio() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      int? sertId = widget.sertifikasiId;
      if (sertId == null || sertId <= 0) {
        final status = await AsesiService.getSertifikasiStatus(widget.skemaId);
        final raw = status?['sertifikasi_id'];
        if (raw is int) {
          sertId = raw;
        } else if (raw != null) {
          sertId = int.tryParse(raw.toString());
        }
      }

      if (sertId == null || sertId <= 0) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Pendaftaran skema belum ditemukan. Lengkapi pendaftaran dulu.';
          _documents = [];
        });
        return;
      }

      final docs = await AsesiService.getPortofolioList(sertId);
      if (!mounted) return;
      setState(() {
        _documents = docs;
        _loading = false;
        _error = docs.isEmpty ? 'Belum ada dokumen portofolio untuk skema ini.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat portofolio. Coba lagi.';
        _documents = [];
      });
    }
  }

  String _fileNameOf(Map<String, dynamic> d) {
    final fn = d['file_name'];
    if (fn == null) return 'Belum diunggah';
    final s = fn.toString().trim();
    if (s.isEmpty || s == 'null') return 'Belum diunggah';
    // URL → basename
    if (s.contains('/')) {
      return s.split('/').last.split('?').first;
    }
    return s;
  }

  String _labelOf(Map<String, dynamic> d) {
    final label = d['label']?.toString().trim() ?? '';
    if (label.isNotEmpty) return label;
    final key = d['key']?.toString().trim() ?? '';
    if (key.isNotEmpty) return key.replaceAll('_', ' ');
    return 'Dokumen';
  }

  String _statusOf(Map<String, dynamic> d) {
    final st = (d['status']?.toString() ?? '').trim();
    if (st.isNotEmpty) return st;
    final fn = _fileNameOf(d);
    return fn == 'Belum diunggah' ? 'Belum Diunggah' : 'Diunggah';
  }

  bool _isVerified(String status) {
    final s = status.toLowerCase();
    return s.contains('verif') ||
        s.contains('lengkap') ||
        s.contains('unggah') && !s.contains('belum') ||
        s == 'ok' ||
        s == 'uploaded';
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Konfirmasi Portofolio',
            rightWidget: SizedBox(width: 32),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadPortofolio,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Portofolio Utama',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                _buildSchemeCard(
                                  'Skema Sertifikasi',
                                  widget.title,
                                ),
                                if (_error != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      _error!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  )
                                else
                                  ..._documents.map(
                                    (d) => _buildPortofolioItem(
                                      _labelOf(d),
                                      _fileNameOf(d),
                                      _statusOf(d),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildActionButton(context),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7E7E7E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortofolioItem(String name, String fileName, String status) {
    final ok = _isVerified(status) && fileName != 'Belum diunggah';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 12,
              color: fileName == 'Belum diunggah'
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF7E7E7E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Status : ',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7E7E7E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ok
                      ? const Color(0xFFE2F4E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ok
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KonfirmasiPersetujuanScreen(
                skemaId: widget.skemaId,
                title: widget.title,
                kodeSkema: widget.kodeSkema,
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
          'Selanjutnya',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

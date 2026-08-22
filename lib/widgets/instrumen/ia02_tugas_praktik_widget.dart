import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/instrumen_asesmen_models.dart';

class IA02TugasPraktikWidget extends StatefulWidget {
  final IA02TugasPraktikData data;
  final VoidCallback? onSaved;

  const IA02TugasPraktikWidget({
    super.key,
    required this.data,
    this.onSaved,
  });

  @override
  State<IA02TugasPraktikWidget> createState() => _IA02TugasPraktikWidgetState();
}

class _IA02TugasPraktikWidgetState extends State<IA02TugasPraktikWidget> {
  late TextEditingController _skenarioCtrl;
  late TextEditingController _perlengkapanCtrl;
  late TextEditingController _durasiCtrl;
  late TextEditingController _linkHasilCtrl;
  late TextEditingController _catatanCtrl;
  late TextEditingController _penyusunNamaCtrl;
  late TextEditingController _penyusunMetCtrl;
  late TextEditingController _validatorNamaCtrl;
  late TextEditingController _validatorMetCtrl;

  String? _rekomendasi;

  @override
  void initState() {
    super.initState();
    _skenarioCtrl = TextEditingController(text: widget.data.skenarioTugas);
    _perlengkapanCtrl = TextEditingController(text: widget.data.perlengkapanPeralatan);
    _durasiCtrl = TextEditingController(text: widget.data.durasiWaktu);
    _linkHasilCtrl = TextEditingController(text: widget.data.linkHasilPraktek);
    _catatanCtrl = TextEditingController(text: widget.data.catatan);
    _penyusunNamaCtrl = TextEditingController(text: widget.data.penyusunNama);
    _penyusunMetCtrl = TextEditingController(text: widget.data.penyusunNomorMet);
    _validatorNamaCtrl = TextEditingController(text: widget.data.validatorNama);
    _validatorMetCtrl = TextEditingController(text: widget.data.validatorNomorMet);
    _rekomendasi = widget.data.rekomendasi;
  }

  @override
  void dispose() {
    _skenarioCtrl.dispose();
    _perlengkapanCtrl.dispose();
    _durasiCtrl.dispose();
    _linkHasilCtrl.dispose();
    _catatanCtrl.dispose();
    _penyusunNamaCtrl.dispose();
    _penyusunMetCtrl.dispose();
    _validatorNamaCtrl.dispose();
    _validatorMetCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copyTugasLink() {
    final textToCopy = 'Skenario: ${_skenarioCtrl.text}\nDurasi: ${_durasiCtrl.text}\nLink: ${_linkHasilCtrl.text}';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informasi tugas praktik berhasil disalin ke clipboard.'),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _kirimTugasPraktek() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tugas Praktik Demonstrasi berhasil dikirimkan kepada ${widget.data.namaAsesi}.'),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isK = _rekomendasi == 'K';
    final isBK = _rekomendasi == 'BK';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Card Informasi Asesi & Penyusun ──
          _buildCard(
            title: 'Informasi Praktik Demonstrasi',
            icon: LucideIcons.user_check,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama Asesi', widget.data.namaAsesi, isHighlight: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Penyusun',
                        _penyusunNamaCtrl.text.isNotEmpty ? _penyusunNamaCtrl.text : 'Tim LSP',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        'No. MET',
                        _penyusunMetCtrl.text.isNotEmpty ? _penyusunMetCtrl.text : '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Validator',
                        _validatorNamaCtrl.text.isNotEmpty ? _validatorNamaCtrl.text : 'Master Asesor',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        'No. MET',
                        _validatorMetCtrl.text.isNotEmpty ? _validatorMetCtrl.text : '-',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 2. Card Skenario & Durasi Waktu ──
          _buildCard(
            title: 'Skenario & Petunjuk Tugas Praktik',
            icon: LucideIcons.file_text,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    const Text(
                      'Alokasi Waktu / Durasi:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        _durasiCtrl.text.isNotEmpty ? _durasiCtrl.text : '90 Menit',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Instruksi / Skenario Praktik Demonstrasi:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _skenarioCtrl,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 12.5, height: 1.35),
                  decoration: InputDecoration(
                    hintText: 'Tuliskan instruksi langkah skenario tugas praktik...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 3. Card Peralatan & Perlengkapan ──
          _buildCard(
            title: 'Peralatan & Perlengkapan Kerja',
            icon: LucideIcons.wrench,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Peralatan & Bahan yang Digunakan:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _perlengkapanCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12.5, height: 1.35),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Komputer, Aplikasi IDE/Database, Internet, Formulir SOP...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 4. Card Tautan Kirim & Hasil Tugas Praktik ──
          _buildCard(
            title: 'Tautan Kirim / Hasil Tugas Praktik',
            icon: LucideIcons.link_2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tautan / Link Cloud Hasil Tugas Praktik Asesi:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _linkHasilCtrl,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF2563EB)),
                  decoration: InputDecoration(
                    hintText: 'https://drive.google.com/... atau https://github.com/...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(LucideIcons.globe, size: 16, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Action Buttons for Link
                Row(
                  children: [
                    if (_linkHasilCtrl.text.trim().isNotEmpty) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl(_linkHasilCtrl.text.trim()),
                          icon: const Icon(LucideIcons.external_link, size: 14),
                          label: const Text('Buka Hasil', style: TextStyle(fontSize: 11.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyTugasLink,
                        icon: const Icon(LucideIcons.copy, size: 14),
                        label: const Text('Salin Info', style: TextStyle(fontSize: 11.5)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _kirimTugasPraktek,
                        icon: const Icon(LucideIcons.send, size: 14),
                        label: const Text('Kirim ke Asesi', style: TextStyle(fontSize: 11.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 5. Card Penilaian & Rekomendasi Asesor ──
          _buildCard(
            title: 'Penilaian & Rekomendasi Asesor',
            icon: LucideIcons.clipboard_check,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        'Rekomendasi :',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isK
                              ? const Color(0xFFDCFCE7)
                              : isBK
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isK
                                ? const Color(0xFF16A34A)
                                : isBK
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: (_rekomendasi == 'K' || _rekomendasi == 'BK') ? _rekomendasi : null,
                            isExpanded: true,
                            hint: const Text('- Pilih Rekomendasi -', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                            items: const [
                              DropdownMenuItem(
                                value: 'K',
                                child: Text(
                                  'Kompeten (K)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'BK',
                                child: Text(
                                  'Belum Kompeten (BK)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _rekomendasi = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Catatan Hasil Observasi Praktik Demonstrasi:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _catatanCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Tuliskan catatan pengamatan praktik jika ada...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 6. Bottom Action Button ──
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.data.skenarioTugas = _skenarioCtrl.text.trim();
                widget.data.durasiWaktu = _durasiCtrl.text.trim();
                widget.data.perlengkapanPeralatan = _perlengkapanCtrl.text.trim();
                widget.data.linkHasilPraktek = _linkHasilCtrl.text.trim();
                widget.data.catatan = _catatanCtrl.text.trim();
                widget.data.rekomendasi = _rekomendasi;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tugas Praktik Demonstrasi FR.IA.02 berhasil disimpan.'),
                    backgroundColor: Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                widget.onSaved?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text(
                'Simpan Tugas Praktik (IA.02)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : '-',
          style: TextStyle(
            fontSize: isHighlight ? 14 : 12.5,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? const Color(0xFF1E293B) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

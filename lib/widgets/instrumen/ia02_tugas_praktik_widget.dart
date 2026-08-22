import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter/services.dart';
import '../../models/instrumen_asesmen_models.dart';
import '../../widgets/asesi/asesi_form_common.dart';

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
        content: Text('Tugas Praktik Demonstrasi (TPD) berhasil dikirimkan kepada ${widget.data.namaAsesi}.'),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Top Header: Observasi Langsung (Blue Banner) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: const Text(
              'Observasi Langsung',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),

          // ── 2. Nama Lengkap Subheader ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Color(0xFFCBD5E1)),
                right: BorderSide(color: Color(0xFFCBD5E1)),
                bottom: BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 120,
                  child: Text(
                    'Nama Lengkap:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.data.namaAsesi,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── 3. Table Penyusun & Validator ──
          _buildPenyusunValidatorTable(),

          const SizedBox(height: 14),

          // ── 4. Yellow Title Banner (FR.IA.02) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE047), // Yellow BNSP banner
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'FR.IA.02. Tugas Praktik Demonstrasi',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: 0.2,
              ),
            ),
          ),

          // ── 5. Main Task & Requirements Table ──
          _buildTaskDetailsTable(),

          // ── 6. Submission & Link Table ──
          _buildSubmissionTable(),

          const SizedBox(height: 16),

          // ── 7. Penilaian & Rekomendasi Asesor ──
          _buildPenilaianCard(),

          const SizedBox(height: 16),

          // ── 8. Bottom Action Save Button ──
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tugas Praktik FR.IA.02 berhasil disimpan sementara (UI Mode).'),
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
                'Simpan Form FR.IA.02',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Tabel Status Penyusun & Validator
  Widget _buildPenyusunValidatorTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                SizedBox(
                  width: 90,
                  child: Text(
                    'STATUS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      'NAMA',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      'NOMOR MET',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      'TANDA TANGAN & TGL',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),

          // Row 1: Penyusun
          _buildPenyusunValidatorRow(
            status: 'Penyusun',
            namaCtrl: _penyusunNamaCtrl,
            metCtrl: _penyusunMetCtrl,
            tandaTanganStatus: widget.data.penyusunTandaTangan,
            isEven: false,
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Row 2: Validator
          _buildPenyusunValidatorRow(
            status: 'Validator',
            namaCtrl: _validatorNamaCtrl,
            metCtrl: _validatorMetCtrl,
            tandaTanganStatus: widget.data.validatorTandaTangan,
            isEven: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPenyusunValidatorRow({
    required String status,
    required TextEditingController namaCtrl,
    required TextEditingController metCtrl,
    required String tandaTanganStatus,
    required bool isEven,
  }) {
    return Container(
      color: isEven ? const Color(0xFFFAFAFA) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: TextFormField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Nama...',
                    hintStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B)),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: TextFormField(
                  controller: metCtrl,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'No MET...',
                    hintStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B)),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  tandaTanganStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: tandaTanganStatus.contains('Sudah') || tandaTanganStatus.contains('Tervalidasi')
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tabel Skenario, Perlengkapan, dan Durasi
  Widget _buildTaskDetailsTable() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFCBD5E1)),
          right: BorderSide(color: Color(0xFFCBD5E1)),
          bottom: BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Skenario Tugas Praktek
          _buildFormTableRow(
            label: 'Skenario Tugas Praktek',
            child: TextFormField(
              controller: _skenarioCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tuliskan deskripsi skenario tugas praktik...',
                hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(6),
              ),
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.35),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),

          // Row 2: Perlengkapan dan Peralatan
          _buildFormTableRow(
            label: 'Perlengkapan dan Peralatan',
            child: TextFormField(
              controller: _perlengkapanCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Daftar alat dan perlengkapan kerja...',
                hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(6),
              ),
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.35),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),

          // Row 3: Durasi Waktu
          _buildFormTableRow(
            label: 'Durasi Waktu',
            child: TextFormField(
              controller: _durasiCtrl,
              decoration: const InputDecoration(
                hintText: 'Contoh: 120 Menit',
                hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  /// Tabel Pengiriman & Hasil Praktek
  Widget _buildSubmissionTable() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFCBD5E1)),
          right: BorderSide(color: Color(0xFFCBD5E1)),
          bottom: BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
      child: Column(
        children: [
          // Row 4: Kirim Tugas Praktek
          _buildFormTableRow(
            label: 'Kirim Tugas Praktek',
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _kirimTugasPraktek,
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  icon: const Icon(LucideIcons.send, size: 13, color: Color(0xFF2563EB)),
                  label: const Text(
                    'Kirim Tugas Praktek',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _copyTugasLink,
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    'Copy',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),

          // Row 5: File Tugas Praktek
          _buildFormTableRow(
            label: 'File Tugas Praktek',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data.fileTugasPraktek,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.data.fileTugasPraktek.contains('Belum')
                          ? const Color(0xFF64748B)
                          : const Color(0xFF16A34A),
                    ),
                  ),
                ),
                if (widget.data.fileTugasPraktekUrl != null && widget.data.fileTugasPraktekUrl!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => openDocumentUrl(context, widget.data.fileTugasPraktekUrl),
                    icon: const Icon(LucideIcons.download, size: 14),
                    label: const Text('Unduh', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),

          // Row 6: Link Hasil Praktek
          _buildFormTableRow(
            label: 'Link Hasil Praktek',
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _linkHasilCtrl,
                    decoration: const InputDecoration(
                      hintText: 'https://github.com/... atau link drive tugas asesi',
                      hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (_linkHasilCtrl.text.trim().isNotEmpty)
                  InkWell(
                    onTap: () => openDocumentUrl(context, _linkHasilCtrl.text.trim()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                      child: Text(
                        'LINK',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTableRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 155,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Card Penilaian Praktik Demonstrasi
  Widget _buildPenilaianCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Penilaian Observasi Demonstrasi :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Kompeten (K)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() {
                      _rekomendasi = 'K';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _rekomendasi == 'K' ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _rekomendasi == 'K' ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                        width: _rekomendasi == 'K' ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _rekomendasi == 'K' ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: _rekomendasi == 'K' ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kompeten (K)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _rekomendasi == 'K' ? const Color(0xFF15803D) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Belum Kompeten (BK)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() {
                      _rekomendasi = 'BK';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _rekomendasi == 'BK' ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _rekomendasi == 'BK' ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
                        width: _rekomendasi == 'BK' ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _rekomendasi == 'BK' ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: _rekomendasi == 'BK' ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Belum Kompeten (BK)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _rekomendasi == 'BK' ? const Color(0xFFB91C1C) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Catatan / Feedback Asesor :',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _catatanCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan catatan hasil demonstrasi praktik asesi...',
              hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.all(10),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}

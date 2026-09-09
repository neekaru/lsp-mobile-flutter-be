import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/instrumen_asesmen_models.dart';
import '../../utils/url_helper.dart';

class IA11VerifikasiPortofolioWidget extends StatefulWidget {
  final IA11Data? data;
  final Function(IA11Data updatedData) onSave;

  const IA11VerifikasiPortofolioWidget({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  State<IA11VerifikasiPortofolioWidget> createState() =>
      _IA11VerifikasiPortofolioWidgetState();
}

class _IA11VerifikasiPortofolioWidgetState
    extends State<IA11VerifikasiPortofolioWidget> {
  late List<IA11DokumenItem> _dokumen;
  late String _isPortofolio;
  late TextEditingController _catatanController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _dokumen = widget.data?.dokumen.map((d) => IA11DokumenItem(
          no: d.no,
          nama: d.nama,
          fileName: d.fileName,
          url: d.url,
          valid: d.valid,
          asli: d.asli,
          terkini: d.terkini,
          memadai: d.memadai,
        )).toList() ?? [];
    _isPortofolio = widget.data?.isPortofolio ?? '1';
    _catatanController = TextEditingController(
      text: widget.data?.catatanPortofolio ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant IA11VerifikasiPortofolioWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initData();
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _setAllVATM(bool value) {
    setState(() {
      for (final doc in _dokumen) {
        doc.valid = value;
        doc.asli = value;
        doc.terkini = value;
        doc.memadai = value;
      }
    });
  }

  void _setDocVATM(int index, bool value) {
    setState(() {
      _dokumen[index].valid = value;
      _dokumen[index].asli = value;
      _dokumen[index].terkini = value;
      _dokumen[index].memadai = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    if (d == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Data FR.IA.11 belum tersedia untuk skema ini.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    final totalDocs = _dokumen.length;
    final totalMemadai = _dokumen.where((doc) => doc.valid && doc.asli && doc.terkini && doc.memadai).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Heading
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDD6FE)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.file_check, size: 20, color: Color(0xFF7C3AED)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FR.IA.11. CEKLIS VERIFIKASI PORTOFOLIO',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B21B6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Summary & Quick Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelayakan Portofolio (VATM):',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalMemadai / $totalDocs Memadai Penuh',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _setAllVATM(true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: const Color(0xFFEDE9FE),
                        foregroundColor: const Color(0xFF7C3AED),
                      ),
                      child: const Text('Semua VATM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () => _setAllVATM(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text('Reset', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Document List
          if (_dokumen.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text(
                  'Belum ada dokumen portofolio yang diunggah oleh asesi.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._dokumen.asMap().entries.map((entry) {
              final idx = entry.key;
              final doc = entry.value;
              return _buildDocCard(idx, doc);
            }),

          const SizedBox(height: 14),

          // Keputusan Asesor
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekomendasi / Keputusan Portofolio:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isPortofolio = '1'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isPortofolio == '1' ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isPortofolio == '1' ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                              width: _isPortofolio == '1' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isPortofolio == '1' ? LucideIcons.circle_check : LucideIcons.circle,
                                size: 16,
                                color: _isPortofolio == '1' ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Memadai (1)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _isPortofolio == '1' ? FontWeight.bold : FontWeight.normal,
                                  color: _isPortofolio == '1' ? const Color(0xFF15803D) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isPortofolio = '0'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isPortofolio == '0' ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isPortofolio == '0' ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                              width: _isPortofolio == '0' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isPortofolio == '0' ? LucideIcons.circle_x : LucideIcons.circle,
                                size: 16,
                                color: _isPortofolio == '0' ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Belum Memadai (0)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _isPortofolio == '0' ? FontWeight.bold : FontWeight.normal,
                                  color: _isPortofolio == '0' ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
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
                  'Catatan Verifikasi Portofolio Asesor:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan catatan tindak lanjut atau kesimpulan bukti portofolio...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 14),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            final updated = IA11Data(
                              asesiId: d.asesiId,
                              namaAsesi: d.namaAsesi,
                              skema: d.skema,
                              kodeSkema: d.kodeSkema,
                              dokumen: _dokumen,
                              catatanPortofolio: _catatanController.text.trim(),
                              isPortofolio: _isPortofolio,
                            );
                            await widget.onSave(updated);
                            if (mounted) {
                              setState(() => _isSaving = false);
                            }
                          },
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(LucideIcons.save, size: 16),
                    label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Verifikasi Portofolio (FR.IA.11)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _openDocument(String rawUrl) async {
    if (rawUrl.trim().isEmpty) return;
    final resolvedUrl = UrlHelper.resolveUrl(rawUrl);
    final uri = Uri.tryParse(resolvedUrl);
    if (uri != null && uri.hasScheme) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return;
        }
        if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          return;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka file: $resolvedUrl'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuka tautan: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL dokumen tidak valid: $rawUrl'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildDocCard(int index, IA11DokumenItem doc) {
    final isFullyVATM = doc.valid && doc.asli && doc.terkini && doc.memadai;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFullyVATM ? const Color(0xFFC4B5FD) : const Color(0xFFE2E8F0),
          width: isFullyVATM ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFullyVATM ? const Color(0xFF7C3AED) : const Color(0xFF64748B),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${doc.no}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.nama.isNotEmpty ? doc.nama : doc.fileName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.fileName,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    if (doc.url.isNotEmpty || doc.fileName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          final targetUrl = doc.url.isNotEmpty
                              ? doc.url
                              : '/storage/portofolio/${doc.fileName}';
                          _openDocument(targetUrl);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.external_link,
                                size: 13,
                                color: Color(0xFF7C3AED),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Buka Dokumen',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7C3AED),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (doc.url.isNotEmpty || doc.fileName.isNotEmpty)
                IconButton(
                  icon: const Icon(LucideIcons.external_link, size: 16, color: Color(0xFF7C3AED)),
                  tooltip: 'Buka Dokumen',
                  onPressed: () {
                    final targetUrl = doc.url.isNotEmpty
                        ? doc.url
                        : '/storage/portofolio/${doc.fileName}';
                    _openDocument(targetUrl);
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // VATM Row Checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aturan Bukti (VATM):',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              TextButton(
                onPressed: () => _setDocVATM(index, !isFullyVATM),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isFullyVATM ? 'Batalkan VATM' : 'Semua VATM',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Column(
            children: [
              Row(
                children: [
                  _buildVATMChip(
                    label: 'Valid (V)',
                    checked: doc.valid,
                    onTap: () => setState(() => doc.valid = !doc.valid),
                  ),
                  const SizedBox(width: 8),
                  _buildVATMChip(
                    label: 'Asli (A)',
                    checked: doc.asli,
                    onTap: () => setState(() => doc.asli = !doc.asli),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildVATMChip(
                    label: 'Terkini (T)',
                    checked: doc.terkini,
                    onTap: () => setState(() => doc.terkini = !doc.terkini),
                  ),
                  const SizedBox(width: 8),
                  _buildVATMChip(
                    label: 'Memadai (M)',
                    checked: doc.memadai,
                    onTap: () => setState(() => doc.memadai = !doc.memadai),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVATMChip({
    required String label,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: checked ? const Color(0xFFEDE9FE) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: checked ? const Color(0xFF7C3AED) : const Color(0xFFCBD5E1),
              width: checked ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                checked ? LucideIcons.square_check : LucideIcons.square,
                size: 13,
                color: checked ? const Color(0xFF7C3AED) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: checked ? FontWeight.bold : FontWeight.normal,
                  color: checked ? const Color(0xFF5B21B6) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

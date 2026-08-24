import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import '../../models/jadwal_models.dart';
import '../../services/asesi/asesi_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class AsesiAK03FormScreen extends StatefulWidget {
  final JadwalItem jadwal;

  const AsesiAK03FormScreen({
    super.key,
    required this.jadwal,
  });

  @override
  State<AsesiAK03FormScreen> createState() => _AsesiAK03FormScreenState();
}

class _AsesiAK03FormScreenState extends State<AsesiAK03FormScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  AK03Data? _ak03Data;

  static const List<String> _defaultKomponenList = [
    'Saya mendapatkan penjelasan yang cukup memadai mengenai proses asesmen/uji kompetensi',
    'Asesor memberikan kesempatan untuk mendiskusikan/ menegosiasikan metoda, instrumen dan sumber asesmen serta jadwal asesmen',
    'Asesor berusaha menggali seluruh bukti pendukung yang sesuai dengan latar belakang pelatihan dan pengalaman yang saya miliki',
    'Saya mendapatkan jaminan kerahasiaan hasil asesmen serta penjelasan penanganan dokumen asesmen',
    'Saya sepenuhnya diberikan kesempatan untuk mendemonstrasikan kompetensi yang saya miliki selama asesmen',
    'Saya mendapatkan penjelasan yang memadai mengenai keputusan asesmen',
    'Asesor memberikan umpan balik yang mendukung setelah asesmen serta tindak lanjutnya',
    'Asesor menggunakan keterampilan komunikasi yang efektif selama asesmen',
    'Asesor bersama saya menandatangani semua dokumen hasil asesmen',
  ];

  late List<String> _hasilList;
  late List<TextEditingController> _catatanItemControllers;
  late TextEditingController _umpanBalikController;
  late TextEditingController _catatanController;

  @override
  void initState() {
    super.initState();
    _hasilList = List.filled(_defaultKomponenList.length, 'Ya');
    _catatanItemControllers = List.generate(
      _defaultKomponenList.length,
      (_) => TextEditingController(),
    );
    _umpanBalikController = TextEditingController();
    _catatanController = TextEditingController();

    _fetchAK03();
  }

  @override
  void dispose() {
    for (final ctrl in _catatanItemControllers) {
      ctrl.dispose();
    }
    _umpanBalikController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchAK03() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await AsesiService.getAK03(widget.jadwal.id);
      if (data != null) {
        setState(() {
          _ak03Data = data;
          _umpanBalikController.text = data.umpanBalik;
          _catatanController.text = data.catatan;

          if (data.items.isNotEmpty) {
            for (int i = 0; i < _defaultKomponenList.length; i++) {
              if (i < data.items.length) {
                final item = data.items[i];
                _hasilList[i] = (item.hasil == 'Tidak' || item.hasil == '0') ? 'Tidak' : 'Ya';
                _catatanItemControllers[i].text = item.catatanKomentar;
              }
            }
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat formulir FR-AK.03: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAK03() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    final List<Map<String, dynamic>> itemsPayload = [];
    for (int i = 0; i < _defaultKomponenList.length; i++) {
      itemsPayload.add({
        'no': i + 1,
        'komponen': _defaultKomponenList[i],
        'hasil': _hasilList[i],
        'catatan_komentar': _catatanItemControllers[i].text.trim(),
      });
    }

    try {
      final success = await AsesiService.saveAK03(
        widget.jadwal.id,
        items: itemsPayload,
        umpanBalik: _umpanBalikController.text.trim(),
        catatan: _catatanController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Formulir FR-AK.03 berhasil disimpan!'),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF27AE60),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _fetchAK03();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan formulir FR-AK.03. Silakan coba lagi.'),
              backgroundColor: Color(0xFFEB5757),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: const Color(0xFFEB5757),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool isSudahDiisi = _ak03Data?.isSudahDiisi ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'FR-AK.03 Umpan Balik',
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEB5757)),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _fetchAK03,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2F80ED),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── 1. Header Card Info Jadwal ──
                            _buildHeaderCard(isSudahDiisi),
                            const SizedBox(height: 12),

                            // ── 2. Information Banner ──
                            _buildInfoBanner(),
                            const SizedBox(height: 16),

                            // ── 3. List 9 Komponen Evaluasi ──
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F80ED),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Komponen Evaluasi & Umpan Balik',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            ...List.generate(_defaultKomponenList.length, (index) {
                              return _buildKomponenCard(index);
                            }),

                            const SizedBox(height: 12),

                            // ── 4. Umpan Balik Umum & Catatan Khusus ──
                            _buildFeedbackCard(),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading || _errorMessage.isNotEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAK03,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isSudahDiisi ? 'Perbarui Umpan Balik FR-AK.03' : 'Simpan Umpan Balik FR-AK.03',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(bool isSudahDiisi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.jadwal.skema,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSudahDiisi ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSudahDiisi ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSudahDiisi ? Icons.check_circle_rounded : Icons.pending_rounded,
                      size: 13,
                      color: isSudahDiisi ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSudahDiisi ? 'Telah Diisi' : 'Belum Diisi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSudahDiisi ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          _buildInfoItem(LucideIcons.calendar, 'Tanggal Asesmen', widget.jadwal.tanggalMulai.isNotEmpty ? widget.jadwal.tanggalMulai : '-'),
          const SizedBox(height: 6),
          _buildInfoItem(LucideIcons.map_pin, 'TUK (Tempat Uji)', widget.jadwal.tuk.isNotEmpty ? widget.jadwal.tuk : '-'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Formulir ini diisi oleh Peserta (Asesi) sebagai evaluasi dan umpan balik pelaksanaan proses asesmen sesuai standar BNSP FR-AK.03.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKomponenCard(int index) {
    final no = index + 1;
    final komponen = _defaultKomponenList[index];
    final selectedHasil = _hasilList[index];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number + Question
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$no',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  komponen,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Pilihan Ya / Tidak (Chips/Buttons)
          Row(
            children: [
              const Text(
                'Hasil :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              _buildChoiceButton(
                label: 'Ya',
                isSelected: selectedHasil == 'Ya',
                activeColor: const Color(0xFF27AE60),
                onTap: () {
                  setState(() {
                    _hasilList[index] = 'Ya';
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildChoiceButton(
                label: 'Tidak',
                isSelected: selectedHasil == 'Tidak',
                activeColor: const Color(0xFFEB5757),
                onTap: () {
                  setState(() {
                    _hasilList[index] = 'Tidak';
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Catatan / Komentar item
          TextField(
            controller: _catatanItemControllers[index],
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Tulis komentar/catatan khusus butir ini (opsional)...',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 14,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeColor : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Umpan Balik Umum',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tuliskan tanggapan umum Anda terkait seluruh proses asesmen yang telah dijalankan.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _umpanBalikController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Contoh: Proses asesmen berjalan dengan lancar, tertib, dan sesuai instruksi.',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Catatan Khusus (Opsional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Catatan khusus, usulan perbaikan, atau apresiasi kepada asesor/TUK.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _catatanController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Tuliskan catatan khusus bila ada...',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

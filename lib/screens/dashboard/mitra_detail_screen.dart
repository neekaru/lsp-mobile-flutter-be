import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../models/asesor_dashboard_models.dart';
import '../../services/marketing/places_service.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/mitra_external_url.dart';
import 'widgets/mitra_location_card.dart';

class AsesorMitraDetailScreen extends StatefulWidget {
  final AsesorMitra mitra;

  const AsesorMitraDetailScreen({super.key, required this.mitra});

  @override
  State<AsesorMitraDetailScreen> createState() => _AsesorMitraDetailScreenState();
}

class _AsesorMitraDetailScreenState extends State<AsesorMitraDetailScreen> {
  double? _resolvedLat;
  double? _resolvedLng;
  String? _resolvedAddress;
  bool _isResolvingLocation = false;

  @override
  void initState() {
    super.initState();
    _initCoordinates();
  }

  void _initCoordinates() {
    if (widget.mitra.hasCoordinates) {
      _resolvedLat = widget.mitra.latitude;
      _resolvedLng = widget.mitra.longitude;
    } else {
      _resolveLocationFromAddress();
    }
  }

  Future<void> _resolveLocationFromAddress() async {
    final query = [
      if (widget.mitra.namaTuk.isNotEmpty) widget.mitra.namaTuk,
      if (widget.mitra.alamat.isNotEmpty) widget.mitra.alamat,
      if (widget.mitra.kota.isNotEmpty) widget.mitra.kota,
    ].join(', ').trim();

    if (query.isEmpty) return;

    setState(() => _isResolvingLocation = true);

    try {
      final results = await PlacesService.searchPlaces(
        query: query,
        filterRetail: false,
      );

      if (results.isNotEmpty && mounted) {
        final p = results.first;
        if (p.latitude != 0.0 && p.longitude != 0.0) {
          setState(() {
            _resolvedLat = p.latitude;
            _resolvedLng = p.longitude;
            _resolvedAddress = p.formattedAddress;
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error resolving location for mitra: $e');
    } finally {
      if (mounted) {
        setState(() => _isResolvingLocation = false);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mitra = widget.mitra;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            CustomAppBar(
              title: 'Detail Mitra Kerjasama',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderProfileCard(mitra),
                    const SizedBox(height: 14),
                    _buildInfoLembagaCard(mitra),
                    const SizedBox(height: 14),
                    _buildDetailKerjasamaCard(mitra),
                    const SizedBox(height: 14),
                    _buildDokumenMouCard(mitra),
                    const SizedBox(height: 14),
                    MitraLocationCard(
                      mitra: mitra,
                      lat: _resolvedLat,
                      lng: _resolvedLng,
                      resolvedAddress: _resolvedAddress,
                      isResolving: _isResolvingLocation,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderProfileCard(AsesorMitra mitra) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (mitra.statusMitra) {
      case 1:
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFDCFCE7);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 2:
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
        statusIcon = Icons.history_rounded;
        break;
      case 0:
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.access_time_rounded;
        break;
    }

    final formattedTanggal = mitra.tanggalBermitra.isNotEmpty
        ? DateFormatHelper.formatToIndonesian(mitra.tanggalBermitra)
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mitra.namaTuk.isNotEmpty ? mitra.namaTuk : 'Mitra Kerjasama',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                mitra.statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (mitra.idTuk > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ID TUK: #${mitra.idTuk}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                'Terdaftar Bermitra: $formattedTanggal',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLembagaCard(AsesorMitra mitra) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.domain_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Informasi Lembaga & TUK',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailItem(
            label: 'Nama Tempat Uji (TUK)',
            value: mitra.namaTuk.isNotEmpty ? mitra.namaTuk : '-',
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Kota / Kabupaten',
            value: mitra.kota.isNotEmpty ? mitra.kota : '-',
            icon: Icons.location_city_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Alamat Lengkap',
            value: mitra.alamat.isNotEmpty ? mitra.alamat : '-',
            icon: Icons.place_rounded,
            onCopy: mitra.alamat.isNotEmpty
                ? () => _copyToClipboard(mitra.alamat, 'Alamat')
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailKerjasamaCard(AsesorMitra mitra) {
    final formattedTanggal = mitra.tanggalBermitra.isNotEmpty
        ? DateFormatHelper.formatToIndonesian(mitra.tanggalBermitra)
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Detail Kerjasama & Proyeksi',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailItem(
            label: 'Tanggal Mulai Kerjasama',
            value: formattedTanggal,
            icon: Icons.event_available_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Status Kemitraan',
            value: mitra.statusLabel,
            icon: Icons.verified_user_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Deskripsi Kemitraan',
            value: mitra.deskripsiMitra.isNotEmpty ? mitra.deskripsiMitra : '-',
            icon: Icons.notes_rounded,
          ),
          const SizedBox(height: 10),
          _buildDetailItem(
            label: 'Proyeksi & Potensi Asesi',
            value: mitra.proyeksiMitra.isNotEmpty ? mitra.proyeksiMitra : '-',
            icon: Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenMouCard(AsesorMitra mitra) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.description_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Dokumen Perjanjian (MoU)',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          if (mitra.hasMou) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nota Kesepahaman (MoU) Resmi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dokumen perjanjian kemitraan TUK & Asesor',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => openMitraExternalUrl(mitra.linkMouMitra),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text(
                  'Buka Dokumen MoU',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tautan dokumen MoU belum diunggah untuk kemitraan ini.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
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

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF475569)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
            onPressed: onCopy,
            tooltip: 'Salin',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
      ],
    );
  }
}

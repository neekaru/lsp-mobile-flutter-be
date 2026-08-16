import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/blanko_models.dart';
import '../../services/admin/blanko_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/blanko_detail_header.dart';
import 'widgets/blanko_detail_metrics.dart';
import 'widgets/blanko_detail_section.dart';
import 'widgets/blanko_jadwal_id_chips.dart';

class DetailPengajuanBlankoScreen extends StatefulWidget {
  final int blankoId;
  final BlankoListItem? initialData;

  const DetailPengajuanBlankoScreen({
    super.key,
    required this.blankoId,
    this.initialData,
  });

  @override
  State<DetailPengajuanBlankoScreen> createState() =>
      _DetailPengajuanBlankoScreenState();
}

class _DetailPengajuanBlankoScreenState
    extends State<DetailPengajuanBlankoScreen> {
  bool _isLoading = true;
  BlankoDetailModel? _detail;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final res = await BlankoService.getBlankoDetail(widget.blankoId);
    if (!mounted) return;
    setState(() {
      _detail = res;
      _isLoading = false;
    });
  }

  Future<void> _openBastLink(String urlStr) async {
    if (urlStr.trim().isEmpty) return;
    try {
      String formattedUrl = urlStr.trim();
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final uri = Uri.parse(formattedUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka link: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final init = widget.initialData;
    final nomorPermohonan = _detail?.nomorPermohonan ??
        init?.nomorPermohonan ??
        'Permohonan #${widget.blankoId}';
    final nomorKeputusan =
        _detail?.nomorKeputusan ?? init?.nomorKeputusan ?? '-';
    final statusTerkirim =
        _detail?.statusTerkirim ?? init?.statusTerkirim ?? 'Belum Terkirim';
    final isSudahTerkirim = _detail?.isSudahTerkirim ??
        init?.isSudahTerkirim ??
        false;
    final isValidasi = (_detail?.isValidasi ?? init?.isValidasi ?? 0) == 1;

    final jumlahKompeten = _detail?.jumlahKompeten ?? init?.jumlahKompeten ?? 0;
    final blankoTerkirim = _detail?.blankoTerkirim ?? init?.blankoTerkirim ?? 0;
    final blankoAwal = _detail?.noBlankoAwal ?? init?.noBlankoAwal ?? '0';
    final blankoAkhir = _detail?.noBlankoAkhir ?? init?.noBlankoAkhir ?? '0';
    final rangeText = (blankoAwal == '0' && blankoAkhir == '0')
        ? '-'
        : '$blankoAwal - $blankoAkhir';
    final blankoDiterimaStatus = _detail != null
        ? (_detail!.blankoDiterima == '1' ? 'Sudah' : 'Belum')
        : (init?.blankoDiterima == '1' ? 'Sudah' : 'Belum');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Detail Pengajuan Blanko',
              onBack: () => Navigator.pop(context),
              rightWidget: IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF0F172A),
                  size: 20,
                ),
                onPressed: _fetchDetail,
              ),
            ),
            if (_isLoading && _detail == null)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchDetail,
                color: const Color(0xFF378CE7),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header Card
                      BlankoDetailHeader(
                        nomorPermohonan: nomorPermohonan,
                        nomorKeputusan: nomorKeputusan,
                        isSudahTerkirim: isSudahTerkirim,
                        statusTerkirim: statusTerkirim,
                        isValidasi: isValidasi,
                      ),
                      const SizedBox(height: 12),

                      // 2. Metrics 2x2 Grid
                      BlankoDetailMetrics(
                        jumlahKompeten: jumlahKompeten,
                        blankoTerkirim: blankoTerkirim,
                        blankoDiterimaStatus: blankoDiterimaStatus,
                        rangeText: rangeText,
                      ),
                      const SizedBox(height: 12),

                      // 3. Section Informasi Permohonan
                      BlankoDetailSection(
                        title: 'Informasi Permohonan',
                        icon: Icons.assignment_outlined,
                        items: [
                          BlankoInfoItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'Tanggal Permohonan',
                            value: _detail?.tanggalPermohonan.isNotEmpty == true
                                ? _detail!.tanggalPermohonan
                                : (init?.tanggalPermohonan ?? '-'),
                          ),
                          BlankoInfoItem(
                            icon: Icons.person_outline_rounded,
                            label: 'PIC Pengajuan',
                            value: _detail?.picPengajuan.isNotEmpty == true
                                ? _detail!.picPengajuan
                                : (init?.picPengajuan ?? '-'),
                          ),
                          BlankoInfoItem(
                            icon: Icons.event_note_outlined,
                            label: 'Jadwal ID',
                            value: '',
                            valueWidget: BlankoJadwalIdChips(
                              jadwalIds: _detail?.jadwalIds ?? const [],
                            ),
                          ),
                          BlankoInfoItem(
                            icon: Icons.date_range_outlined,
                            label: 'Range Tanggal Asesmen',
                            value: _detail?.rangeTanggalAsesmen.isNotEmpty ==
                                    true
                                ? _detail!.rangeTanggalAsesmen
                                : '-',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 4. Section Keputusan & Pleno
                      BlankoDetailSection(
                        title: 'Keputusan & Tim Pleno',
                        icon: Icons.gavel_outlined,
                        items: [
                          BlankoInfoItem(
                            icon: Icons.verified_outlined,
                            label: 'Nomor Keputusan',
                            value: _detail?.nomorKeputusan.isNotEmpty == true
                                ? _detail!.nomorKeputusan
                                : (init?.nomorKeputusan ?? '-'),
                          ),
                          BlankoInfoItem(
                            icon: Icons.calendar_month_outlined,
                            label: 'Tanggal Keputusan',
                            value: _detail?.tanggalKeputusan.isNotEmpty == true
                                ? _detail!.tanggalKeputusan
                                : '-',
                          ),
                          BlankoInfoItem(
                            icon: Icons.article_outlined,
                            label: 'SK Tim Pleno',
                            value: _detail?.skTimPleno.isNotEmpty == true
                                ? _detail!.skTimPleno
                                : '-',
                          ),
                          BlankoInfoItem(
                            icon: Icons.groups_outlined,
                            label: 'Tim Pleno',
                            value: _detail?.timPleno.isNotEmpty == true
                                ? _detail!.timPleno
                                : '-',
                          ),
                          BlankoInfoItem(
                            icon: Icons.person_pin_outlined,
                            label: 'Ketua Tim Pleno',
                            value: _detail?.ketuaTimPleno.isNotEmpty == true
                                ? _detail!.ketuaTimPleno
                                : '-',
                          ),
                          BlankoInfoItem(
                            icon: Icons.event_available_outlined,
                            label: 'Tanggal Pleno',
                            value: _detail?.tanggalPleno.isNotEmpty == true
                                ? _detail!.tanggalPleno
                                : '-',
                          ),
                          BlankoInfoItem(
                            icon: Icons.description_outlined,
                            label: 'No. Berita Acara',
                            value: _detail?.noBeritaAcara.isNotEmpty == true
                                ? _detail!.noBeritaAcara
                                : '-',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 5. Section Rincian Blanko & Penerimaan
                      BlankoDetailSection(
                        title: 'Rincian Blanko',
                        icon: Icons.inventory_2_outlined,
                        items: [
                          BlankoInfoItem(
                            icon: Icons.format_list_numbered_rounded,
                            label: 'No. Blanko Awal',
                            value: _detail?.noBlankoAwal.isNotEmpty == true
                                ? _detail!.noBlankoAwal
                                : (init?.noBlankoAwal ?? '0'),
                          ),
                          BlankoInfoItem(
                            icon: Icons.format_list_numbered_rounded,
                            label: 'No. Blanko Akhir',
                            value: _detail?.noBlankoAkhir.isNotEmpty == true
                                ? _detail!.noBlankoAkhir
                                : (init?.noBlankoAkhir ?? '0'),
                          ),
                          BlankoInfoItem(
                            icon: Icons.mark_email_read_outlined,
                            label: 'Blanko Diterima',
                            value: _detail != null
                                ? (_detail!.blankoDiterima == '1'
                                    ? 'Sudah Diterima'
                                    : 'Belum Diterima')
                                : (init?.blankoDiterima == '1'
                                    ? 'Sudah Diterima'
                                    : 'Belum Diterima'),
                          ),
                          BlankoInfoItem(
                            icon: Icons.event_outlined,
                            label: 'Tanggal Diterima',
                            value: _detail?.tanggalDiterima ??
                                init?.tanggalDiterima ??
                                '-',
                          ),
                          BlankoInfoItem(
                            icon: Icons.fact_check_outlined,
                            label: 'Validasi',
                            value: isValidasi
                                ? 'Tervalidasi'
                                : 'Belum Validasi',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 6. Action Button BAST (if link available)
                      if (_detail?.linkBast != null &&
                          _detail!.linkBast.trim().isNotEmpty) ...[
                        GestureDetector(
                          onTap: () => _openBastLink(_detail!.linkBast),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.open_in_browser_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Buka Berita Acara Serah Terima (BAST)',
                                  style: TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

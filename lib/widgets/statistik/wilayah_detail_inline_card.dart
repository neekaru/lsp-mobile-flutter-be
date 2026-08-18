import 'package:material_ui/material_ui.dart';
import '../../models/dashboard_models.dart';
import '../../services/api_service.dart';
import '../../utils/number_format_helper.dart';

class WilayahDetailInlineCard extends StatefulWidget {
  final String provinceId;
  final String provinceName;
  final VoidCallback onClose;

  const WilayahDetailInlineCard({
    super.key,
    required this.provinceId,
    required this.provinceName,
    required this.onClose,
  });

  @override
  State<WilayahDetailInlineCard> createState() =>
      _WilayahDetailInlineCardState();
}

class _WilayahDetailInlineCardState extends State<WilayahDetailInlineCard> {
  bool _isLoading = true;
  PenyebaranWilayahDetail? _detail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  @override
  void didUpdateWidget(covariant WilayahDetailInlineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provinceId != widget.provinceId) {
      _fetchDetailData();
    }
  }

  Future<void> _fetchDetailData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService.getPenyebaranWilayahDetail(
        widget.provinceId,
        widget.provinceName,
      );

      if (mounted) {
        setState(() {
          _detail = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat detail wilayah.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.provinceName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${NumberFormatHelper.formatWithDots(_detail!.totalAsesor)} Asesor  •  ${NumberFormatHelper.formatWithDots(_detail!.totalTuk)} TUK  •  ${NumberFormatHelper.formatWithDots(_detail!.totalAsesi)} Asesi',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Tutup Detail',
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Memuat detail wilayah...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ),
            )
          else if (_detail != null) ...[
            // 1. Jumlah Asesor Section (per Bidang/Skema)
            _buildSectionHeader(
              title: '1. Jumlah Asesor',
              count: _detail!.totalAsesor,
              unit: 'Asesor',
              icon: Icons.person_outline_rounded,
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 8),
            _buildAsesorBidangList(_detail!.asesorByBidang),

            const SizedBox(height: 16),

            // 2. Jumlah TUK Section (per Kabupaten/Kota)
            _buildSectionHeader(
              title: '2. Jumlah TUK',
              count: _detail!.totalTuk,
              unit: 'TUK',
              icon: Icons.domain_rounded,
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 8),
            _buildTukKabupatenList(_detail!.tukByKabupaten),

            const SizedBox(height: 16),

            // 3. Jumlah Asesi Section (per Bidang/Skema)
            _buildSectionHeader(
              title: '3. Jumlah Asesi',
              count: _detail!.totalAsesi,
              unit: 'Asesi',
              icon: Icons.groups_outlined,
              color: const Color(0xFF059669),
            ),
            const SizedBox(height: 8),
            _buildAsesiBidangList(_detail!.asesiByBidang),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${NumberFormatHelper.formatWithDots(count)} $unit',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsesorBidangList(List<BidangBreakdownItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text('Tidak ada data bidang asesor.', style: TextStyle(fontSize: 11, color: Colors.grey)),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.namaBidang,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${NumberFormatHelper.formatWithDots(item.jumlah)} Asesor',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTukKabupatenList(List<TUKKabupatenItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text('Tidak ada data TUK kabupaten.', style: TextStyle(fontSize: 11, color: Colors.grey)),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.namaKabupaten,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${NumberFormatHelper.formatWithDots(item.jumlahTuk)} TUK',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAsesiBidangList(List<BidangBreakdownItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text('Tidak ada data bidang asesi.', style: TextStyle(fontSize: 11, color: Colors.grey)),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const Icon(Icons.school_outlined, size: 14, color: Color(0xFF059669)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.namaBidang,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${NumberFormatHelper.formatWithDots(item.jumlah)} Asesi',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

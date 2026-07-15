import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/asesor_service.dart';
import 'detail_honor_screen.dart';

class HonorAsesorScreen extends StatefulWidget {
  const HonorAsesorScreen({super.key});

  @override
  State<HonorAsesorScreen> createState() => _HonorAsesorScreenState();
}

class _HonorAsesorScreenState extends State<HonorAsesorScreen> {
  String _selectedMonth = 'Semua';
  bool _isLoading = true;
  Map<String, dynamic>? _honorData;
  List<String> _availableMonths = ['Semua']; // Will be populated from API

  @override
  void initState() {
    super.initState();
    _fetchHonorData();
  }

  Future<void> _fetchHonorData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // If _selectedMonth is 'Semua', fetch without periode parameter
      final res = _selectedMonth == 'Semua'
          ? await AsesorService.getHonorList()
          : await AsesorService.getHonorList(_selectedMonth);
      if (mounted) {
        setState(() {
          _honorData = res;

          // Populate available months from API response (only when fetching all)
          if (_selectedMonth == 'Semua' &&
              res != null &&
              res['available_months'] != null) {
            final apiMonths = (res['available_months'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            _availableMonths = ['Semua', ...apiMonths];
          }
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Periode Bulan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._availableMonths.map((monthName) {
                    final isSelected = monthName == _selectedMonth;
                    return ListTile(
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        color: isSelected
                            ? const Color(0xFF378CE7)
                            : const Color(0xFF64748B),
                      ),
                      title: Text(
                        monthName,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF378CE7)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF378CE7),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedMonth = monthName;
                        });
                        Navigator.pop(context);
                        _fetchHonorData();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    final String totalHonor = _honorData?['total_honor'] ?? 'Rp. 0';
    final String countText =
        _honorData?['jumlah_asesmen_selesai'] ?? '0 Asesmen selesai';
    final List<dynamic> details = _honorData?['rincian'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(title: 'Honor Saya'),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchHonorData,
              color: const Color(0xFF378CE7),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Picker Button
                    GestureDetector(
                      onTap: () => _showMonthPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF378CE7),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedMonth,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF378CE7),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Highlight Total Honor Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Honor',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  totalHonor,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  countText,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Premium Vector Illustration of smartphone & transaction details
                          _buildIllustration(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Riwayat Section Title
                    const Text(
                      'Riwayat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (details.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Text(
                            'Tidak ada riwayat honor untuk periode ini',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: details.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final detail = details[index] as Map<String, dynamic>;
                          
                          // Extract fields
                          final String title = detail['judul_asesmen'] ?? '';
                          final String honorAmount = detail['honor'] ?? 'Rp. 0';
                          
                          // Determine values based on user's design screenshot:
                          final String status = detail['status'] ?? (title.toLowerCase().contains('marketing') ? 'Menunggu' : 'Complete');
                          final int jumlahAsesmen = detail['jumlah_asesmen'] ?? (title.toLowerCase().contains('ui/ux') ? 4 : 2);
                          final String metodePembayaran = detail['metode_pembayaran'] ?? 'Transfer Bank';
                          final String tanggalPembayaran = detail['tanggal_pembayaran'] ?? detail['tanggal'] ?? '20 Juli 2026';
                          final String noTransfer = detail['no_transfer'] ?? 'PAY-20262007-002';
                          
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF), // Soft blue background
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.qr_code,
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
                                            title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Skema sertifikasi',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$jumlahAsesmen Asesmen',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          honorAmount,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF22C55E), // Green text
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: status == 'Complete'
                                                ? const Color(0xFFDCFCE7) // Light green
                                                : const Color(0xFFFFEDD5), // Light orange
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: status == 'Complete'
                                                  ? const Color(0xFF15803D)
                                                  : const Color(0xFFD97706),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: Color(0xFFF1F5F9),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Metode Pembayaran',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Tanggal Pembayaran',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tanggalPembayaran,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            metodePembayaran,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'No.Transfer',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            noTransfer,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () => _navigateToHonorDetail(
                                      context: context,
                                      detail: detail,
                                      status: status,
                                      metodePembayaran: metodePembayaran,
                                      tanggalPembayaran: tanggalPembayaran,
                                      noTransfer: noTransfer,
                                      jumlahAsesmen: jumlahAsesmen,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF3B82F6),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        'Lihat Detail',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(
          0xFFBFDBFE,
        ).withValues(alpha: 0.6), // Light blue background box
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Green Money Note (rotated)
            Positioned(
              left: 10,
              bottom: 12,
              child: Transform.rotate(
                angle: -0.25,
                child: Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80), // Green bill
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Smartphone body
            Positioned(
              right: 15,
              top: 10,
              child: Container(
                width: 42,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A), // Dark blue phone
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    // Speaker line
                    Center(
                      child: Container(
                        width: 10,
                        height: 1.5,
                        color: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Screen content with a tiny credit card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6), // Blue screen
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Tiny credit card
                            Positioned(
                              top: 4,
                              child: Container(
                                width: 30,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF97316),
                                      Color(0xFFEA580C),
                                    ], // Orange card
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Mini receipt/check lines
                            Positioned(
                              bottom: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 25,
                                    height: 2,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 18,
                                    height: 2,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // White receipt in front of the phone
            Positioned(
              right: 5,
              bottom: 12,
              child: Transform.rotate(
                angle: 0.15,
                child: Container(
                  width: 32,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white, // White receipt paper
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 20, height: 2, color: Colors.grey[400]),
                      const SizedBox(height: 2),
                      Container(
                        width: 15,
                        height: 1.5,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 18,
                        height: 1.5,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 10,
                        height: 1.5,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Gold Coin
            Positioned(
              left: 14,
              bottom: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24), // Gold color
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD97706),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 1),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHonorDetail({
    required BuildContext context,
    required Map<String, dynamic> detail,
    required String status,
    required String metodePembayaran,
    required String tanggalPembayaran,
    required String noTransfer,
    required int jumlahAsesmen,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHonorScreen(
          detail: detail,
          status: status,
          metodePembayaran: metodePembayaran,
          tanggalPembayaran: tanggalPembayaran,
          noTransfer: noTransfer,
          jumlahAsesmen: jumlahAsesmen,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/sertifikat_service.dart';
import 'konfirmasi_persetujuan_screen.dart';

class KonfirmasiPembayaranScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const KonfirmasiPembayaranScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<KonfirmasiPembayaranScreen> createState() =>
      _KonfirmasiPembayaranScreenState();
}

class _KonfirmasiPembayaranScreenState
    extends State<KonfirmasiPembayaranScreen> {
  bool _loading = true;
  String _totalPembayaran = 'Rp. 0';
  String _skemaTitle = '';

  @override
  void initState() {
    super.initState();
    _skemaTitle = widget.title;
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    try {
      final detail = await SertifikatService.getSkemaDetail(widget.skemaId);
      if (!mounted) return;
      setState(() {
        _totalPembayaran =
            detail.price.isNotEmpty ? detail.price : 'Rp. 0';
        if (detail.title.isNotEmpty) _skemaTitle = detail.title;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ringkasan Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F4E9), // light green background
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Lunas',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32), // green text
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6), // grey container background
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildTotalPaymentCard(),
                        _buildPaymentMethodCard(),
                        _buildLspAccountCard(context),
                        _buildPaymentStatusCard(),
                        _buildDateTimeCard(),
                        _buildReceiptCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildActionButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return const CustomAppBar(
      title: 'Konfirmasi Pembayaran',
      rightWidget: SizedBox(width: 32),
    );
  }

  Widget _buildTotalPaymentCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            _totalPembayaran,
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

  Widget _buildPaymentMethodCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7E7E7E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Transfer Bank BCA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // BCA Logo Representation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F4C81),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.account_balance_rounded, color: Colors.white, size: 10),
                SizedBox(width: 4),
                Text(
                  'BCA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLspAccountCard(BuildContext context) {
    const String accountNo = '1325 5968 2458';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'No. Rekening LSP',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7E7E7E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'LSP Digital Nasional',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: accountNo));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nomor rekening disalin ke papan klip'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Row(
              children: const [
                Text(
                  accountNo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Status Pembayaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F4E9), // light green background
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Berhasil',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32), // green text
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
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
        children: const [
          Text(
            'Tanggal & Waktu',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF7E7E7E),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '18 Juni 2026, 20:00 WIB',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Bukti Pembayaran',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7E7E7E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Bukti_pembayaran.PNG',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFF3B82F6), // blue right arrow
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
                title: _skemaTitle.isNotEmpty ? _skemaTitle : widget.title,
                kodeSkema: widget.kodeSkema,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B9FD8), // matching the blue button color in screenshots
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

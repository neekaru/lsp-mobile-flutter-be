import 'package:flutter/material.dart';
import 'tes_tertulis_screen.dart';

class KonfirmasiPersetujuanScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const KonfirmasiPersetujuanScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<KonfirmasiPersetujuanScreen> createState() => _KonfirmasiPersetujuanScreenState();
}

class _KonfirmasiPersetujuanScreenState extends State<KonfirmasiPersetujuanScreen> {
  bool _isApproved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Syarat & Ketentuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTermsBox(),
                  const SizedBox(height: 16),
                  _buildCheckboxRow(),
                  const SizedBox(height: 48),
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
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFEAEAEA), // light grey header background
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF3B82F6), // blue bottom line
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black87,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.black87,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Konfirmasi Persetujuan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsBox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '1. Saya menyatakan bahwa data yang saya berikan adalah benar dan dapat dipertanggung jawabkan.',
            style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black),
          ),
          SizedBox(height: 12),
          Text(
            '2. Saya telah membaca dan memahami skema sertifikat yang telah dipilih.',
            style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black),
          ),
          SizedBox(height: 12),
          Text(
            '3. Saya bersedia mengikuti seluruh Proses asesmen yang berlaku sesuai dengan ketentuan yang ada.',
            style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black),
          ),
          SizedBox(height: 12),
          Text(
            '4. Saya memahami bila biaya yang sudah saya keluarkan tidak dapat dikembalikan apapbila saya mengundurkan diri di tengah prosess.',
            style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isApproved,
            activeColor: const Color(0xFF3B82F6),
            onChanged: (val) {
              setState(() {
                _isApproved = val ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Saya setuju dengan syarat dan ketentuan diatas',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isApproved ? () => _showSuccessDialog(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B9FD8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
        ),
        child: const Text(
          'Konfirmasi Pendaftaran',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header Row with Back Arrow
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Success Badge Graphic (Double circles with checkmark and decorative dots)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2F4E9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    // Decorative floating dots to match screenshot bubbles
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
                    ),
                    Positioned(
                      top: 30,
                      left: 0,
                      child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
                    ),
                    Positioned(
                      bottom: 25,
                      left: 5,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 10,
                      child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFC2EAD0), shape: BoxShape.circle)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Casing matching screenshot: "konfirmasi Pendaftaran Berhasil"
                const Text(
                  'konfirmasi Pendaftaran Berhasil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Casing and content matching screenshot exactly
                const Text(
                  'Pendaftaran Anda dalam skema sertifikasi pemasaran digital berhasil dikonfirmasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Buttons: Batal & Ok
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Dismiss dialog
                            // Navigate to test screen
                            Navigator.push(
                              parentContext,
                              MaterialPageRoute(
                                builder: (context) => TesTertulisScreen(
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
                            'Ok',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

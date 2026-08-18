import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/pengajuan/animated_status_badges.dart';
import 'asesor_recommendation_screen.dart';

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
  State<KonfirmasiPersetujuanScreen> createState() =>
      _KonfirmasiPersetujuanScreenState();
}

class _KonfirmasiPersetujuanScreenState
    extends State<KonfirmasiPersetujuanScreen> {
  bool _isApproved = false;

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
    return const CustomAppBar(
      title: 'Konfirmasi Persetujuan',
      rightWidget: SizedBox(width: 32),
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
            style: TextStyle(fontSize: 13, color: Colors.black87),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
        ),
        child: const Text(
          'Konfirmasi Pendaftaran',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext parentContext) {
    showGeneralDialog(
      context: parentContext,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedSuccessBadge(),
                const SizedBox(height: 24),

                // Casing matching screenshot: "Konfirmasi Pendaftaran Berhasil"
                const Text(
                  'Konfirmasi Pendaftaran Berhasil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Casing and content matching screenshot exactly
                Text(
                  'Pendaftaran Anda dalam skema sertifikasi ${widget.title} berhasil dikonfirmasi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                            // Navigate to asesor recommendation screen
                            Navigator.push(
                              parentContext,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AsesorRecommendationScreen(
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
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(scale: curve, child: child);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'pra_asesmen_wizard_screen.dart';

class PraAsesmenScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const PraAsesmenScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<PraAsesmenScreen> createState() => _PraAsesmenScreenState();
}

class _PraAsesmenScreenState extends State<PraAsesmenScreen> {
  void _startWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PraAsesmenWizardScreen(
          skemaId: widget.skemaId,
          title: widget.title,
          kodeSkema: widget.kodeSkema,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarningBanner(),
                  const SizedBox(height: 24),
                  _buildMenuCard(
                    stepNum: "1",
                    title: "Informasi Skema",
                    subtitle: "Informasi detail skema yang telah Anda pilih",
                    badgeColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    icon: Icons.workspace_premium_rounded,
                    onTap: _startWizard,
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    stepNum: "2",
                    title: "Evaluasi Diri",
                    subtitle: "Nilai diri Anda dalam setiap kompetensi",
                    badgeColor: const Color(0xFFDCFCE7),
                    iconColor: const Color(0xFF16A34A),
                    icon: Icons.assignment_turned_in_rounded,
                    onTap: _startWizard,
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    stepNum: "3",
                    title: "Pernyataan Kesiapan",
                    subtitle: "Pernyataan dan Komitmen untuk mengikuti asessmen",
                    badgeColor: const Color(0xFFDBEAFE),
                    iconColor: const Color(0xFF2563EB),
                    icon: Icons.gpp_good_rounded,
                    onTap: _startWizard,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Text(
            'Pra-Asessment',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const Icon(
            Icons.more_horiz_rounded,
            color: Colors.black,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withValues(alpha: 0.5),
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Sebelum memulai asessmen, isi pra asessmen terlebih dahulu untuk Mengevaluasi kesiapan Anda',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String stepNum,
    required String title,
    required String subtitle,
    required Color badgeColor,
    required Color iconColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$stepNum. $title',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _startWizard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9FD8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Mulai Pra Asessmen',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

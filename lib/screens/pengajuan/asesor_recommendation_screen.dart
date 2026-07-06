import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import '../../services/sertifikat_service.dart';
import 'pra_asesmen_screen.dart';
import '../jadwal/profil_asesor_screen.dart';

class AsesorRecommendationScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const AsesorRecommendationScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<AsesorRecommendationScreen> createState() => _AsesorRecommendationScreenState();
}

class _AsesorRecommendationScreenState extends State<AsesorRecommendationScreen> {
  List<AsesorDetailItem> _asesorList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAsesors();
  }

  Future<void> _loadAsesors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await SertifikatService.getAsesorBySkema(widget.skemaId);
      setState(() {
        _asesorList = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading assessors: $e');
      setState(() {
        _isLoading = false;
      });
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
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5B9FD8),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBlueBanner(),
                        const SizedBox(height: 20),
                        _buildAsesorList(),
                        const SizedBox(height: 20),
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
    return CustomAppBar(
      title: 'Asessor',
      rightWidget: IconButton(
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: Colors.black,
        ),
        onPressed: () {},
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildBlueBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE), // Light blue background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFBAE6FD), // Border matching blue
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Asessor yang Disarankan :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0369A1), // Dark blue text
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem('Kompeten di skema terkait'),
          const SizedBox(height: 8),
          _buildCheckItem('Berpengalaman'),
          const SizedBox(height: 8),
          _buildCheckItem('Rating dan Pengalam'),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_rounded,
          color: Color(0xFF10B981), // Green check icon
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0369A1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsesorList() {
    if (_asesorList.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada asesor rekomendasi untuk skema ini.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _asesorList.length,
      itemBuilder: (context, index) {
        final asesor = _asesorList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.0,
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilAsesorScreen(
                    name: asesor.namaAsesor,
                    skema: widget.title,
                    lokasi: asesor.kabupatenKota,
                    asesorDetail: asesor,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF94A3B8),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asesor.namaAsesor,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              asesor.kabupatenKota,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PraAsesmenScreen(
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
              'Selanjutnya',
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

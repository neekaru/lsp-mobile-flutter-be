import 'package:material_ui/material_ui.dart';
import '../../widgets/pengajuan/asesor_list_item.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import '../../services/sertifikat/sertifikat_service.dart';
import 'pra_asesmen_screen.dart';

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
  State<AsesorRecommendationScreen> createState() =>
      _AsesorRecommendationScreenState();
}

class _AsesorRecommendationScreenState
    extends State<AsesorRecommendationScreen> {
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
                    child: CircularProgressIndicator(color: Color(0xFF5B9FD8)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20.0,
                          12.0,
                          20.0,
                          0.0,
                        ),
                        child: _buildBlueBanner(),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _buildAsesorList()),
                    ],
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
        icon: const Icon(Icons.more_horiz_rounded, color: Colors.black),
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
          _buildCheckItem('Rating dan Pengalaman'),
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
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Tidak ada asesor rekomendasi untuk skema ini.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
      physics: const BouncingScrollPhysics(),
      itemCount: _asesorList.length,
      // Skip keepAlive overhead — items are lightweight and cheap to rebuild
      addAutomaticKeepAlives: false,
      // ignore: deprecated_member_use
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final asesor = _asesorList[index];
        return AsesorListItem(
          key: ValueKey(asesor.idAsesor),
          asesor: asesor,
          skemaTitle: widget.title,
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Extracted list item widget — gives Flutter its own Element in the tree,
// enabling efficient diffing and skipping rebuilds for unchanged items.
// All decorations/styles are static const to eliminate per-frame allocations.
// =============================================================================

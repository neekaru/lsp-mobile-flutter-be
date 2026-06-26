// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

// Overlay widget specifically for the filter options popup
class FilterMenuOverlay extends StatefulWidget {
  final String initialKategori;
  final String? initialJenjang;
  final String? initialBidang;
  final Function(String kategori, String? jenjang, String? bidang) onApply;

  const FilterMenuOverlay({
    super.key,
    required this.initialKategori,
    required this.initialJenjang,
    required this.initialBidang,
    required this.onApply,
  });

  @override
  State<FilterMenuOverlay> createState() => _FilterMenuOverlayState();
}

class _FilterMenuOverlayState extends State<FilterMenuOverlay> {
  late String _tempKategori;
  late String? _tempJenjang;
  late String? _tempBidang;

  @override
  void initState() {
    super.initState();
    _tempKategori = widget.initialKategori;
    _tempJenjang = widget.initialJenjang;
    _tempBidang = widget.initialBidang;
  }

  Widget _buildRadioItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4A9EDF),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A9EDF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double cardWidth = 230.0;
    const double rightMargin = 16.0;
    
    // The grey backdrop width (covers the card + some padding to the left of the card)
    final double backdropWidth = cardWidth + rightMargin + 16; // 262.0

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Grey backdrop covering ONLY the right side of the screen
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: backdropWidth,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),

          // 2. Transparent backdrop covering the rest of the area on the left to dismiss on tap
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: screenWidth - backdropWidth,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // 3. White filter card (on the right side)
          Positioned(
            top: statusBarHeight + 68, // Shifted down for padding
            right: rightMargin,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside the card from dismissing
              child: Container(
                width: cardWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3D000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // kategori Skema
                      const Text(
                        'kategori Skema',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRadioItem(
                        title: 'Semua Skema',
                        isSelected: _tempKategori == 'Semua Skema',
                        onTap: () {
                          setState(() => _tempKategori = 'Semua Skema');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Skema AJJ',
                        isSelected: _tempKategori == 'Skema AJJ',
                        onTap: () {
                          setState(() => _tempKategori = 'Skema AJJ');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Skema Nirkertas(Paperless)',
                        isSelected: _tempKategori == 'Skema Nirkertas(Paperless)',
                        onTap: () {
                          setState(() => _tempKategori = 'Skema Nirkertas(Paperless)');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Skema Populer',
                        isSelected: _tempKategori == 'Skema Populer',
                        onTap: () {
                          setState(() => _tempKategori = 'Skema Populer');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Skema Terbaru',
                        isSelected: _tempKategori == 'Skema Terbaru',
                        onTap: () {
                          setState(() => _tempKategori = 'Skema Terbaru');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),

                      const Divider(height: 20, thickness: 0.5, color: Color(0xFFCBD5E1)),

                      // Jenjang
                      const Text(
                        'Jenjang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRadioItem(
                        title: 'Semua Jenjang',
                        isSelected: _tempJenjang == null,
                        onTap: () {
                          setState(() => _tempJenjang = null);
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Okupasi',
                        isSelected: _tempJenjang == 'Okupasi',
                        onTap: () {
                          setState(() => _tempJenjang = 'Okupasi');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'KKNI',
                        isSelected: _tempJenjang == 'KKNI',
                        onTap: () {
                          setState(() => _tempJenjang = 'KKNI');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Klaster',
                        isSelected: _tempJenjang == 'Klaster',
                        onTap: () {
                          setState(() => _tempJenjang = 'Klaster');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),

                      const Divider(height: 20, thickness: 0.5, color: Color(0xFFCBD5E1)),

                      // Bidang
                      const Text(
                        'Bidang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRadioItem(
                        title: 'Semua Bidang',
                        isSelected: _tempBidang == null,
                        onTap: () {
                          setState(() => _tempBidang = null);
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Digital Marketing & Office',
                        isSelected: _tempBidang == 'Digital Marketing & Office',
                        onTap: () {
                          setState(() => _tempBidang = 'Digital Marketing & Office');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Data Science',
                        isSelected: _tempBidang == 'Data Science',
                        onTap: () {
                          setState(() => _tempBidang = 'Data Science');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Software Development',
                        isSelected: _tempBidang == 'Software Development',
                        onTap: () {
                          setState(() => _tempBidang = 'Software Development');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Multimedia',
                        isSelected: _tempBidang == 'Multimedia',
                        onTap: () {
                          setState(() => _tempBidang = 'Multimedia');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                      _buildRadioItem(
                        title: 'Graphic Design',
                        isSelected: _tempBidang == 'Graphic Design',
                        onTap: () {
                          setState(() => _tempBidang = 'Graphic Design');
                          widget.onApply(_tempKategori, _tempJenjang, _tempBidang);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. "Filter by" and three-dots header row above the card (on the right side)
          Positioned(
            top: statusBarHeight + 16,
            right: rightMargin,
            width: cardWidth, // Row width spans exactly the card width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.black,
                      size: 24,
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
}

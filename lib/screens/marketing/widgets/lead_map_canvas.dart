import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';

class LeadMapCanvas extends StatelessWidget {
  final List<PlaceResult> places;
  final PlaceResult? selectedPlace;
  final Function(PlaceResult place) onSelectPlace;
  final VoidCallback onSearchArea;
  final bool isLoading;

  const LeadMapCanvas({
    super.key,
    required this.places,
    this.selectedPlace,
    required this.onSelectPlace,
    required this.onSearchArea,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Canvas / Background Tile Mockup (Visual Styled Map)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0F8),
          ),
          child: CustomPaint(
            painter: _RoadMapPainter(),
            child: places.isEmpty
                ? const SizedBox.shrink()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;

                      // Calculate normalized bounds
                      double minLat = 999.0;
                      double maxLat = -999.0;
                      double minLng = 999.0;
                      double maxLng = -999.0;

                      for (final p in places) {
                        if (p.latitude < minLat) minLat = p.latitude;
                        if (p.latitude > maxLat) maxLat = p.latitude;
                        if (p.longitude < minLng) minLng = p.longitude;
                        if (p.longitude > maxLng) maxLng = p.longitude;
                      }

                      if (maxLat == minLat) {
                        maxLat += 0.05;
                        minLat -= 0.05;
                      }
                      if (maxLng == minLng) {
                        maxLng += 0.05;
                        minLng -= 0.05;
                      }

                      final latRange = maxLat - minLat;
                      final lngRange = maxLng - minLng;

                      return Stack(
                        children: [
                          // User Location Marker (Blue Dot in Center)
                          Positioned(
                            left: width * 0.5 - 14,
                            top: height * 0.45 - 14,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Place Pins
                          ...places.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final place = entry.value;
                            final isSelected = selectedPlace?.placeId == place.placeId;

                            // Project lat/lng to widget coordinates with padding
                            double xRatio = (place.longitude - minLng) / lngRange;
                            double yRatio = 1.0 - ((place.latitude - minLat) / latRange);

                            // Add pseudo-random offset if lat/lng are identical
                            if (places.length > 1) {
                              xRatio = 0.15 + (xRatio.clamp(0.0, 1.0) * 0.7);
                              yRatio = 0.18 + (yRatio.clamp(0.0, 1.0) * 0.6);
                            } else {
                              xRatio = 0.5;
                              yRatio = 0.4;
                            }

                            // Manual staggered layout for realistic spread if same cluster
                            final posX = (width * xRatio) - (idx % 2 == 0 ? 10 : -10);
                            final posY = (height * yRatio) - (idx % 3 * 8);

                            return Positioned(
                              left: posX.clamp(10.0, width - 140.0),
                              top: posY.clamp(60.0, height - 70.0),
                              child: GestureDetector(
                                onTap: () => onSelectPlace(place),
                                child: _buildPlacePin(place, isSelected),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ),

        // Floating "Telusuri area ini" Button (Sesuai Screenshot Google Maps)
        Positioned(
          top: 14,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onSearchArea,
              icon: isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2563EB),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                isLoading ? 'Memuat Tempat...' : 'Telusuri area ini',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                elevation: 4,
                shadowColor: Colors.black26,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacePin(PlaceResult place, bool isSelected) {
    Color pinColor = const Color(0xFFDC2626); // Default Google Maps Red
    IconData icon = Icons.school_rounded;

    switch (place.inferredCategory) {
      case 'Kampus':
        icon = Icons.school_rounded;
        pinColor = const Color(0xFF9333EA);
        break;
      case 'BLK':
      case 'LPK':
      case 'LKP':
        icon = Icons.domain_rounded;
        pinColor = const Color(0xFFD97706);
        break;
      case 'Dinas Pemda':
        icon = Icons.account_balance_rounded;
        pinColor = const Color(0xFF0284C7);
        break;
      case 'Perusahaan Swasta':
        icon = Icons.business_rounded;
        pinColor = const Color(0xFF0F172A);
        break;
      case 'SMK':
      default:
        icon = Icons.school_rounded;
        pinColor = const Color(0xFFE11D48);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name Chip above pin
        Container(
          constraints: const BoxConstraints(maxWidth: 130),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            place.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),

        // Pin Bubble
        Container(
          width: isSelected ? 34 : 28,
          height: isSelected ? 34 : 28,
          decoration: BoxDecoration(
            color: pinColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, size: isSelected ? 18 : 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to draw realistic road-like grid background
class _RoadMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final greenAreaPaint = Paint()
      ..color = const Color(0xFFD8F3DC).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Green natural patches
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, size.height * 0.1, size.width * 0.35, size.height * 0.25),
        const Radius.circular(30),
      ),
      greenAreaPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.45, size.width * 0.4, size.height * 0.35),
        const Radius.circular(40),
      ),
      greenAreaPaint,
    );

    // Primary Roads (White paths)
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(
        size.width * 0.4,
        size.height * 0.35,
        size.width * 0.6,
        size.height * 0.55,
        size.width,
        size.height * 0.6,
      );
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.4,
        size.width * 0.55,
        size.height * 0.7,
        size.width * 0.3,
        size.height,
      );
    canvas.drawPath(path2, roadPaint);

    final path3 = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.4);
    canvas.drawPath(path3, roadPaint..strokeWidth = 3.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


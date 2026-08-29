import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/lead_model.dart';
import '../../../services/marketing/places_service.dart';

class PlaceSearchCard extends StatelessWidget {
  final PlaceResult place;
  final bool isSaved;
  final VoidCallback onSaveLead;
  final VoidCallback? onDirectPitch;

  const PlaceSearchCard({
    super.key,
    required this.place,
    required this.isSaved,
    required this.onSaveLead,
    this.onDirectPitch,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'SMK':
        return const Color(0xFF2563EB); // Blue
      case 'Kampus':
        return const Color(0xFF7C3AED); // Purple
      case 'BLK':
        return const Color(0xFF059669); // Green
      case 'LPK':
      case 'LKP':
        return const Color(0xFFD97706); // Amber
      case 'Dinas Pemda':
        return const Color(0xFFDC2626); // Red
      case 'Perusahaan Swasta':
      default:
        return const Color(0xFF0F172A); // Dark
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'SMK':
        return Icons.school_rounded;
      case 'Kampus':
        return Icons.account_balance_rounded;
      case 'BLK':
        return Icons.build_circle_rounded;
      case 'LPK':
      case 'LKP':
        return Icons.menu_book_rounded;
      case 'Dinas Pemda':
        return Icons.domain_rounded;
      case 'Perusahaan Swasta':
      default:
        return Icons.business_center_rounded;
    }
  }

  Future<void> _openMapDirections() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getCategoryColor(place.inferredCategory);
    final photoUrl = place.photoReference.isNotEmpty
        ? PlacesService.getPhotoUrl(place.photoReference, maxWidth: 200)
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSaved ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
          width: isSaved ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSaved
                ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                : const Color(0x08000000),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tag + Rating + Map icon
            Row(
              children: [
                // Category Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getCategoryIcon(place.inferredCategory),
                          size: 13, color: themeColor),
                      const SizedBox(width: 4),
                      Text(
                        place.inferredCategory,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Rating
                if (place.rating > 0) ...[
                  const Icon(Icons.star_rounded,
                      size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 2),
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (place.userRatingsTotal > 0) ...[
                    Text(
                      ' (${place.userRatingsTotal})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                ],
                // Open Map button
                InkWell(
                  onTap: _openMapDirections,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.directions_rounded,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle: Photo thumbnail + Name & Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photoUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_getCategoryIcon(place.inferredCategory),
                            color: themeColor, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getCategoryIcon(place.inferredCategory),
                        color: themeColor, size: 26),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.formattedAddress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Action Row
            Row(
              children: [
                // Save to Lead Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSaved ? null : onSaveLead,
                    icon: Icon(
                      isSaved
                          ? Icons.check_circle_rounded
                          : Icons.bookmark_add_rounded,
                      size: 16,
                    ),
                    label: Text(
                      isSaved ? 'Tersimpan di Prospek' : 'Simpan ke Lead',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaved
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFF2563EB),
                      foregroundColor:
                          isSaved ? const Color(0xFF2563EB) : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: isSaved
                            ? const BorderSide(color: Color(0xFFBFDBFE))
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (onDirectPitch != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDirectPitch,
                    tooltip: 'Hubungi via WhatsApp',
                    icon: const Icon(
                      Icons.chat_rounded,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFDCFCE7),
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}


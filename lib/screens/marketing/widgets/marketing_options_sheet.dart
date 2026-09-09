import 'package:material_ui/material_ui.dart';
import '../../../services/marketing/places_service.dart';

Future<void> showMarketingOptionsSheet({
  required BuildContext context,
  required int searchRadiusKm,
  required String? locationName,
  required VoidCallback onOpenFilter,
  required VoidCallback onSyncLocation,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.dashboard_customize_rounded,
                      color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Menu & Opsi Penelusuran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MenuOptionItem(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Filter Prospek & Blacklist',
                subtitle:
                    'Sesuaikan radius ($searchRadiusKm km), kategori & kata kunci',
                onTap: () {
                  Navigator.pop(ctx);
                  onOpenFilter();
                },
              ),
              const SizedBox(height: 10),
              _MenuOptionItem(
                icon: Icons.my_location_rounded,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFF0FDF4),
                title: 'Sinkronkan Lokasi GPS Live',
                subtitle: locationName ??
                    'Dapatkan koordinat akurat perangkat live',
                onTap: () {
                  Navigator.pop(ctx);
                  onSyncLocation();
                },
              ),
              const SizedBox(height: 10),
              _MenuOptionItem(
                icon: Icons.cached_rounded,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFFFBEB),
                title: 'Bersihkan Cache Pencarian',
                subtitle: 'Muat ulang data tempat segar langsung dari server',
                onTap: () {
                  Navigator.pop(ctx);
                  PlacesService.clearSearchCache();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Cache pencarian tempat berhasil dibersihkan'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MenuOptionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuOptionItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

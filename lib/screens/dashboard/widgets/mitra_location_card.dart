import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';
import '../../../models/asesor_dashboard_models.dart';
import 'mitra_external_url.dart';

class MitraLocationCard extends StatelessWidget {
  final AsesorMitra mitra;
  final double? lat;
  final double? lng;
  final String? resolvedAddress;
  final bool isResolving;

  const MitraLocationCard({
    super.key,
    required this.mitra,
    required this.lat,
    required this.lng,
    required this.resolvedAddress,
    required this.isResolving,
  });

  @override
  Widget build(BuildContext context) {
    final hasLatLng = lat != null && lng != null;
    final hasValidCoordinates = hasLatLng && lat! >= -90 && lat! <= 90 && lng! >= -180 && lng! <= 180;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded, size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lokasi & Peta TUK',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (isResolving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Navigasi dan titik lokasi tempat uji kompetensi mitra.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          if (isResolving)
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Menemukan lokasi berdasarkan alamat...',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else if (hasValidCoordinates) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat!, lng!),
                    zoom: 16,
                  ),
                  liteModeEnabled: true,
                  markers: {
                    Marker(
                      markerId: MarkerId('mitra-${mitra.id}'),
                      position: LatLng(lat!, lng!),
                      infoWindow: InfoWindow(
                        title: mitra.namaTuk.isNotEmpty ? mitra.namaTuk : 'TUK Mitra',
                        snippet: resolvedAddress ?? mitra.alamat,
                      ),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openMitraExternalUrl('https://www.google.com/maps/search/?api=1&query=${lat!},${lng!}'),
                    icon: const Icon(Icons.map_outlined, size: 15),
                    label: const Text('Buka Maps', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => openMitraExternalUrl('https://www.google.com/maps/dir/?api=1&destination=${lat!},${lng!}'),
                    icon: const Icon(Icons.directions_rounded, size: 15),
                    label: const Text('Petunjuk Arah', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_off_rounded, color: Color(0xFF94A3B8), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Koordinat peta belum tersimpan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Anda dapat mencari dan membuka lokasi secara manual melalui Google Maps menggunakan nama dan alamat mitra.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final searchQuery = [
                          if (mitra.namaTuk.isNotEmpty) mitra.namaTuk,
                          if (mitra.alamat.isNotEmpty) mitra.alamat,
                          if (mitra.kota.isNotEmpty) mitra.kota,
                        ].join(' ');
                        openMitraExternalUrl(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}',
                        );
                      },
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: const Text('Cari Alamat di Google Maps', style: TextStyle(fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

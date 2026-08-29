import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';
import '../../../services/marketing/location_service.dart';

class LeadMapCanvas extends StatefulWidget {
  final List<PlaceResult> places;
  final PlaceResult? selectedPlace;
  final UserGeoLocation? userLocation;
  final Set<String> savedPlaceIds;
  final Set<String> savedNames;
  final Function(PlaceResult place) onSelectPlace;
  final VoidCallback onSearchArea;
  final Future<void> Function()? onMyLocationPressed;
  final bool isLoading;

  const LeadMapCanvas({
    super.key,
    required this.places,
    this.selectedPlace,
    this.userLocation,
    this.savedPlaceIds = const {},
    this.savedNames = const {},
    required this.onSelectPlace,
    required this.onSearchArea,
    this.onMyLocationPressed,
    this.isLoading = false,
  });

  @override
  State<LeadMapCanvas> createState() => _LeadMapCanvasState();
}

class _LeadMapCanvasState extends State<LeadMapCanvas> {
  GoogleMapController? _mapController;

  // Default Center (Yogyakarta fallback)
  static const LatLng _defaultCenter = LatLng(-7.7956, 110.3695);

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    for (final place in widget.places) {
      final isSelected = widget.selectedPlace?.placeId == place.placeId;
      final isSaved = widget.savedPlaceIds.contains(place.placeId) ||
          widget.savedNames.contains(place.name.toLowerCase().trim());

      // Color distinction:
      // - GREEN / AZURE: Tempat yang SUDAH disimpan di database prospek asesor
      // - RED: Tempat baru dari Google Maps yang BELUM ada di database (Calon Prospek)
      final double markerHue = isSaved
          ? BitmapDescriptor.hueGreen
          : BitmapDescriptor.hueRed;

      final String statusTag =
          isSaved ? '✓ [Tersimpan di Prospek]' : '[Calon Prospek Baru]';

      markers.add(
        Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          zIndexInt: isSelected ? 3 : (isSaved ? 2 : 1),
          infoWindow: InfoWindow(
            title: '${isSaved ? "✓ " : ""}${place.name}',
            snippet:
                '$statusTag ${place.inferredCategory} • Rating: ${place.rating > 0 ? place.rating : "-"}',
            onTap: () => widget.onSelectPlace(place),
          ),
          onTap: () => widget.onSelectPlace(place),
        ),
      );
    }

    return markers;
  }

  void _animateToSelectedPlace() {
    if (_mapController != null && widget.selectedPlace != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.selectedPlace!.latitude,
            widget.selectedPlace!.longitude,
          ),
          15.0,
        ),
      );
    } else if (_mapController != null && widget.places.isNotEmpty) {
      final first = widget.places.first;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(first.latitude, first.longitude),
          13.5,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant LeadMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlace?.placeId != widget.selectedPlace?.placeId ||
        oldWidget.savedPlaceIds.length != widget.savedPlaceIds.length) {
      _animateToSelectedPlace();
    }
  }

  Future<void> _handleMyLocation() async {
    if (widget.onMyLocationPressed != null) {
      await widget.onMyLocationPressed!();
    } else {
      final loc = await LocationService.getCurrentLocation();
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(loc.latitude, loc.longitude),
            14.5,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialTarget = _defaultCenter;
    if (widget.userLocation != null) {
      initialTarget = LatLng(
        widget.userLocation!.latitude,
        widget.userLocation!.longitude,
      );
    } else if (widget.places.isNotEmpty) {
      initialTarget = LatLng(
        widget.places.first.latitude,
        widget.places.first.longitude,
      );
    }

    return Stack(
      children: [
        // Native Google Maps View
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: 13.5,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _animateToSelectedPlace();
          },
          markers: _buildMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          onCameraMove: (_) {},
        ),

        // Floating Legend Indicator (Merah = Baru, Hijau = Tersimpan)
        Positioned(
          top: 70,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.red),
                SizedBox(width: 2),
                Text('Baru dari Maps',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                SizedBox(width: 8),
                Icon(Icons.location_on, size: 14, color: Colors.green),
                SizedBox(width: 2),
                Text('Tersimpan di DB',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
              ],
            ),
          ),
        ),

        // Floating "Telusuri area ini" Button
        Positioned(
          top: 14,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: widget.isLoading ? null : widget.onSearchArea,
              icon: widget.isLoading
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
                widget.isLoading ? 'Memuat Tempat...' : 'Telusuri area ini',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),

        // Floating My Location Button (GPS Device Geolocation)
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'my_location_btn',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2563EB),
            elevation: 3,
            onPressed: _handleMyLocation,
            tooltip: 'Lokasi Saya',
            child: const Icon(Icons.my_location_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}

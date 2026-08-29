import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';

class LeadMapCanvas extends StatefulWidget {
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
  State<LeadMapCanvas> createState() => _LeadMapCanvasState();
}

class _LeadMapCanvasState extends State<LeadMapCanvas> {
  GoogleMapController? _mapController;

  // Default Center (Yogyakarta / Sampit based on results)
  static const LatLng _defaultCenter = LatLng(-7.8012, 110.4283);

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    for (final place in widget.places) {
      final isSelected =
          widget.selectedPlace?.placeId == place.placeId;

      markers.add(
        Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.latitude, place.longitude),
          // Always RED pin for standard Google Maps markers
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndexInt: isSelected ? 2 : 1,
          infoWindow: InfoWindow(
            title: place.name,
            snippet:
                '${place.inferredCategory} • Rating: ${place.rating > 0 ? place.rating : "-"}',
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
          14.5,
        ),
      );
    } else if (_mapController != null && widget.places.isNotEmpty) {
      // Zoom to first place
      final first = widget.places.first;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(first.latitude, first.longitude),
          13.0,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant LeadMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlace?.placeId != widget.selectedPlace?.placeId ||
        oldWidget.places.length != widget.places.length) {
      _animateToSelectedPlace();
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialTarget = _defaultCenter;
    if (widget.places.isNotEmpty) {
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
            zoom: 13.0,
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

        // Floating My Location Target Button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'my_location_btn',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2563EB),
            elevation: 3,
            onPressed: () {
              if (_mapController != null && widget.places.isNotEmpty) {
                final target = LatLng(
                  widget.places.first.latitude,
                  widget.places.first.longitude,
                );
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(target, 14.0),
                );
              }
            },
            child: const Icon(Icons.my_location_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}

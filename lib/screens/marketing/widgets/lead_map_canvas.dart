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

  // Default Center (Jakarta fallback)
  static const LatLng _defaultCenter = LatLng(-6.2088, 106.8456);

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    for (final place in widget.places) {
      final isSelected = widget.selectedPlace?.placeId == place.placeId;
      final isSaved = widget.savedPlaceIds.contains(place.placeId) ||
          widget.savedNames.contains(place.name.toLowerCase().trim());

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
        oldWidget.savedPlaceIds.length != widget.savedPlaceIds.length ||
        oldWidget.places.length != widget.places.length) {
      _animateToSelectedPlace();
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

    return GoogleMap(
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
    );
  }
}

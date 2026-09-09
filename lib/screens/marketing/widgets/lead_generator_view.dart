import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';
import '../../../services/marketing/location_service.dart';
import 'lead_map_canvas.dart';
import 'place_search_card.dart';

class LeadGeneratorView extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final bool isLoadingPlaces;
  final List<PlaceResult> places;
  final PlaceResult? selectedPlace;
  final UserGeoLocation? userLocation;
  final Set<String> savedPlaceIds;
  final Set<String> savedNames;
  final bool filterRetailNoise;
  final int idAsesor;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PlaceResult?> onSelectPlace;
  final Future<void> Function({String? query}) onFetchPlaces;
  final Future<void> Function() onMyLocation;
  final VoidCallback onOpenFilter;
  final ValueChanged<String> onCategoryFilter;
  final Future<void> Function(PlaceResult) onSavePlace;
  final VoidCallback onShowSaved;
  final void Function(PlaceResult) onDirectPitch;

  const LeadGeneratorView({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.isLoadingPlaces,
    required this.places,
    required this.selectedPlace,
    required this.userLocation,
    required this.savedPlaceIds,
    required this.savedNames,
    required this.onSearchChanged,
    required this.filterRetailNoise,
    required this.idAsesor,
    required this.onSelectPlace,
    required this.onFetchPlaces,
    required this.onMyLocation,
    required this.onOpenFilter,
    required this.onCategoryFilter,
    required this.onSavePlace,
    required this.onShowSaved,
    required this.onDirectPitch,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: LeadMapCanvas(
            places: places,
            selectedPlace: selectedPlace,
            userLocation: userLocation,
            savedPlaceIds: savedPlaceIds,
            savedNames: savedNames,
            isLoading: isLoadingPlaces,
            onSelectPlace: onSelectPlace,
            onSearchArea: () => onFetchPlaces(),
            onMyLocationPressed: onMyLocation,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          onSubmitted: (val) {
                            final query =
                                val.trim().isNotEmpty ? val.trim() : 'SMK';
                            onFetchPlaces(query: query);
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari SMK, Kampus, BLK, Dinas...',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFF2563EB)),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 18),
                                    onPressed: () {
                                      searchController.clear();
                                      onCategoryFilter('Semua');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: filterRetailNoise
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      shape: const CircleBorder(),
                      elevation: 3,
                      shadowColor: const Color(0x1F000000),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: filterRetailNoise
                              ? Colors.white
                              : const Color(0xFF2563EB),
                          size: 20,
                        ),
                        onPressed: onOpenFilter,
                        tooltip: 'Pengaturan Filter & Blacklist',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                        label: 'Semua',
                        icon: Icons.explore_rounded,
                        selected: selectedCategory == 'Semua',
                        onTap: () => onCategoryFilter('Semua')),
                    _CategoryChip(
                        label: 'SMK',
                        icon: Icons.school_rounded,
                        selected: selectedCategory == 'SMK',
                        onTap: () => onCategoryFilter('SMK')),
                    _CategoryChip(
                        label: 'Kampus',
                        icon: Icons.account_balance_rounded,
                        selected: selectedCategory == 'Kampus',
                        onTap: () => onCategoryFilter('Kampus')),
                    _CategoryChip(
                        label: 'BLK',
                        icon: Icons.build_circle_rounded,
                        selected: selectedCategory == 'BLK',
                        onTap: () => onCategoryFilter('BLK')),
                    _CategoryChip(
                        label: 'LPK',
                        icon: Icons.menu_book_rounded,
                        selected: selectedCategory == 'LPK',
                        onTap: () => onCategoryFilter('LPK')),
                    _CategoryChip(
                        label: 'Dinas Pemda',
                        icon: Icons.domain_rounded,
                        selected: selectedCategory == 'Dinas Pemda',
                        onTap: () => onCategoryFilter('Dinas Pemda')),
                    _CategoryChip(
                        label: 'Perusahaan Swasta',
                        icon: Icons.business_center_rounded,
                        selected: selectedCategory == 'Perusahaan Swasta',
                        onTap: () => onCategoryFilter('Perusahaan Swasta')),
                  ],
                ),
              ),
            ],
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.12,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hasil Pencarian (${places.length} Tempat)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 13, color: Colors.red),
                                  SizedBox(width: 2),
                                  Text('Baru',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                  SizedBox(width: 8),
                                  Icon(Icons.location_on,
                                      size: 13, color: Colors.green),
                                  SizedBox(width: 2),
                                  Text('Tersimpan di DB',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isLoadingPlaces)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2563EB),
                            ),
                          )
                        else
                          InkWell(
                            onTap: onMyLocation,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFBFDBFE), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.my_location_rounded,
                                      size: 14, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      userLocation?.locationName ??
                                          'Lokasi Saya',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (places.isEmpty && !isLoadingPlaces)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Tidak ada tempat ditemukan. Coba ubah kata kunci atau geser peta.',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...places.map((place) {
                      final isSaved = savedPlaceIds.contains(place.placeId) ||
                          savedNames.contains(place.name.toLowerCase().trim());
                      final isSelected =
                          selectedPlace?.placeId == place.placeId;
                      return PlaceSearchCard(
                        place: place,
                        isSaved: isSaved,
                        isSelected: isSelected,
                        onTap: () => onSelectPlace(place),
                        onSaveLead: isSaved
                            ? onShowSaved
                            : () => onSavePlace(place),
                        onDirectPitch: () => onDirectPitch(place),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 14,
          color: selected ? Colors.white : const Color(0xFF475569),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        selected: selected,
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

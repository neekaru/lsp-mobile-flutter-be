import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart'
    as places_sdk;
import 'package:http/http.dart' as http;
import '../../models/lead_model.dart';
import 'location_service.dart';

class PlacesService {
  static const String _defaultApiKey =
      'AIzaSyA9i8FJTM8skspMB5DueA4rcv5RVSlXpsM';

  static String get apiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return _defaultApiKey;
  }

  static places_sdk.FlutterGooglePlacesSdk? _sdk;

  static places_sdk.FlutterGooglePlacesSdk get sdk {
    _sdk ??= places_sdk.FlutterGooglePlacesSdk(
      apiKey,
      locale: const Locale('id', 'ID'),
    );
    return _sdk!;
  }

  /// Search places purely using Google Places Engines with natural proximity sorting
  static Future<List<PlaceResult>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 12000,
    bool filterRetail = true,
    List<String>? allowedCategories,
  }) async {
    final cleanQuery = query.replaceAll('terdekat', '').trim();
    if (cleanQuery.isEmpty) return [];

    List<PlaceResult> results = [];

    // 1. Native Google Places SDK Plus (searchByText & findAutocompletePredictions)
    try {
      final nativeResults = await _searchGooglePlacesNativeSdk(
        query: cleanQuery,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      if (nativeResults.isNotEmpty) {
        results = nativeResults;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Google Places SDK Plus Error: $e');
    }

    // 2. Try Google Places API (New Text Search v1)
    if (results.isEmpty) {
      try {
        final googleNewResults = await _searchGooglePlacesNew(
          query: cleanQuery,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
        if (googleNewResults.isNotEmpty) {
          results = googleNewResults;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Google Places v1 Error: $e');
      }
    }

    // 3. Try Google Places API (Legacy Text Search)
    if (results.isEmpty) {
      try {
        String url =
            'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(cleanQuery)}&key=$apiKey';

        if (latitude != null && longitude != null) {
          url += '&location=$latitude,$longitude&radius=$radius';
        }

        final response = await http.get(Uri.parse(url)).timeout(
              const Duration(seconds: 8),
            );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final status = data['status']?.toString();

          if (status == 'OK') {
            final list = data['results'] as List<dynamic>? ?? [];
            if (list.isNotEmpty) {
              results = list
                  .map((e) =>
                      PlaceResult.fromGoogleJson(e as Map<String, dynamic>))
                  .toList();
            }
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Google Places Legacy Error: $e');
      }
    }

    // Filter out retail noise if enabled
    if (filterRetail) {
      results =
          results.where((p) => !_isIrrelevantPlace(p, cleanQuery)).toList();
    }

    // Filter by allowed categories if specified
    if (allowedCategories != null &&
        allowedCategories.isNotEmpty &&
        !allowedCategories.contains('Semua')) {
      results = results.where((p) {
        return allowedCategories.contains(p.inferredCategory);
      }).toList();
    }

    // Pure natural sorting by distance ascending (closest places first)
    if (latitude != null && longitude != null && results.isNotEmpty) {
      results.sort((a, b) {
        final distA = LocationService.distanceInMeters(
            latitude, longitude, a.latitude, a.longitude);
        final distB = LocationService.distanceInMeters(
            latitude, longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
    }

    return results;
  }

  /// 1. Native Google Places SDK Plus Android/iOS
  static Future<List<PlaceResult>> _searchGooglePlacesNativeSdk({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 12000,
  }) async {
    // 1A. SearchByText with pure user keyword
    try {
      final delta = (radius / 100000.0).clamp(0.03, 0.5);
      final response = await sdk.searchByText(
        query,
        fields: [
          places_sdk.PlaceField.Id,
          places_sdk.PlaceField.DisplayName,
          places_sdk.PlaceField.FormattedAddress,
          places_sdk.PlaceField.Location,
          places_sdk.PlaceField.Rating,
          places_sdk.PlaceField.UserRatingCount,
          places_sdk.PlaceField.Types,
          places_sdk.PlaceField.NationalPhoneNumber,
          places_sdk.PlaceField.WebsiteUri,
        ],
        locationBias: latitude != null && longitude != null
            ? places_sdk.LatLngBounds(
                southwest: places_sdk.LatLng(
                    lat: latitude - delta, lng: longitude - delta),
                northeast: places_sdk.LatLng(
                    lat: latitude + delta, lng: longitude + delta),
              )
            : null,
        maxResultCount: 20,
      );

      final places = response.places;
      if (places.isNotEmpty) {
        return places.map((p) {
          final name = p.displayName?.text ?? p.name ?? 'Lokasi';
          final address = p.address ?? p.shortFormattedAddress ?? '';
          final lat = p.latLng?.lat ?? 0.0;
          final lng = p.latLng?.lng ?? 0.0;
          final types = p.types?.map((e) => e.name).toList() ?? [];

          return PlaceResult(
            placeId: p.id ?? 'sdk_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            formattedAddress: address,
            latitude: lat,
            longitude: lng,
            rating: p.rating ?? 4.8,
            userRatingsTotal: p.userRatingsTotal ?? 100,
            types: types,
            inferredCategory: inferCategory(name, address, types),
            phoneNumber: p.phoneNumber ?? '',
            website: p.websiteUri?.toString() ?? '',
          );
        }).where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ searchByText failed: $e');
    }

    // 1B. Fallback to Autocomplete Predictions
    try {
      final delta = (radius / 100000.0).clamp(0.03, 0.5);
      final predResponse = await sdk.findAutocompletePredictions(
        query,
        countries: ['id'],
        origin: latitude != null && longitude != null
            ? places_sdk.LatLng(lat: latitude, lng: longitude)
            : null,
        locationBias: latitude != null && longitude != null
            ? places_sdk.LatLngBounds(
                southwest: places_sdk.LatLng(
                    lat: latitude - delta, lng: longitude - delta),
                northeast: places_sdk.LatLng(
                    lat: latitude + delta, lng: longitude + delta),
              )
            : null,
      );

      final predictions = predResponse.predictions;
      if (predictions.isNotEmpty) {
        final List<PlaceResult> results = [];
        for (final pred in predictions.take(15)) {
          final pId = pred.placeId;
          if (pId == null || pId.isEmpty) continue;

          try {
            final details = await sdk.fetchPlace(
              pId,
              fields: [
                places_sdk.PlaceField.Location,
                places_sdk.PlaceField.DisplayName,
                places_sdk.PlaceField.FormattedAddress,
                places_sdk.PlaceField.Rating,
                places_sdk.PlaceField.UserRatingCount,
                places_sdk.PlaceField.Types,
                places_sdk.PlaceField.NationalPhoneNumber,
                places_sdk.PlaceField.WebsiteUri,
              ],
            );

            final p = details.place;
            if (p != null && p.latLng != null) {
              final name = p.displayName?.text ?? p.name ?? pred.primaryText ?? 'Lokasi';
              final address = p.address ?? p.shortFormattedAddress ?? pred.fullText ?? '';
              final lat = p.latLng!.lat;
              final lng = p.latLng!.lng;
              final types = p.types?.map((e) => e.name).toList() ?? [];

              results.add(
                PlaceResult(
                  placeId: pId,
                  name: name,
                  formattedAddress: address,
                  latitude: lat,
                  longitude: lng,
                  rating: p.rating ?? 4.8,
                  userRatingsTotal: p.userRatingsTotal ?? 100,
                  types: types,
                  inferredCategory: inferCategory(name, address, types),
                  phoneNumber: p.phoneNumber ?? '',
                  website: p.websiteUri?.toString() ?? '',
                ),
              );
            }
          } catch (_) {}
        }
        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ findAutocompletePredictions failed: $e');
    }

    return [];
  }

  /// Google Places API (New) Text Search
  static Future<List<PlaceResult>> _searchGooglePlacesNew({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 12000,
  }) async {
    const url = 'https://places.googleapis.com/v1/places:searchText';
    final Map<String, dynamic> body = {
      'textQuery': query,
      'languageCode': 'id',
      'maxResultCount': 20,
    };

    if (latitude != null && longitude != null) {
      body['locationBias'] = {
        'circle': {
          'center': {'latitude': latitude, 'longitude': longitude},
          'radius': radius.toDouble(),
        }
      };
    }

    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask':
                'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.types,places.nationalPhoneNumber,places.websiteUri,places.photos',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> places = data['places'] as List<dynamic>? ?? [];

      return places.map((p) {
        final map = p as Map<String, dynamic>;
        final displayNameMap = map['displayName'] as Map<String, dynamic>?;
        final name = displayNameMap?['text']?.toString() ?? 'Lokasi';
        final address = map['formattedAddress']?.toString() ?? '';
        final location = map['location'] as Map<String, dynamic>?;
        final lat = (location?['latitude'] as num?)?.toDouble() ?? 0.0;
        final lng = (location?['longitude'] as num?)?.toDouble() ?? 0.0;
        final rating = (map['rating'] as num?)?.toDouble() ?? 0.0;
        final count = (map['userRatingCount'] as num?)?.toInt() ?? 0;
        final types = (map['types'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final phone = map['nationalPhoneNumber']?.toString() ?? '';
        final website = map['websiteUri']?.toString() ?? '';

        String photoRef = '';
        final photos = map['photos'] as List<dynamic>?;
        if (photos != null && photos.isNotEmpty) {
          final firstPhoto = photos.first as Map<String, dynamic>?;
          photoRef = firstPhoto?['name']?.toString() ?? '';
        }

        return PlaceResult(
          placeId: map['id']?.toString() ?? '',
          name: name,
          formattedAddress: address,
          latitude: lat,
          longitude: lng,
          rating: rating,
          userRatingsTotal: count,
          types: types,
          inferredCategory: inferCategory(name, address, types),
          phoneNumber: phone,
          website: website,
          photoReference: photoRef,
        );
      }).where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
    }
    return [];
  }

  /// Check if place is random consumer retail (swalayan, warung, laundry, etc.)
  static bool _isIrrelevantPlace(PlaceResult p, String rawQuery) {
    final lowerQ = rawQuery.toLowerCase();
    if (lowerQ.contains('swalayan') ||
        lowerQ.contains('toko') ||
        lowerQ.contains('mart') ||
        lowerQ.contains('supermarket') ||
        lowerQ.contains('resto') ||
        lowerQ.contains('cafe')) {
      return false;
    }

    final lowerName = p.name.toLowerCase();
    final allTypes = p.types.map((t) => t.toLowerCase()).join(' ');

    const blacklist = [
      'swalayan',
      'minimarket',
      'supermarket',
      'indomaret',
      'alfamart',
      'alfamidi',
      'toko kelontong',
      'warung',
      'laundry',
      'barbershop',
      'salon kecantikan',
      'counter hp',
      'counter pulsa',
      'fotocopy',
      'bengkel motor',
      'cuci motor',
      'cuci mobil',
      'bakso',
      'mie ayam',
      'cafe',
      'restoran',
      'restaurant',
      'grocery',
      'convenience_store',
      'clothing_store',
      'beauty_salon',
      'hair_care',
      'musholla',
      'masjid',
      'gereja',
      'pura',
      'vihara',
      'hotel',
      'penginapan',
      'homestay',
    ];

    for (final b in blacklist) {
      if (lowerName.contains(b)) return true;
    }

    if (allTypes.contains('convenience_store') ||
        allTypes.contains('grocery_or_supermarket') ||
        allTypes.contains('supermarket') ||
        allTypes.contains('restaurant') ||
        allTypes.contains('cafe') ||
        allTypes.contains('clothing_store') ||
        allTypes.contains('barber_shop') ||
        allTypes.contains('beauty_salon')) {
      if (!lowerName.contains('smk') &&
          !lowerName.contains('sekolah') &&
          !lowerName.contains('kampus') &&
          !lowerName.contains('universitas') &&
          !lowerName.contains('institut') &&
          !lowerName.contains('politeknik') &&
          !lowerName.contains('blk') &&
          !lowerName.contains('lpk') &&
          !lowerName.contains('dinas') &&
          !lowerName.contains('pt ') &&
          !lowerName.contains('cv ')) {
        return true;
      }
    }

    return false;
  }

  /// Dynamic Category Inferrer (Exposed for Advanced Search & Tagging)
  static String inferCategory(
      String name, String address, List<String> types) {
    final full = '$name $address ${types.join(" ")}'.toLowerCase();

    // 1. SMK & Sekolah Menengah Kejuruan
    if (full.contains('smk') ||
        full.contains('kejuruan') ||
        full.contains('vokasi') ||
        full.contains('sekolah') ||
        full.contains('school')) {
      return 'SMK';
    }

    // 2. Kampus, Universitas, Institut, Politeknik, Akademi
    if (full.contains('universitas') ||
        full.contains('kampus') ||
        full.contains('institut') ||
        full.contains('politeknik') ||
        full.contains('college') ||
        full.contains('akademi') ||
        full.contains('university')) {
      return 'Kampus';
    }

    // 3. Balai Latihan Kerja (BLK)
    if (full.contains('blk') ||
        full.contains('balai latihan') ||
        full.contains('pelatihan kerja')) {
      return 'BLK';
    }

    // 4. Lembaga Pelatihan Kerja (LPK)
    if (full.contains('lpk') ||
        full.contains('lkp') ||
        full.contains('kursus') ||
        full.contains('training center')) {
      return 'LPK';
    }

    // 5. Dinas Pemerintah
    if (full.contains('dinas') ||
        full.contains('kementerian') ||
        full.contains('badan') ||
        full.contains('kantor') ||
        full.contains('pemda') ||
        full.contains('government')) {
      return 'Dinas Pemda';
    }

    // 6. Default Perusahaan Swasta (PT/CV)
    return 'Perusahaan Swasta';
  }

  /// Get photo URL from Google Places API photo reference
  static String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (photoReference.isEmpty) return '';
    if (photoReference.startsWith('places/')) {
      return 'https://places.googleapis.com/v1/$photoReference/media?maxHeightPx=$maxWidth&maxWidthPx=$maxWidth&key=$apiKey';
    }
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }
}

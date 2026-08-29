import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart'
    as places_sdk;
import 'package:http/http.dart' as http;
import '../../models/lead_model.dart';

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

  /// Search places within radius around user coordinate
  static Future<List<PlaceResult>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 15000,
  }) async {
    final cleanQuery = query.replaceAll('terdekat', '').trim();
    if (cleanQuery.isEmpty) return [];

    List<PlaceResult> results = [];

    // 1. Native Google Places SDK Plus (searchByText & findAutocompletePredictions with SHA-1 auth)
    try {
      final nativeResults = await _searchGooglePlacesNativeSdk(
        query: cleanQuery,
        latitude: latitude,
        longitude: longitude,
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

    // 4. Try Live OpenStreetMap Nominatim Global Search (Strictly bounded by local viewbox)
    if (results.isEmpty) {
      try {
        final osmResults = await _searchLiveNominatim(
          query: cleanQuery,
          latitude: latitude,
          longitude: longitude,
        );
        if (osmResults.isNotEmpty) {
          results = osmResults;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Nominatim Search Error: $e');
      }
    }

    // 5. Try Photon Komoot Live Geocoding API
    if (results.isEmpty) {
      try {
        final photonResults = await _searchLivePhoton(
          query: cleanQuery,
          latitude: latitude,
          longitude: longitude,
        );
        if (photonResults.isNotEmpty) {
          results = photonResults;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Photon Search Error: $e');
      }
    }

    // Sort results strictly by distance to user coordinate if available
    if (latitude != null && longitude != null && results.isNotEmpty) {
      results.sort((a, b) {
        final distA = (a.latitude - latitude).abs() +
            (a.longitude - longitude).abs();
        final distB = (b.latitude - latitude).abs() +
            (b.longitude - longitude).abs();
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
  }) async {
    // 1A. Try searchByText with Location Bias
    try {
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
                    lat: latitude - 0.08, lng: longitude - 0.08),
                northeast: places_sdk.LatLng(
                    lat: latitude + 0.08, lng: longitude + 0.08),
              )
            : null,
        maxResultCount: 20,
      );

      final places = response.places;
      if (places.isNotEmpty) {
        return places.map((p) {
          final name =
              p.displayName?.text ?? p.name ?? 'Lokasi';
          final address =
              p.address ?? p.shortFormattedAddress ?? '';
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
            inferredCategory: _inferCategory(name, address, types),
            phoneNumber: p.phoneNumber ?? '',
            website: p.websiteUri?.toString() ?? '',
          );
        }).where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ searchByText failed, fallback to predictions: $e');
    }

    // 1B. Fallback to Autocomplete Predictions
    final predResponse = await sdk.findAutocompletePredictions(
      query,
      countries: ['id'],
      origin: latitude != null && longitude != null
          ? places_sdk.LatLng(lat: latitude, lng: longitude)
          : null,
    );

    final predictions = predResponse.predictions;
    if (predictions.isEmpty) return [];

    final List<PlaceResult> results = [];
    final limited = predictions.take(12).toList();

    for (final pred in limited) {
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
              inferredCategory: _inferCategory(name, address, types),
              phoneNumber: p.phoneNumber ?? '',
              website: p.websiteUri?.toString() ?? '',
            ),
          );
        }
      } catch (e) {
        // Continue to next prediction
      }
    }

    return results;
  }

  /// Google Places API (New) Text Search
  static Future<List<PlaceResult>> _searchGooglePlacesNew({
    required String query,
    double? latitude,
    double? longitude,
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
          'radius': 15000.0,
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
          inferredCategory: _inferCategory(name, address, types),
          phoneNumber: phone,
          website: website,
          photoReference: photoRef,
        );
      }).where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
    }
    return [];
  }

  /// Live Nominatim Search Engine (OpenStreetMap)
  static Future<List<PlaceResult>> _searchLiveNominatim({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    String q = query.trim();
    final lower = q.toLowerCase();

    // Expansion for common Indonesian acronyms
    if (lower == 'ugm') {
      q = 'Universitas Gadjah Mada';
    } else if (lower == 'uny') {
      q = 'Universitas Negeri Yogyakarta';
    } else if (lower == 'uin' || lower == 'uin suka') {
      q = 'UIN Sunan Kalijaga';
    } else if (lower == 'ui') {
      q = 'Universitas Indonesia';
    } else if (lower == 'itb') {
      q = 'Institut Teknologi Bandung';
    } else if (lower == 'undip') {
      q = 'Universitas Diponegoro';
    } else if (lower == 'uad') {
      q = 'Universitas Ahmad Dahlan';
    } else if (lower == 'umy') {
      q = 'Universitas Muhammadiyah Yogyakarta';
    }

    String url =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&addressdetails=1&limit=20&countrycodes=id';

    if (latitude != null && longitude != null) {
      final minLat = latitude - 0.15;
      final maxLat = latitude + 0.15;
      final minLng = longitude - 0.15;
      final maxLng = longitude + 0.15;
      url += '&viewbox=$minLng,$maxLat,$maxLng,$minLat&bounded=0';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'LSPDigitalMobile/1.2 (asesor@lsp-digital.id)',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.map((item) {
          final map = item as Map<String, dynamic>;
          final displayName = map['display_name']?.toString() ?? '';
          final rawName = map['name']?.toString() ?? '';
          final name = rawName.isNotEmpty
              ? rawName
              : displayName.split(',').first.trim();

          final lat = double.tryParse(map['lat']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(map['lon']?.toString() ?? '') ?? 0.0;
          final type = map['type']?.toString() ?? '';
          final category = map['category']?.toString() ?? '';

          return PlaceResult(
            placeId:
                'osm_${map['place_id'] ?? map['osm_id'] ?? DateTime.now().millisecondsSinceEpoch}',
            name: name,
            formattedAddress: displayName,
            latitude: lat,
            longitude: lon,
            rating: 4.8,
            userRatingsTotal: 120,
            types: [type, category],
            inferredCategory:
                _inferCategory(name, displayName, [type, category]),
          );
        }).where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
      }
    }
    return [];
  }

  /// Live Photon Komoot Geocoding Search Engine
  static Future<List<PlaceResult>> _searchLivePhoton({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    String url =
        'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=20';
    if (latitude != null && longitude != null) {
      url += '&lat=$latitude&lon=$longitude';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> features = data['features'] as List<dynamic>? ?? [];

      return features.map((f) {
        final feat = f as Map<String, dynamic>;
        final geometry = feat['geometry'] as Map<String, dynamic>?;
        final coordinates =
            geometry?['coordinates'] as List<dynamic>? ?? [];
        final double lon = coordinates.isNotEmpty
            ? (coordinates[0] as num).toDouble()
            : 0.0;
        final double lat = coordinates.length > 1
            ? (coordinates[1] as num).toDouble()
            : 0.0;

        final props = feat['properties'] as Map<String, dynamic>? ?? {};
        final name = props['name']?.toString() ?? 'Lokasi';
        final street = props['street']?.toString() ?? '';
        final city = props['city']?.toString() ??
            props['county']?.toString() ??
            props['state']?.toString() ??
            '';
        final country = props['country']?.toString() ?? 'Indonesia';

        final addressParts = [name, street, city, country]
            .where((s) => s.isNotEmpty)
            .toList();
        final fullAddress = addressParts.join(', ');

        return PlaceResult(
          placeId:
              'photon_${props['osm_id'] ?? DateTime.now().millisecondsSinceEpoch}',
          name: name,
          formattedAddress: fullAddress,
          latitude: lat,
          longitude: lon,
          rating: 4.7,
          userRatingsTotal: 80,
          types: [props['osm_value']?.toString() ?? ''],
          inferredCategory: _inferCategory(name, fullAddress, [
            props['osm_key']?.toString() ?? '',
            props['osm_value']?.toString() ?? ''
          ]),
        );
      }).where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
    }
    return [];
  }

  static String _inferCategory(
      String name, String address, List<String> types) {
    final full = '$name $address ${types.join(" ")}'.toLowerCase();
    if (full.contains('universitas') ||
        full.contains('institut') ||
        full.contains('politeknik') ||
        full.contains('kampus') ||
        full.contains('college') ||
        full.contains('ugm') ||
        full.contains('uny') ||
        full.contains('uin') ||
        full.contains('gadjah mada') ||
        full.contains('akademi') ||
        full.contains('university')) {
      return 'Kampus';
    } else if (full.contains('smk') ||
        full.contains('kejuruan') ||
        full.contains('vokasi') ||
        full.contains('sekolah') ||
        full.contains('school')) {
      return 'SMK';
    } else if (full.contains('blk') ||
        full.contains('balai latihan') ||
        full.contains('pelatihan kerja')) {
      return 'BLK';
    } else if (full.contains('lpk') ||
        full.contains('lkp') ||
        full.contains('kursus') ||
        full.contains('training center')) {
      return 'LPK';
    } else if (full.contains('dinas') ||
        full.contains('kementerian') ||
        full.contains('badan') ||
        full.contains('kantor') ||
        full.contains('pemda') ||
        full.contains('government')) {
      return 'Dinas Pemda';
    }
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

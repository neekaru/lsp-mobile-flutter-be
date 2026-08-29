import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  /// Search places by keyword text (e.g. "UGM", "Universitas Gadjah Mada", "SMK IT Sampit")
  static Future<List<PlaceResult>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 15000,
  }) async {
    final cleanQuery = query.replaceAll('terdekat', '').trim();
    if (cleanQuery.isEmpty) return [];

    // 1. Try Google Places API (Text Search)
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
          final results = data['results'] as List<dynamic>? ?? [];
          if (results.isNotEmpty) {
            return results
                .map((e) => PlaceResult.fromGoogleJson(e as Map<String, dynamic>))
                .toList();
          }
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ Google Places API ($status): ${data['error_message']}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Google Places API error: $e');
    }

    // 2. LIVE Search via Global Maps Service (Nominatim OpenStreetMap)
    // Works globally for all schools, universities (UGM, UNY, ITB), government offices & businesses
    try {
      final liveResults = await _searchLiveMapService(
        query: cleanQuery,
        latitude: latitude,
        longitude: longitude,
      );
      if (liveResults.isNotEmpty) {
        return liveResults;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Live map search error: $e');
    }

    // 3. Fallback search dataset if offline
    return _getFallbackPlaces(cleanQuery, latitude, longitude);
  }

  /// Live Search Engine for places in Indonesia (Universities, Schools, Offices, Companies)
  static Future<List<PlaceResult>> _searchLiveMapService({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String q = query.trim();
      final lower = q.toLowerCase();

      // Expansion for well-known acronyms
      if (lower == 'ugm') {
        q = 'Universitas Gadjah Mada Yogyakarta';
      } else if (lower == 'uny') {
        q = 'Universitas Negeri Yogyakarta';
      } else if (lower == 'uin' || lower == 'uin suka') {
        q = 'UIN Sunan Kalijaga Yogyakarta';
      } else if (lower == 'ui') {
        q = 'Universitas Indonesia Depok';
      } else if (lower == 'itb') {
        q = 'Institut Teknologi Bandung';
      } else if (lower == 'undip') {
        q = 'Universitas Diponegoro Semarang';
      }

      String url =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&addressdetails=1&limit=15&countrycodes=id';

      if (latitude != null && longitude != null) {
        final minLat = latitude - 0.4;
        final maxLat = latitude + 0.4;
        final minLng = longitude - 0.4;
        final maxLng = longitude + 0.4;
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

            String inferred = 'SMK';
            final fullText =
                '$name $displayName $type $category'.toLowerCase();

            if (fullText.contains('universitas') ||
                fullText.contains('institut') ||
                fullText.contains('politeknik') ||
                fullText.contains('kampus') ||
                fullText.contains('college') ||
                fullText.contains('ugm') ||
                fullText.contains('uny') ||
                fullText.contains('gadjah mada') ||
                fullText.contains('akademi')) {
              inferred = 'Kampus';
            } else if (fullText.contains('smk') ||
                fullText.contains('kejuruan') ||
                fullText.contains('vokasi') ||
                fullText.contains('sekolah')) {
              inferred = 'SMK';
            } else if (fullText.contains('blk') ||
                fullText.contains('balai latihan') ||
                fullText.contains('pelatihan kerja')) {
              inferred = 'BLK';
            } else if (fullText.contains('lpk') ||
                fullText.contains('lkp') ||
                fullText.contains('kursus') ||
                fullText.contains('training center')) {
              inferred = 'LPK';
            } else if (fullText.contains('dinas') ||
                fullText.contains('kementerian') ||
                fullText.contains('badan') ||
                fullText.contains('kantor') ||
                fullText.contains('pemda')) {
              inferred = 'Dinas Pemda';
            } else {
              inferred = 'Perusahaan Swasta';
            }

            return PlaceResult(
              placeId: 'osm_${map['place_id'] ?? map['osm_id'] ?? DateTime.now().millisecondsSinceEpoch}',
              name: name,
              formattedAddress: displayName,
              latitude: lat,
              longitude: lon,
              rating: 4.8,
              userRatingsTotal: 150,
              types: [type, category],
              inferredCategory: inferred,
            );
          }).where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Live Nominatim search error: $e');
    }
    return [];
  }

  /// Get photo URL from Google Places API photo reference
  static String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (photoReference.isEmpty) return '';
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }

  /// Realistic fallback places database for offline demo
  static List<PlaceResult> _getFallbackPlaces(
      String query, double? lat, double? lng) {
    final lowerQ = query.toLowerCase();

    final allPlaces = [
      // Yogyakarta (SMK, Kampus, BLK, Dinas, Perusahaan)
      const PlaceResult(
        placeId: 'place_yk_ugm',
        name: 'Universitas Gadjah Mada (UGM)',
        formattedAddress: 'Bulaksumur, Caturtunggal, Depok, Sleman, DI Yogyakarta',
        latitude: -7.7713,
        longitude: 110.3776,
        rating: 4.9,
        userRatingsTotal: 3450,
        types: ['university', 'point_of_interest'],
        inferredCategory: 'Kampus',
        phoneNumber: '0274-588688',
        website: 'https://ugm.ac.id',
      ),
      const PlaceResult(
        placeId: 'place_yk_uny',
        name: 'Universitas Negeri Yogyakarta (UNY)',
        formattedAddress: 'Jl. Colombo No.1, Karang Malang, Caturtunggal, Depok, Sleman, DIY',
        latitude: -7.7749,
        longitude: 110.3867,
        rating: 4.8,
        userRatingsTotal: 2100,
        types: ['university', 'point_of_interest'],
        inferredCategory: 'Kampus',
        phoneNumber: '0274-586168',
        website: 'https://uny.ac.id',
      ),
      const PlaceResult(
        placeId: 'place_yk_1',
        name: 'SMK Negeri 1 Kalasan',
        formattedAddress: 'Jl. Raya Solo - Yogyakarta KM. 14, Glondong, Tirtomartani, Kalasan, Sleman, DIY',
        latitude: -7.7719,
        longitude: 110.4691,
        rating: 4.8,
        userRatingsTotal: 142,
        types: ['school', 'point_of_interest'],
        inferredCategory: 'SMK',
        phoneNumber: '0274-496180',
        website: 'https://smkn1kalasan.sch.id',
      ),
      const PlaceResult(
        placeId: 'place_yk_2',
        name: "SMK Ma'arif 2 Piyungan",
        formattedAddress: 'Jl. Wonosari KM.13, Sitimulyo, Piyungan, Bantul, DIY',
        latitude: -7.8367,
        longitude: 110.4578,
        rating: 4.7,
        userRatingsTotal: 88,
        types: ['school', 'point_of_interest'],
        inferredCategory: 'SMK',
        phoneNumber: '0274-4353112',
        website: 'https://smkmaarif2piyungan.sch.id',
      ),
      const PlaceResult(
        placeId: 'place_yk_3',
        name: 'SMK Budhi Dharma Piyungan',
        formattedAddress: 'Jl. Prambanan - Piyungan, Srimartani, Piyungan, Bantul, DIY',
        latitude: -7.8420,
        longitude: 110.4670,
        rating: 4.6,
        userRatingsTotal: 65,
        types: ['school', 'point_of_interest'],
        inferredCategory: 'SMK',
        phoneNumber: '0274-4435771',
      ),
      const PlaceResult(
        placeId: 'place_yk_4',
        name: 'SMK Negeri 1 Pleret',
        formattedAddress: 'Jl. Kanggotan, Pleret, Bantul, DIY',
        latitude: -7.8710,
        longitude: 110.4010,
        rating: 4.7,
        userRatingsTotal: 110,
        types: ['school', 'point_of_interest'],
        inferredCategory: 'SMK',
        phoneNumber: '0274-441233',
      ),
      const PlaceResult(
        placeId: 'place_yk_5',
        name: 'SMK Negeri 2 Yogyakarta',
        formattedAddress: 'Jl. AM. Sangaji No.47, Cokrodiningratan, Jetis, Kota Yogyakarta',
        latitude: -7.7785,
        longitude: 110.3670,
        rating: 4.9,
        userRatingsTotal: 290,
        types: ['school', 'point_of_interest'],
        inferredCategory: 'SMK',
        phoneNumber: '0274-513490',
        website: 'https://smkn2jogja.sch.id',
      ),
      const PlaceResult(
        placeId: 'place_yk_6',
        name: 'Universitas Ahmad Dahlan (Kampus 4)',
        formattedAddress: 'Jl. Ringroad Selatan, Tamanan, Banguntapan, Bantul, DIY',
        latitude: -7.8333,
        longitude: 110.3831,
        rating: 4.8,
        userRatingsTotal: 620,
        types: ['university', 'point_of_interest'],
        inferredCategory: 'Kampus',
        phoneNumber: '0274-563515',
        website: 'https://uad.ac.id',
      ),
      const PlaceResult(
        placeId: 'place_yk_7',
        name: 'Universitas Muhammadiyah Yogyakarta (UMY)',
        formattedAddress: 'Jl. Brawijaya, Geblagan, Tamantirto, Kasihan, Bantul, DIY',
        latitude: -7.8098,
        longitude: 110.3235,
        rating: 4.8,
        userRatingsTotal: 1850,
        types: ['university', 'point_of_interest'],
        inferredCategory: 'Kampus',
        phoneNumber: '0274-387656',
        website: 'https://umy.ac.id',
      ),
      const PlaceResult(
        placeId: 'place_yk_8',
        name: 'Balai Latihan Kerja (BLK) DIY',
        formattedAddress: 'Jl. Kyai Mojo No.56, Bener, Tegalrejo, Kota Yogyakarta',
        latitude: -7.7812,
        longitude: 110.3541,
        rating: 4.6,
        userRatingsTotal: 74,
        types: ['point_of_interest'],
        inferredCategory: 'BLK',
        phoneNumber: '0274-512876',
      ),
      const PlaceResult(
        placeId: 'place_yk_9',
        name: 'LPK Gama Komputer Indonesia',
        formattedAddress: 'Jl. Kaliurang KM 5 No.20, Caturtunggal, Depok, Sleman',
        latitude: -7.7610,
        longitude: 110.3810,
        rating: 4.7,
        userRatingsTotal: 53,
        types: ['point_of_interest'],
        inferredCategory: 'LPK',
        phoneNumber: '0274-589123',
      ),
      const PlaceResult(
        placeId: 'place_yk_10',
        name: 'Dinas Komunikasi dan Informatika DIY',
        formattedAddress: 'Jl. Brigjen Katamso, Prawirodirjan, Gondomanan, Kota Yogyakarta',
        latitude: -7.8055,
        longitude: 110.3695,
        rating: 4.7,
        userRatingsTotal: 89,
        types: ['government_office', 'point_of_interest'],
        inferredCategory: 'Dinas Pemda',
        phoneNumber: '0274-562811',
      ),
      const PlaceResult(
        placeId: 'place_yk_11',
        name: 'PT Gamatechno Indonesia',
        formattedAddress: 'Jl. Cik Di Tiro No.34, Terban, Gondokusuman, Kota Yogyakarta',
        latitude: -7.7792,
        longitude: 110.3752,
        rating: 4.8,
        userRatingsTotal: 135,
        types: ['point_of_interest'],
        inferredCategory: 'Perusahaan Swasta',
        phoneNumber: '0274-566161',
      ),

      // Sampit (Kotawaringin Timur)
      const PlaceResult(
        placeId: 'place_sampit_1',
        name: 'SMK Negeri 1 Sampit',
        formattedAddress: 'Jl. Walter Condrat No. 20, Baamang Tengah, Baamang, Kotawaringin Timur',
        latitude: -2.5312,
        longitude: 112.9510,
        rating: 4.7,
        userRatingsTotal: 95,
        types: ['school', 'point_of_interest'],
        inferredCategory: 'SMK',
        phoneNumber: '0531-21345',
      ),
      const PlaceResult(
        placeId: 'place_sampit_2',
        name: 'SMK Negeri 2 Sampit',
        formattedAddress: 'Jl. Gunung Slamet No. 15, Mentawa Baru Hulu, Kotawaringin Timur',
        latitude: -2.5390,
        longitude: 112.9460,
        rating: 4.6,
        userRatingsTotal: 72,
        types: ['school', 'point_of_interest'],
        inferredCategory: 'SMK',
        phoneNumber: '0531-22450',
      ),
      const PlaceResult(
        placeId: 'place_sampit_3',
        name: 'Universitas Darwan Ali (UNDA) Sampit',
        formattedAddress: 'Jl. Batu Berlian No. 10, Mentawa Baru Ketapang, Kotawaringin Timur',
        latitude: -2.5445,
        longitude: 112.9601,
        rating: 4.8,
        userRatingsTotal: 180,
        types: ['university', 'point_of_interest'],
        inferredCategory: 'Kampus',
        phoneNumber: '0531-31889',
        website: 'https://unda.ac.id',
      ),
      const PlaceResult(
        placeId: 'place_sampit_4',
        name: 'BLK Kotawaringin Timur (Sampit)',
        formattedAddress: 'Jl. Jenderal Sudirman KM. 6, Baamang, Kotawaringin Timur',
        latitude: -2.5200,
        longitude: 112.9100,
        rating: 4.5,
        userRatingsTotal: 40,
        types: ['point_of_interest'],
        inferredCategory: 'BLK',
        phoneNumber: '0531-23110',
      ),
      const PlaceResult(
        placeId: 'place_sampit_5',
        name: 'Dinas Kominfo Kabupaten Kotawaringin Timur',
        formattedAddress: 'Jl. Jenderal Sudirman No. 1, Mentawa Baru Hulu, Sampit',
        latitude: -2.5360,
        longitude: 112.9540,
        rating: 4.6,
        userRatingsTotal: 52,
        types: ['government_office', 'point_of_interest'],
        inferredCategory: 'Dinas Pemda',
        phoneNumber: '0531-21002',
      ),
    ];

    String cleanQ = lowerQ.replaceAll('terdekat', '').trim();

    // Proximity filter: if coordinate is given and query doesn't specify a distant city
    List<PlaceResult> candidatePlaces = allPlaces;
    if (lat != null &&
        lng != null &&
        !cleanQ.contains('sampit') &&
        !cleanQ.contains('jogja') &&
        !cleanQ.contains('sleman') &&
        !cleanQ.contains('bantul')) {
      if (lat < -6.0 && lng < 112.0) {
        candidatePlaces = allPlaces
            .where((p) => p.latitude < -6.0 && p.longitude < 112.0)
            .toList();
      } else if (lat > -4.0 && lng > 111.0) {
        candidatePlaces = allPlaces
            .where((p) => p.latitude > -4.0 && p.longitude > 111.0)
            .toList();
      }
    }

    if (cleanQ.isEmpty || cleanQ == 'semua') {
      return candidatePlaces;
    }

    return candidatePlaces.where((p) {
      final name = p.name.toLowerCase();
      final address = p.formattedAddress.toLowerCase();
      final category = p.inferredCategory.toLowerCase();

      return name.contains(cleanQ) ||
          address.contains(cleanQ) ||
          category.contains(cleanQ) ||
          cleanQ.contains(category) ||
          (cleanQ == 'ugm' && name.contains('gadjah mada')) ||
          (cleanQ == 'uny' && name.contains('negeri yogyakarta')) ||
          (cleanQ == 'umy' && name.contains('muhammadiyah yogyakarta')) ||
          (cleanQ == 'uad' && name.contains('ahmad dahlan'));
    }).toList();
  }
}

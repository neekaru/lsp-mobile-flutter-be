class LeadModel {
  final String id;
  final int idAsesor;
  final String namaInstitusi;
  final String leadKategori; // SMK, LPK, LKP, Kampus, BLK, Dinas Pemda, Perusahaan Swasta
  final String leadLocation;
  final String kabupaten;
  final String provinsi;
  final double latitude;
  final double longitude;
  final String leadDescription;
  final String leadPotensi;
  final int estimasiSiswa;
  final List<String> jurusanList;
  final String leadStatus; // lead, prospek, interest, sales
  final String telepon;
  final String email;
  final String picName;
  final String catatan;
  final String placeId;
  final double rating;
  final int userRatingsTotal;
  final String photoReference;
  final String website;
  final bool isAiGenerated;
  final DateTime updatedAt;

  const LeadModel({
    required this.id,
    required this.idAsesor,
    required this.namaInstitusi,
    required this.leadKategori,
    required this.leadLocation,
    this.kabupaten = '',
    this.provinsi = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.leadDescription = '',
    this.leadPotensi = '',
    this.estimasiSiswa = 0,
    this.jurusanList = const [],
    this.leadStatus = 'lead',
    this.telepon = '',
    this.email = '',
    this.picName = '',
    this.catatan = '',
    this.placeId = '',
    this.rating = 0.0,
    this.userRatingsTotal = 0,
    this.photoReference = '',
    this.website = '',
    this.isAiGenerated = false,
    required this.updatedAt,
  });

  LeadModel copyWith({
    String? id,
    int? idAsesor,
    String? namaInstitusi,
    String? leadKategori,
    String? leadLocation,
    String? kabupaten,
    String? provinsi,
    double? latitude,
    double? longitude,
    String? leadDescription,
    String? leadPotensi,
    int? estimasiSiswa,
    List<String>? jurusanList,
    String? leadStatus,
    String? telepon,
    String? email,
    String? picName,
    String? catatan,
    String? placeId,
    double? rating,
    int? userRatingsTotal,
    String? photoReference,
    String? website,
    bool? isAiGenerated,
    DateTime? updatedAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      idAsesor: idAsesor ?? this.idAsesor,
      namaInstitusi: namaInstitusi ?? this.namaInstitusi,
      leadKategori: leadKategori ?? this.leadKategori,
      leadLocation: leadLocation ?? this.leadLocation,
      kabupaten: kabupaten ?? this.kabupaten,
      provinsi: provinsi ?? this.provinsi,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      leadDescription: leadDescription ?? this.leadDescription,
      leadPotensi: leadPotensi ?? this.leadPotensi,
      estimasiSiswa: estimasiSiswa ?? this.estimasiSiswa,
      jurusanList: jurusanList ?? this.jurusanList,
      leadStatus: leadStatus ?? this.leadStatus,
      telepon: telepon ?? this.telepon,
      email: email ?? this.email,
      picName: picName ?? this.picName,
      catatan: catatan ?? this.catatan,
      placeId: placeId ?? this.placeId,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      photoReference: photoReference ?? this.photoReference,
      website: website ?? this.website,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_asesor': idAsesor,
      'nama_institusi': namaInstitusi,
      'lead_kategori': leadKategori,
      'lead_location': leadLocation,
      'kabupaten': kabupaten,
      'provinsi': provinsi,
      'latitude': latitude,
      'longitude': longitude,
      'lead_description': leadDescription,
      'lead_potensi': leadPotensi,
      'estimasi_siswa': estimasiSiswa,
      'jurusan_list': jurusanList,
      'lead_status': leadStatus,
      'telepon': telepon,
      'email': email,
      'pic_name': picName,
      'catatan': catatan,
      'place_id': placeId,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'photo_reference': photoReference,
      'website': website,
      'is_ai_generated': isAiGenerated,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    List<String> jurusans = [];
    if (json['jurusan_list'] is List) {
      jurusans = (json['jurusan_list'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return LeadModel(
      id: json['id']?.toString() ?? '',
      idAsesor: (json['id_asesor'] as num?)?.toInt() ?? 0,
      namaInstitusi: json['nama_institusi']?.toString() ?? '',
      leadKategori: json['lead_kategori']?.toString() ?? 'SMK',
      leadLocation: json['lead_location']?.toString() ?? '',
      kabupaten: json['kabupaten']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      leadDescription: json['lead_description']?.toString() ?? '',
      leadPotensi: json['lead_potensi']?.toString() ?? '',
      estimasiSiswa: (json['estimasi_siswa'] as num?)?.toInt() ?? 0,
      jurusanList: jurusans,
      leadStatus: json['lead_status']?.toString() ?? 'lead',
      telepon: json['telepon']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      picName: json['pic_name']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
      placeId: json['place_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt() ?? 0,
      photoReference: json['photo_reference']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      isAiGenerated: json['is_ai_generated'] == true,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Model untuk hasil pencarian Google Places API sebelum disimpan sebagai Lead
class PlaceResult {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final double rating;
  final int userRatingsTotal;
  final String photoReference;
  final List<String> types;
  final String inferredCategory; // SMK, LPK, LKP, Kampus, BLK, Dinas Pemda, Perusahaan Swasta
  final String phoneNumber;
  final String website;

  const PlaceResult({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    this.userRatingsTotal = 0,
    this.photoReference = '',
    this.types = const [],
    this.inferredCategory = 'SMK',
    this.phoneNumber = '',
    this.website = '',
  });

  factory PlaceResult.fromGoogleJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (location['lng'] as num?)?.toDouble() ?? 0.0;

    final photos = json['photos'] as List<dynamic>?;
    String photoRef = '';
    if (photos != null && photos.isNotEmpty) {
      photoRef = photos[0]['photo_reference']?.toString() ?? '';
    }

    final rawTypes = json['types'] as List<dynamic>? ?? [];
    final typesList = rawTypes.map((e) => e.toString()).toList();

    final name = json['name']?.toString() ?? '';
    final category = _inferCategoryFromNameAndTypes(name, typesList);

    return PlaceResult(
      placeId: json['place_id']?.toString() ?? '',
      name: name,
      formattedAddress: json['formatted_address']?.toString() ??
          json['vicinity']?.toString() ??
          '',
      latitude: lat,
      longitude: lng,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt() ?? 0,
      photoReference: photoRef,
      types: typesList,
      inferredCategory: category,
      phoneNumber: json['formatted_phone_number']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
    );
  }

  static String _inferCategoryFromNameAndTypes(
      String name, List<String> types) {
    final lower = name.toLowerCase();
    if (lower.contains('smk') ||
        lower.contains('kejuruan') ||
        lower.contains('vokasi')) {
      return 'SMK';
    }
    if (lower.contains('kampus') ||
        lower.contains('universitas') ||
        lower.contains('politeknik') ||
        lower.contains('institut') ||
        lower.contains('stmik') ||
        lower.contains('akademi')) {
      return 'Kampus';
    }
    if (lower.contains('blk') ||
        lower.contains('balai latihan kerja') ||
        lower.contains('bpptk') ||
        lower.contains('upt')) {
      return 'BLK';
    }
    if (lower.contains('lpk') || lower.contains('pelatihan kerja')) {
      return 'LPK';
    }
    if (lower.contains('lkp') || lower.contains('kursus')) {
      return 'LKP';
    }
    if (lower.contains('dinas') ||
        lower.contains('badan') ||
        lower.contains('kementerian') ||
        lower.contains('kominfo') ||
        lower.contains('pemda')) {
      return 'Dinas Pemda';
    }
    if (lower.contains('pt ') ||
        lower.contains('cv ') ||
        lower.contains('pt.') ||
        lower.contains('software') ||
        lower.contains('techno') ||
        lower.contains('tech') ||
        lower.contains('digital') ||
        lower.contains('persada') ||
        lower.contains('solusi')) {
      return 'Perusahaan Swasta';
    }
    return 'SMK';
  }

  LeadModel toLeadModel(int idAsesor) {
    return LeadModel(
      id: 'lead_${DateTime.now().millisecondsSinceEpoch}_$placeId',
      idAsesor: idAsesor,
      namaInstitusi: name,
      leadKategori: inferredCategory,
      leadLocation: formattedAddress,
      latitude: latitude,
      longitude: longitude,
      leadDescription: 'Institusi $inferredCategory potensial untuk program sertifikasi profesi BNSP LSP.',
      leadStatus: 'lead',
      telepon: phoneNumber,
      website: website,
      placeId: placeId,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      photoReference: photoReference,
      updatedAt: DateTime.now(),
    );
  }
}



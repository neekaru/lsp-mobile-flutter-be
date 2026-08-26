import 'dart:convert';

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
      isAiGenerated: json['is_ai_generated'] == true,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}


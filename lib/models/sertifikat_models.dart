// ============================================================================
// Sertifikat Models
// ============================================================================

class SertifikatItem {
  final int id;
  final String skema;
  final String pemegang;
  final String nomorSertifikat;
  final String tanggalTerbit;
  final String tanggalBerlaku;
  final String status; // 'aktif', 'kadaluarsa', 'akan_kadaluarsa'
  final String kategori; // 'Digital Marketing', 'Informatika', dll
  final String? institusi;

  const SertifikatItem({
    required this.id,
    required this.skema,
    required this.pemegang,
    required this.nomorSertifikat,
    required this.tanggalTerbit,
    required this.tanggalBerlaku,
    required this.status,
    required this.kategori,
    this.institusi,
  });

  factory SertifikatItem.fromJson(Map<String, dynamic> json) {
    return SertifikatItem(
      id: json['id'] ?? 0,
      skema: json['skema'] ?? '',
      pemegang: json['pemegang'] ?? '',
      nomorSertifikat: json['nomor_sertifikat'] ?? '',
      tanggalTerbit: json['tanggal_terbit'] ?? '',
      tanggalBerlaku: json['tanggal_berlaku'] ?? '',
      status: json['status'] ?? 'aktif',
      kategori: json['kategori'] ?? '',
      institusi: json['institusi'],
    );
  }
}

class SertifikatRingkasan {
  final int totalPemegangSertifikat;
  final double persentasePertumbuhan;
  final int totalSkema;
  final double persentaseSkema;
  final int totalSertifikatYangDiterbitkan;
  final double persentaseSertifikat;

  const SertifikatRingkasan({
    required this.totalPemegangSertifikat,
    required this.persentasePertumbuhan,
    required this.totalSkema,
    required this.persentaseSkema,
    required this.totalSertifikatYangDiterbitkan,
    required this.persentaseSertifikat,
  });

  factory SertifikatRingkasan.fallback() {
    return const SertifikatRingkasan(
      totalPemegangSertifikat: 3980,
      persentasePertumbuhan: 15.7,
      totalSkema: 2000,
      persentaseSkema: 16.8,
      totalSertifikatYangDiterbitkan: 8000,
      persentaseSertifikat: 18.7,
    );
  }
}

class SertifikatDistribusi {
  final int idSkema;
  final String kodeSkema;
  final String skema;
  final String kategori;
  final int totalPemegang;
  final double persentase;
  final String color;

  const SertifikatDistribusi({
    required this.idSkema,
    required this.kodeSkema,
    required this.skema,
    required this.kategori,
    required this.totalPemegang,
    required this.persentase,
    required this.color,
  });

  factory SertifikatDistribusi.fromJson(Map<String, dynamic> json, {double? persentase, String? color}) {
    return SertifikatDistribusi(
      idSkema: json['id_skema'] ?? 0,
      kodeSkema: json['kode_skema'] ?? '',
      skema: json['skema'] ?? '',
      kategori: json['kategori'] ?? '',
      totalPemegang: json['total_pemegang'] ?? 0,
      persentase: persentase ?? 0.0,
      color: color ?? '5B9FD8',
    );
  }
}

class SertifikatApiResponse {
  final List<SertifikatDistribusi> data;
  final SertifikatMeta meta;

  const SertifikatApiResponse({
    required this.data,
    required this.meta,
  });

  factory SertifikatApiResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    final meta = SertifikatMeta.fromJson(json['meta'] ?? {});
    
    final colors = [
      '0D47A1', // Dark Blue
      '1976D2', // Bright Blue
      '42A5F5', // Mid Blue
      '64B5F6', // Light Blue
      '90CAF9', // Very Light Blue
      'BBDEFB', // Extra Light Blue
      '5B9FD8', // Default Blue
    ];
    
    // Calculate total from current data list (not from meta)
    // This ensures percentages add up to 100% for the displayed items
    int totalFromData = 0;
    for (var item in dataList) {
      totalFromData += (item['total_pemegang'] ?? 0) as int;
    }
    
    final List<SertifikatDistribusi> distribusiList = [];
    for (int i = 0; i < dataList.length; i++) {
      final item = dataList[i];
      final totalPemegang = item['total_pemegang'] ?? 0;
      // Calculate percentage based on displayed data total
      final persentase = totalFromData > 0 ? (totalPemegang / totalFromData * 100) : 0.0;
      final color = colors[i % colors.length];
      
      distribusiList.add(SertifikatDistribusi.fromJson(
        item,
        persentase: persentase,
        color: color,
      ));
    }
    
    return SertifikatApiResponse(
      data: distribusiList,
      meta: meta,
    );
  }
}

class SertifikatMeta {
  final int totalSkema;
  final int totalPemegangSertifikat;
  final int? tahunFilter;
  final int limit;
  final String? periode;
  final String? tanggalUpdate;

  const SertifikatMeta({
    required this.totalSkema,
    required this.totalPemegangSertifikat,
    this.tahunFilter,
    required this.limit,
    this.periode,
    this.tanggalUpdate,
  });

  factory SertifikatMeta.fromJson(Map<String, dynamic> json) {
    return SertifikatMeta(
      totalSkema: json['total_skema'] ?? 0,
      totalPemegangSertifikat: json['total_pemegang_sertifikat'] ?? 0,
      tahunFilter: json['tahun_filter'],
      limit: json['limit'] ?? 10,
      periode: json['periode'],
      tanggalUpdate: json['tanggal_update'],
    );
  }
}

// ============================================================================
// Sertifikat Summary Models
// ============================================================================

class SertifikatSummary {
  final int totalPemegangSertifikat;
  final int totalSkema;
  final TopSkema? topSkema;
  final SertifikatTrends? trends;
  final String periode;
  final String comparisonPeriod;
  final String tanggalUpdate;

  const SertifikatSummary({
    required this.totalPemegangSertifikat,
    required this.totalSkema,
    this.topSkema,
    this.trends,
    required this.periode,
    required this.comparisonPeriod,
    required this.tanggalUpdate,
  });

  factory SertifikatSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    
    // Check if top_skema has meaningful data
    final topSkemaData = data['top_skema'];
    final hasTopSkema = topSkemaData != null && 
                        topSkemaData is Map && 
                        topSkemaData.isNotEmpty &&
                        (topSkemaData['id_skema'] != null || topSkemaData['skema'] != null);
    
    // Check if trends has meaningful data
    final trendsData = data['trends'];
    final hasTrends = trendsData != null && 
                      trendsData is Map && 
                      trendsData.isNotEmpty;
    
    return SertifikatSummary(
      totalPemegangSertifikat: data['total_pemegang_sertifikat'] ?? 0,
      totalSkema: data['total_skema'] ?? 0,
      topSkema: hasTopSkema ? TopSkema.fromJson(Map<String, dynamic>.from(topSkemaData)) : null,
      trends: hasTrends ? SertifikatTrends.fromJson(Map<String, dynamic>.from(trendsData)) : null,
      periode: meta['periode'] ?? '',
      comparisonPeriod: meta['comparison_period'] ?? '',
      tanggalUpdate: meta['tanggal_update'] ?? '',
    );
  }

  factory SertifikatSummary.fallback() {
    return const SertifikatSummary(
      totalPemegangSertifikat: 0,
      totalSkema: 0,
      topSkema: null,
      trends: null,
      periode: 'N/A',
      comparisonPeriod: 'N/A',
      tanggalUpdate: '',
    );
  }
}

class TopSkema {
  final int idSkema;
  final String skema;
  final int totalPemegang;

  const TopSkema({
    required this.idSkema,
    required this.skema,
    required this.totalPemegang,
  });

  factory TopSkema.fromJson(Map<String, dynamic> json) {
    return TopSkema(
      idSkema: json['id_skema'] ?? 0,
      skema: json['skema'] ?? '',
      totalPemegang: json['total_pemegang'] ?? 0,
    );
  }

  factory TopSkema.fallback() {
    return const TopSkema(
      idSkema: 0,
      skema: 'N/A',
      totalPemegang: 0,
    );
  }
}

class SertifikatTrends {
  final TrendData pemegangSertifikat;
  final TrendData skema;

  const SertifikatTrends({
    required this.pemegangSertifikat,
    required this.skema,
  });

  factory SertifikatTrends.fromJson(Map<String, dynamic> json) {
    return SertifikatTrends(
      pemegangSertifikat: TrendData.fromJson(json['pemegang_sertifikat'] ?? {}),
      skema: TrendData.fromJson(json['skema'] ?? {}),
    );
  }

  factory SertifikatTrends.fallback() {
    return SertifikatTrends(
      pemegangSertifikat: TrendData.fallback(),
      skema: TrendData.fallback(),
    );
  }
}

class TrendData {
  final double percentage;
  final String direction;
  final String formatted;

  const TrendData({
    required this.percentage,
    required this.direction,
    required this.formatted,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      direction: json['direction'] ?? 'stable',
      formatted: json['formatted'] ?? '+0.0%',
    );
  }

  factory TrendData.fallback() {
    return const TrendData(
      percentage: 0.0,
      direction: 'stable',
      formatted: '+0.0%',
    );
  }
}

// ============================================================================
// Skema Sertifikasi Models (matches backend /api/sertifikat/skema)
// ============================================================================

class SkemaSertifikatListItem {
  final int id;
  final String kodeSkema;
  final String title;
  final String jenjang;
  final String kategori;
  final String bidang;
  final String description;
  final int unitsCount;
  final String price;
  final List<String> tags;
  final String status;
  final bool isOpen;

  const SkemaSertifikatListItem({
    required this.id,
    required this.kodeSkema,
    required this.title,
    required this.jenjang,
    required this.kategori,
    required this.bidang,
    required this.description,
    required this.unitsCount,
    required this.price,
    required this.tags,
    required this.status,
    required this.isOpen,
  });

  factory SkemaSertifikatListItem.fromJson(Map<String, dynamic> json) {
    return SkemaSertifikatListItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kodeSkema: json['kode_skema'] as String? ?? '',
      title: json['title'] as String? ?? '',
      jenjang: json['jenjang'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      bidang: json['bidang'] as String? ?? '',
      description: json['description'] as String? ?? '',
      unitsCount: (json['units_count'] as num?)?.toInt() ?? 0,
      price: json['price'] as String? ?? 'Rp. 0',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((t) => t.toString())
          .toList(),
      status: json['status'] as String? ?? 'Pendaftaran Ditutup',
      isOpen: json['isOpen'] as bool? ?? false,
    );
  }
}

class SkemaSertifikatMeta {
  final int total;
  final int page;
  final int lastPage;
  final int perPage;

  const SkemaSertifikatMeta({
    required this.total,
    required this.page,
    required this.lastPage,
    required this.perPage,
  });

  factory SkemaSertifikatMeta.fromJson(Map<String, dynamic> json) {
    return SkemaSertifikatMeta(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 6,
    );
  }
}

class SkemaSertifikatListResponse {
  final List<SkemaSertifikatListItem> data;
  final SkemaSertifikatMeta meta;

  const SkemaSertifikatListResponse({
    required this.data,
    required this.meta,
  });

  factory SkemaSertifikatListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => SkemaSertifikatListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SkemaSertifikatListResponse(
      data: list,
      meta: SkemaSertifikatMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SkemaUnitKompetensiItem {
  final String code;
  final String title;
  final String subtitle;

  const SkemaUnitKompetensiItem({
    required this.code,
    required this.title,
    required this.subtitle,
  });

  factory SkemaUnitKompetensiItem.fromJson(Map<String, dynamic> json) {
    return SkemaUnitKompetensiItem(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }
}

class SkemaSertifikatDetailResponse {
  final int id;
  final String kodeSkema;
  final String title;
  final String jenjang;
  final String kategori;
  final String bidang;
  final String price;
  final String description;
  final String linkDownload;
  final List<SkemaUnitKompetensiItem> unitList;
  final List<String> persyaratan;

  const SkemaSertifikatDetailResponse({
    required this.id,
    required this.kodeSkema,
    required this.title,
    required this.jenjang,
    required this.kategori,
    required this.bidang,
    required this.price,
    required this.description,
    required this.linkDownload,
    required this.unitList,
    required this.persyaratan,
  });

  factory SkemaSertifikatDetailResponse.fromJson(Map<String, dynamic> json) {
    final units = (json['unitList'] as List<dynamic>? ?? [])
        .map((e) => SkemaUnitKompetensiItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final syarat = (json['persyaratan'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return SkemaSertifikatDetailResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kodeSkema: json['kode_skema'] as String? ?? '',
      title: json['title'] as String? ?? '',
      jenjang: json['jenjang'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      bidang: json['bidang'] as String? ?? '',
      price: json['price'] as String? ?? 'Rp. 0',
      description: json['description'] as String? ?? '',
      linkDownload: json['link_download'] as String? ?? '',
      unitList: units,
      persyaratan: syarat,
    );
  }
}

class SertifikatValidationResult {
  final bool valid;
  final String? nama;
  final String? noSertifikat;
  final String? noRegistrasi;
  final String? tanggalTerbit;
  final String? status;
  final String? skema;
  final String? masaBerlaku;
  final String? message;

  const SertifikatValidationResult({
    required this.valid,
    this.nama,
    this.noSertifikat,
    this.noRegistrasi,
    this.tanggalTerbit,
    this.status,
    this.skema,
    this.masaBerlaku,
    this.message,
  });

  factory SertifikatValidationResult.fromJson(Map<String, dynamic> json) {
    return SertifikatValidationResult(
      valid: json['valid'] ?? false,
      nama: json['nama'],
      noSertifikat: json['no_sertifikat'],
      noRegistrasi: json['no_registrasi'],
      tanggalTerbit: json['tanggal_terbit'],
      status: json['status'],
      skema: json['skema'],
      masaBerlaku: json['masa_berlaku'],
      message: json['message'],
    );
  }
}


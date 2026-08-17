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

/// Bidang item for filter chips — fetched from GET /api/sertifikat/skema/bidang
class SkemaBidangItem {
  final String value;
  final String label;

  const SkemaBidangItem({required this.value, required this.label});

  factory SkemaBidangItem.fromJson(Map<String, dynamic> json) {
    return SkemaBidangItem(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class SkemaBidangListResponse {
  final List<SkemaBidangItem> data;

  const SkemaBidangListResponse({required this.data});

  factory SkemaBidangListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => SkemaBidangItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SkemaBidangListResponse(data: list);
  }
}

class SkemaSertifikatListResponse {
  final List<SkemaSertifikatListItem> data;
  final SkemaSertifikatMeta meta;

  const SkemaSertifikatListResponse({required this.data, required this.meta});

  factory SkemaSertifikatListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => SkemaSertifikatListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SkemaSertifikatListResponse(
      data: list,
      meta: SkemaSertifikatMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class SkemaUnitKompetensiItem {
  final String code;
  final String title;
  final String subtitle;
  final String deskripsi;
  final List<String> elemen;
  final List<String> kriteria;

  const SkemaUnitKompetensiItem({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.deskripsi,
    required this.elemen,
    required this.kriteria,
  });

  factory SkemaUnitKompetensiItem.fromJson(Map<String, dynamic> json) {
    final elements = (json['elemen'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final criteria = (json['kriteria'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return SkemaUnitKompetensiItem(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      elemen: elements,
      kriteria: criteria,
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
  final bool isAlreadyRegistered;

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
    this.isAlreadyRegistered = false,
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
      isAlreadyRegistered: json['is_already_registered'] as bool? ?? false,
    );
  }
}

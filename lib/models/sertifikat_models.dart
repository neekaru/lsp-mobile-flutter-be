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
  final String nomorRegistrasi;
  final String nomorBlanko;
  final String nomorSeri;
  final String tempatUji;
  final String namaAsesor;

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
    this.nomorRegistrasi = '',
    this.nomorBlanko = '',
    this.nomorSeri = '',
    this.tempatUji = '',
    this.namaAsesor = '',
  });

  factory SertifikatItem.fromJson(Map<String, dynamic> json) {
    final skemaMap = json['skema'] is Map<String, dynamic> ? json['skema'] : {};
    final asesorMap = json['asesor'] is Map<String, dynamic>
        ? json['asesor']
        : {};

    return SertifikatItem(
      id: json['id'] ?? 0,
      skema: skemaMap['nama_skema'] ?? json['skema'] ?? '',
      pemegang: json['pemegang'] ?? '',
      nomorSertifikat: json['no_sertifikat'] ?? json['nomor_sertifikat'] ?? '',
      tanggalTerbit: json['tanggal_terbit'] ?? '',
      tanggalBerlaku:
          json['tanggal_kadaluarsa'] ?? json['tanggal_berlaku'] ?? '',
      status: json['status_sertifikat'] ?? json['status'] ?? 'aktif',
      kategori: skemaMap['kategori'] ?? json['kategori'] ?? '',
      institusi: json['institusi'],
      nomorRegistrasi: json['nomor_registrasi'] ?? '',
      nomorBlanko: json['nomor_blanko'] ?? '',
      nomorSeri: json['nomor_seri'] ?? '',
      tempatUji: json['tempat_uji'] ?? '',
      namaAsesor: asesorMap['nama'] ?? json['nama_asesor'] ?? '',
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
      totalPemegangSertifikat: 0,
      persentasePertumbuhan: 0,
      totalSkema: 0,
      persentaseSkema: 0,
      totalSertifikatYangDiterbitkan: 0,
      persentaseSertifikat: 0,
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

  factory SertifikatDistribusi.fromJson(
    Map<String, dynamic> json, {
    double? persentase,
    String? color,
  }) {
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

  const SertifikatApiResponse({required this.data, required this.meta});

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
      final persentase = totalFromData > 0
          ? (totalPemegang / totalFromData * 100)
          : 0.0;
      final color = colors[i % colors.length];

      distribusiList.add(
        SertifikatDistribusi.fromJson(
          item,
          persentase: persentase,
          color: color,
        ),
      );
    }

    return SertifikatApiResponse(data: distribusiList, meta: meta);
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
    final hasTopSkema =
        topSkemaData != null &&
        topSkemaData is Map &&
        topSkemaData.isNotEmpty &&
        (topSkemaData['id_skema'] != null || topSkemaData['skema'] != null);

    // Check if trends has meaningful data
    final trendsData = data['trends'];
    final hasTrends =
        trendsData != null && trendsData is Map && trendsData.isNotEmpty;

    return SertifikatSummary(
      totalPemegangSertifikat: data['total_pemegang_sertifikat'] ?? 0,
      totalSkema: data['total_skema'] ?? 0,
      topSkema: hasTopSkema
          ? TopSkema.fromJson(Map<String, dynamic>.from(topSkemaData))
          : null,
      trends: hasTrends
          ? SertifikatTrends.fromJson(Map<String, dynamic>.from(trendsData))
          : null,
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
    return const TopSkema(idSkema: 0, skema: 'N/A', totalPemegang: 0);
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

class SertifikatValidationResult {
  final bool valid;
  final String? nama;
  final String? noSertifikat;
  final String? noRegistrasi;
  final String? noSeri;
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
    this.noSeri,
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
      noSeri: json['no_seri'],
      tanggalTerbit: json['tanggal_terbit'],
      status: json['status'],
      skema: json['skema'],
      masaBerlaku: json['masa_berlaku'],
      message: json['message'],
    );
  }
}

// ============================================================================
// Pra-Asesmen Models
// ============================================================================

class PraAsesmenInfo {
  final int skemaId;
  final String namaSkema;
  final String kodeSkema;
  final String tanggalAsesmen;
  final String tuk;
  final String namaAsesor;

  const PraAsesmenInfo({
    required this.skemaId,
    required this.namaSkema,
    required this.kodeSkema,
    required this.tanggalAsesmen,
    required this.tuk,
    required this.namaAsesor,
  });

  factory PraAsesmenInfo.fromJson(Map<String, dynamic> json) {
    return PraAsesmenInfo(
      skemaId: json['skema_id'] ?? 0,
      namaSkema: json['nama_skema'] ?? '',
      kodeSkema: json['kode_skema'] ?? '',
      tanggalAsesmen: json['tanggal_asesmen'] ?? '',
      tuk: json['tuk'] ?? '',
      // UI shows a single assessor; API may return comma-separated list.
      namaAsesor: _firstAsesorName(json['nama_asesor']?.toString() ?? ''),
    );
  }

  /// Picks the first non-empty assessor name from a comma-separated list.
  static String _firstAsesorName(String raw) {
    for (final part in raw.split(',')) {
      final name = part.trim();
      if (name.isEmpty) continue;
      if (name.toLowerCase() == 'belum ada') continue;
      return name;
    }
    return '';
  }

  factory PraAsesmenInfo.fallback(int skemaId, String title, String kodeSkema) {
    return PraAsesmenInfo(
      skemaId: skemaId,
      namaSkema: title,
      kodeSkema: kodeSkema,
      tanggalAsesmen: '',
      tuk: '',
      namaAsesor: '',
    );
  }
}

class PraAsesmenKompetensi {
  final int skemaId;
  final String namaSkema;
  final List<UnitKompetensi> unitKompetensi;

  const PraAsesmenKompetensi({
    required this.skemaId,
    required this.namaSkema,
    required this.unitKompetensi,
  });

  factory PraAsesmenKompetensi.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['unit_kompetensi'] ?? [];
    return PraAsesmenKompetensi(
      skemaId: _asInt(json['skema_id']),
      namaSkema: json['nama_skema']?.toString() ?? '',
      unitKompetensi: list
          .map(
            (item) => UnitKompetensi.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  factory PraAsesmenKompetensi.fallback(int skemaId, String title) {
    return PraAsesmenKompetensi(
      skemaId: skemaId,
      namaSkema: title,
      unitKompetensi: const [],
    );
  }
}

class UnitKompetensi {
  final String kodeUnit;
  final String judulUnit;
  final List<ElemenKompetensi> elemen;

  const UnitKompetensi({
    required this.kodeUnit,
    required this.judulUnit,
    required this.elemen,
  });

  factory UnitKompetensi.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['elemen'] ?? [];
    return UnitKompetensi(
      kodeUnit: json['kode_unit']?.toString() ?? '',
      judulUnit: json['judul_unit']?.toString() ?? '',
      elemen: list
          .map(
            (item) => ElemenKompetensi.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

/// GET /api/ujian/skema/:id/soal
class UjianSkemaSoal {
  final int skemaId;
  final String namaSkema;
  final String kodeSkema;
  final int examId;
  final String namaExam;
  final int durasiMenit;
  final int totalSoal;
  final List<UjianSoalItem> soal;

  const UjianSkemaSoal({
    required this.skemaId,
    required this.namaSkema,
    required this.kodeSkema,
    required this.examId,
    required this.namaExam,
    required this.durasiMenit,
    required this.totalSoal,
    required this.soal,
  });

  factory UjianSkemaSoal.fromJson(Map<String, dynamic> json) {
    final list = json['soal'] as List? ?? [];
    return UjianSkemaSoal(
      skemaId: _asInt(json['skema_id']),
      namaSkema: json['nama_skema']?.toString() ?? '',
      kodeSkema: json['kode_skema']?.toString() ?? '',
      examId: _asInt(json['exam_id']),
      namaExam: json['nama_exam']?.toString() ?? '',
      durasiMenit: _asInt(json['durasi_menit']),
      totalSoal: _asInt(json['total_soal']),
      soal: list
          .map((e) =>
              UjianSoalItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class UjianSoalItem {
  final int id;
  final String pertanyaan;
  final String jenisSoal;
  final String tipeSoal;
  final String jawabanA;
  final String jawabanB;
  final String jawabanC;
  final String jawabanD;
  final String jawabanE;
  final String jawabanBenar;
  final int urutan;

  const UjianSoalItem({
    required this.id,
    required this.pertanyaan,
    this.jenisSoal = '',
    this.tipeSoal = '',
    this.jawabanA = '',
    this.jawabanB = '',
    this.jawabanC = '',
    this.jawabanD = '',
    this.jawabanE = '',
    this.jawabanBenar = '',
    this.urutan = 0,
  });

  factory UjianSoalItem.fromJson(Map<String, dynamic> json) {
    return UjianSoalItem(
      id: _asInt(json['id']),
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      jenisSoal: json['jenis_soal']?.toString() ?? '',
      tipeSoal: json['tipe_soal']?.toString() ?? '',
      jawabanA: json['jawaban_a']?.toString() ?? '',
      jawabanB: json['jawaban_b']?.toString() ?? '',
      jawabanC: json['jawaban_c']?.toString() ?? '',
      jawabanD: json['jawaban_d']?.toString() ?? '',
      jawabanE: json['jawaban_e']?.toString() ?? '',
      jawabanBenar: json['jawaban_benar']?.toString() ?? '',
      urutan: _asInt(json['urutan']),
    );
  }

  /// UI map: options as A/B/C/D/E labels + letters for submit.
  Map<String, dynamic> toQuizMap() {
    final opts = <String>[];
    final letters = <String>[];
    void add(String letter, String text) {
      final t = text.trim();
      if (t.isEmpty) return;
      opts.add('$letter. $t');
      letters.add(letter);
    }

    add('A', jawabanA);
    add('B', jawabanB);
    add('C', jawabanC);
    add('D', jawabanD);
    add('E', jawabanE);

    return {
      'id_soal': id,
      'category': jenisSoal.isNotEmpty
          ? jenisSoal
          : (tipeSoal.isNotEmpty ? tipeSoal : 'Soal'),
      'question': pertanyaan,
      'options': opts,
      'option_letters': letters,
      'correct_letter': jawabanBenar.trim().toUpperCase(),
    };
  }
}

class KukItem {
  final int idKuk;
  final int idElemen;
  final String pertanyaanKuk;

  const KukItem({
    required this.idKuk,
    required this.idElemen,
    required this.pertanyaanKuk,
  });

  factory KukItem.fromJson(Map<String, dynamic> json) {
    return KukItem(
      idKuk: _asInt(json['id_kuk']),
      idElemen: _asInt(json['id_elemen']),
      pertanyaanKuk: json['pertanyaan_kuk']?.toString() ?? '',
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

class ElemenKompetensi {
  final int idElemen;
  final String elemenKompetensi;
  final String pertanyaanKuk;
  final List<KukItem> kuk;

  const ElemenKompetensi({
    required this.idElemen,
    this.elemenKompetensi = '',
    required this.pertanyaanKuk,
    this.kuk = const [],
  });

  factory ElemenKompetensi.fromJson(Map<String, dynamic> json) {
    final List<dynamic> kukList = json['kuk'] ?? [];
    return ElemenKompetensi(
      idElemen: _asInt(json['id_elemen']),
      elemenKompetensi: json['elemen_kompetensi']?.toString() ?? '',
      pertanyaanKuk: json['pertanyaan_kuk']?.toString() ?? '',
      kuk: kukList
          .map((item) => KukItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  /// Flat assessable rows: each KUK, or elemen itself if no KUK.
  List<Map<String, dynamic>> get assessableItems {
    if (kuk.isNotEmpty) {
      return kuk
          .map((k) => {
                'key': 'k:${k.idKuk}',
                'id_elemen': idElemen,
                'id_kuk': k.idKuk,
                'text': k.pertanyaanKuk,
              })
          .toList();
    }
    return [
      {
        'key': 'e:$idElemen',
        'id_elemen': idElemen,
        'id_kuk': 0,
        'text': pertanyaanKuk.isNotEmpty ? pertanyaanKuk : elemenKompetensi,
      },
    ];
  }
}

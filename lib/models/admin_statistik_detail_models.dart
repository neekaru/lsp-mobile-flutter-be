// ============================================================================
// Detailed Admin Statistics Models (Items #1-5)
// ============================================================================

class AsesorDomisiliItem {
  final String id;
  final String namaAsesor;
  final String noMet;
  final String tipeAsesor;
  final String provinsi;
  final String kabupatenKota;
  final String email;
  final String noHp;
  final String skemaKeahlian;
  final String status;

  const AsesorDomisiliItem({
    required this.id,
    required this.namaAsesor,
    required this.noMet,
    required this.tipeAsesor,
    required this.provinsi,
    required this.kabupatenKota,
    required this.email,
    required this.noHp,
    required this.skemaKeahlian,
    required this.status,
  });

  factory AsesorDomisiliItem.fromJson(Map<String, dynamic> json) {
    return AsesorDomisiliItem(
      id: json['id']?.toString() ?? '',
      namaAsesor: json['nama_asesor']?.toString() ?? json['nama']?.toString() ?? '',
      noMet: json['no_met']?.toString() ?? json['no_reg']?.toString() ?? '-',
      tipeAsesor: json['tipe_asesor']?.toString() ?? json['tipe']?.toString() ?? 'Internal',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupatenKota: json['kabupaten_kota']?.toString() ?? json['kota']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? json['telepon']?.toString() ?? '',
      skemaKeahlian: json['skema_keahlian']?.toString() ?? json['skema']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_asesor': namaAsesor,
      'no_met': noMet,
      'tipe_asesor': tipeAsesor,
      'provinsi': provinsi,
      'kabupaten_kota': kabupatenKota,
      'email': email,
      'no_hp': noHp,
      'skema_keahlian': skemaKeahlian,
      'status': status,
    };
  }
}

class DomisiliAsesorDetailData {
  final String provinsiId;
  final String provinsiNama;
  final int totalAsesor;
  final int totalInternal;
  final int totalExternal;
  final List<AsesorDomisiliItem> asesorList;
  final int totalCount;
  final int filteredCount;

  const DomisiliAsesorDetailData({
    required this.provinsiId,
    required this.provinsiNama,
    required this.totalAsesor,
    required this.totalInternal,
    required this.totalExternal,
    required this.asesorList,
    required this.totalCount,
    required this.filteredCount,
  });

  factory DomisiliAsesorDetailData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final rawMeta = json['meta'];
    final meta = rawMeta is Map<String, dynamic> ? rawMeta : <String, dynamic>{};

    final list = (data['asesor_list'] as List?)
            ?.map((e) => AsesorDomisiliItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DomisiliAsesorDetailData(
      provinsiId: data['provinsi_id']?.toString() ?? '',
      provinsiNama: data['provinsi_nama']?.toString() ?? '',
      totalAsesor: data['total_asesor'] ?? meta['total_count'] ?? 0,
      totalInternal: data['total_internal'] ?? 0,
      totalExternal: data['total_external'] ?? 0,
      asesorList: list,
      totalCount: meta['total_count'] ?? 0,
      filteredCount: meta['filtered_count'] ?? list.length,
    );
  }
}

class DomisiliAsesorProvinsiItem {
  final String provinsiId;
  final String provinsiKode;
  final String provinsiNama;
  final int totalAsesor;
  final int asesorInternal;
  final int asesorExternal;
  final double persentaseInternal;
  final List<AsesorDomisiliItem> daftarAsesor;

  const DomisiliAsesorProvinsiItem({
    required this.provinsiId,
    required this.provinsiKode,
    required this.provinsiNama,
    required this.totalAsesor,
    required this.asesorInternal,
    required this.asesorExternal,
    required this.persentaseInternal,
    this.daftarAsesor = const [],
  });

  factory DomisiliAsesorProvinsiItem.fromJson(Map<String, dynamic> json) {
    final rawAsesor = json['asesor_list'] ?? json['asesor'];
    final listAsesor = (rawAsesor is List)
        ? rawAsesor
            .map((e) => AsesorDomisiliItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <AsesorDomisiliItem>[];

    return DomisiliAsesorProvinsiItem(
      provinsiId: json['provinsi_id']?.toString() ?? '',
      provinsiKode: json['provinsi_kode']?.toString() ?? '',
      provinsiNama: json['provinsi_nama']?.toString() ?? 'Lainnya',
      totalAsesor: json['total_asesor'] ?? 0,
      asesorInternal: json['asesor_internal'] ?? 0,
      asesorExternal: json['asesor_external'] ?? 0,
      persentaseInternal:
          (json['persentase_internal'] as num?)?.toDouble() ?? 0.0,
      daftarAsesor: listAsesor,
    );
  }
}

class DomisiliAsesorData {
  final List<DomisiliAsesorProvinsiItem> items;
  final int totalAsesor;
  final int totalInternal;
  final int totalExternal;

  const DomisiliAsesorData({
    required this.items,
    required this.totalAsesor,
    required this.totalInternal,
    required this.totalExternal,
  });

  factory DomisiliAsesorData.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?)
            ?.map((e) =>
                DomisiliAsesorProvinsiItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final meta = json['meta'] ?? {};
    return DomisiliAsesorData(
      items: list,
      totalAsesor: meta['total_asesor'] ?? 0,
      totalInternal: meta['total_internal'] ?? 0,
      totalExternal: meta['total_external'] ?? 0,
    );
  }
}

class KompetensiTeknisItem {
  final int skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int jumlahAsesor;

  const KompetensiTeknisItem({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.jumlahAsesor,
  });

  factory KompetensiTeknisItem.fromJson(Map<String, dynamic> json) {
    return KompetensiTeknisItem(
      skemaId: json['skema_id'] ?? 0,
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      jumlahAsesor: json['jumlah_asesor'] ?? 0,
    );
  }
}

class KompetensiTeknisAsesorItem {
  final String id;
  final String namaAsesor;
  final String noMet;
  final String statusMasaBerlaku;
  final String tanggalExpired;
  final String provinsi;
  final String kabupatenKota;
  final String email;
  final String noHp;
  final String tipeAsesor;

  const KompetensiTeknisAsesorItem({
    required this.id,
    required this.namaAsesor,
    required this.noMet,
    required this.statusMasaBerlaku,
    required this.tanggalExpired,
    required this.provinsi,
    required this.kabupatenKota,
    required this.email,
    required this.noHp,
    required this.tipeAsesor,
  });

  factory KompetensiTeknisAsesorItem.fromJson(Map<String, dynamic> json) {
    return KompetensiTeknisAsesorItem(
      id: json['id']?.toString() ?? '',
      namaAsesor: json['nama_asesor']?.toString() ?? json['nama']?.toString() ?? '',
      noMet: json['no_met']?.toString() ?? json['no_reg']?.toString() ?? '-',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? json['status']?.toString() ?? 'Aktif',
      tanggalExpired: json['tanggal_expired']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupatenKota: json['kabupaten_kota']?.toString() ?? json['kota']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? json['telepon']?.toString() ?? '',
      tipeAsesor: json['tipe_asesor']?.toString() ?? json['tipe']?.toString() ?? 'Internal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_asesor': namaAsesor,
      'no_met': noMet,
      'status_masa_berlaku': statusMasaBerlaku,
      'tanggal_expired': tanggalExpired,
      'provinsi': provinsi,
      'kabupaten_kota': kabupatenKota,
      'email': email,
      'no_hp': noHp,
      'tipe_asesor': tipeAsesor,
    };
  }
}

class KompetensiTeknisDetailData {
  final dynamic skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int totalAsesor;
  final List<KompetensiTeknisAsesorItem> asesorList;
  final int totalCount;
  final int filteredCount;

  const KompetensiTeknisDetailData({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.totalAsesor,
    required this.asesorList,
    required this.totalCount,
    required this.filteredCount,
  });

  factory KompetensiTeknisDetailData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final rawMeta = json['meta'];
    final meta = rawMeta is Map<String, dynamic> ? rawMeta : <String, dynamic>{};

    final rawList = data['asesor_list'] ?? data['items'] ?? (json['data'] is List ? json['data'] : null);
    final list = (rawList is List)
        ? rawList
            .map((e) => KompetensiTeknisAsesorItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <KompetensiTeknisAsesorItem>[];

    return KompetensiTeknisDetailData(
      skemaId: data['skema_id'] ?? 0,
      kodeSkema: data['kode_skema']?.toString() ?? '',
      namaSkema: data['nama_skema']?.toString() ?? '',
      totalAsesor: data['total_asesor'] ?? meta['total_count'] ?? list.length,
      asesorList: list,
      totalCount: meta['total_count'] ?? data['total_count'] ?? list.length,
      filteredCount: meta['filtered_count'] ?? list.length,
    );
  }
}

class MasaBerlakuAsesorData {
  final int aktif;
  final int tenggang;
  final int expired;
  final int totalAsesor;

  const MasaBerlakuAsesorData({
    required this.aktif,
    required this.tenggang,
    required this.expired,
    required this.totalAsesor,
  });

  factory MasaBerlakuAsesorData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final meta = json['meta'] ?? {};
    return MasaBerlakuAsesorData(
      aktif: data['aktif'] ?? 0,
      tenggang: data['tenggang'] ?? 0,
      expired: data['expired'] ?? 0,
      totalAsesor: meta['total_asesor'] ?? 0,
    );
  }
}

class MasaBerlakuAsesorDetailItem {
  final String id;
  final String namaAsesor;
  final String noMet;
  final String statusMasaBerlaku;
  final String tanggalExpired;
  final int sisaHari;
  final String skemaKeahlian;
  final String provinsi;
  final String kabupatenKota;
  final String email;
  final String noHp;

  const MasaBerlakuAsesorDetailItem({
    required this.id,
    required this.namaAsesor,
    required this.noMet,
    required this.statusMasaBerlaku,
    required this.tanggalExpired,
    required this.sisaHari,
    required this.skemaKeahlian,
    required this.provinsi,
    required this.kabupatenKota,
    required this.email,
    required this.noHp,
  });

  factory MasaBerlakuAsesorDetailItem.fromJson(Map<String, dynamic> json) {
    return MasaBerlakuAsesorDetailItem(
      id: json['id']?.toString() ?? '',
      namaAsesor: json['nama_asesor']?.toString() ?? json['nama']?.toString() ?? '',
      noMet: json['no_met']?.toString() ?? json['no_reg']?.toString() ?? '-',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? json['status']?.toString() ?? 'Tenggang',
      tanggalExpired: json['tanggal_expired']?.toString() ?? json['tgl_expired']?.toString() ?? '-',
      sisaHari: (json['sisa_hari'] as num?)?.toInt() ?? (json['days_remaining'] as num?)?.toInt() ?? 0,
      skemaKeahlian: json['skema_keahlian']?.toString() ?? json['skema']?.toString() ?? '-',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupatenKota: json['kabupaten_kota']?.toString() ?? json['kota']?.toString() ?? '',
      email: json['email']?.toString() ?? '-',
      noHp: json['no_hp']?.toString() ?? json['telepon']?.toString() ?? '-',
    );
  }
}

class MasaBerlakuAsesorDetailData {
  final String statusFilter;
  final int totalCount;
  final List<MasaBerlakuAsesorDetailItem> asesorList;

  const MasaBerlakuAsesorDetailData({
    required this.statusFilter,
    required this.totalCount,
    required this.asesorList,
  });

  factory MasaBerlakuAsesorDetailData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final rawMeta = json['meta'];
    final meta = rawMeta is Map<String, dynamic> ? rawMeta : <String, dynamic>{};

    final rawList = data['asesor_list'] ?? data['items'] ?? (json['data'] is List ? json['data'] : null);
    final list = (rawList is List)
        ? rawList
            .map((e) => MasaBerlakuAsesorDetailItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <MasaBerlakuAsesorDetailItem>[];

    return MasaBerlakuAsesorDetailData(
      statusFilter: data['status_filter']?.toString() ?? '',
      totalCount: meta['total_count'] ?? data['total_count'] ?? list.length,
      asesorList: list,
    );
  }
}

class JenisSkemaItem {
  final String kategori;
  final int jumlahSkema;

  const JenisSkemaItem({
    required this.kategori,
    required this.jumlahSkema,
  });

  factory JenisSkemaItem.fromJson(Map<String, dynamic> json) {
    return JenisSkemaItem(
      kategori: json['kategori']?.toString() ?? 'Umum',
      jumlahSkema: json['jumlah_skema'] ?? 0,
    );
  }
}

class MUKDistribusiItem {
  final int skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int jumlahMuk;

  const MUKDistribusiItem({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.jumlahMuk,
  });

  factory MUKDistribusiItem.fromJson(Map<String, dynamic> json) {
    return MUKDistribusiItem(
      skemaId: json['skema_id'] ?? 0,
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      jumlahMuk: json['jumlah_muk'] ?? 0,
    );
  }
}

class PerangkatMUKItem {
  final int id;
  final int skemaId;
  final String namaPerangkat;
  final String metode;
  final String penyusun;
  final String tanggalPembuatan;
  final int jumlahDigunakan;

  const PerangkatMUKItem({
    required this.id,
    required this.skemaId,
    required this.namaPerangkat,
    required this.metode,
    required this.penyusun,
    required this.tanggalPembuatan,
    required this.jumlahDigunakan,
  });

  factory PerangkatMUKItem.fromJson(Map<String, dynamic> json) {
    return PerangkatMUKItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      skemaId: json['skema_id'] is int ? json['skema_id'] : int.tryParse(json['skema_id'].toString()) ?? 0,
      namaPerangkat: json['nama_perangkat']?.toString() ?? 'MUK / MAPA',
      metode: json['metode']?.toString() ?? 'Observasi Langsung',
      penyusun: json['penyusun']?.toString() ?? 'Administrator',
      tanggalPembuatan: json['tanggal_pembuatan']?.toString() ?? '-',
      jumlahDigunakan: json['jumlah_digunakan'] is int
          ? json['jumlah_digunakan']
          : int.tryParse(json['jumlah_digunakan'].toString()) ?? 0,
    );
  }
}

class MUKDetailData {
  final int skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int totalMuk;
  final List<PerangkatMUKItem> perangkatList;

  const MUKDetailData({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.totalMuk,
    required this.perangkatList,
  });

  factory MUKDetailData.fromJson(Map<String, dynamic> json) {
    return MUKDetailData(
      skemaId: json['skema_id'] is int ? json['skema_id'] : int.tryParse(json['skema_id'].toString()) ?? 0,
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      totalMuk: json['total_muk'] is int ? json['total_muk'] : int.tryParse(json['total_muk'].toString()) ?? 0,
      perangkatList: (json['perangkat_list'] as List<dynamic>?)
              ?.map((e) => PerangkatMUKItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <PerangkatMUKItem>[],
    );
  }
}

class SptAsesorItem {
  final String namaAsesor;
  final String tglExpired;
  final String statusMasaBerlaku;
  final int total;
  final Map<String, int> bulanan;

  const SptAsesorItem({
    required this.namaAsesor,
    required this.tglExpired,
    required this.statusMasaBerlaku,
    required this.total,
    required this.bulanan,
  });

  factory SptAsesorItem.fromJson(Map<String, dynamic> json) {
    final bulananRaw = json['bulanan'] as Map<String, dynamic>? ?? {};
    final mapBulanan = <String, int>{};
    bulananRaw.forEach((key, value) {
      mapBulanan[key] = (value as num?)?.toInt() ?? 0;
    });

    return SptAsesorItem(
      namaAsesor: json['nama_asesor']?.toString() ?? '',
      tglExpired: json['tgl_expired']?.toString() ?? '',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? 'Tidak Diketahui',
      total: json['total'] ?? 0,
      bulanan: mapBulanan,
    );
  }
}

class SptAsesorData {
  final List<SptAsesorItem> items;
  final int totalAsesor;
  final int totalJadwal;
  final int tahun;

  const SptAsesorData({
    required this.items,
    required this.totalAsesor,
    required this.totalJadwal,
    required this.tahun,
  });

  factory SptAsesorData.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?)
            ?.map((e) => SptAsesorItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final meta = json['meta'] ?? {};
    return SptAsesorData(
      items: list,
      totalAsesor: meta['total_asesor'] ?? list.length,
      totalJadwal: meta['total_jadwal'] ?? 0,
      tahun: meta['tahun'] ?? 2026,
    );
  }
}

class Asesi2026Item {
  final String namaAsesor;
  final String tglExpired;
  final String statusMasaBerlaku;
  final int totalAsesi;
  final int totalJadwal;
  final Map<String, int> bulanan;

  const Asesi2026Item({
    required this.namaAsesor,
    required this.tglExpired,
    required this.statusMasaBerlaku,
    required this.totalAsesi,
    required this.totalJadwal,
    required this.bulanan,
  });

  factory Asesi2026Item.fromJson(Map<String, dynamic> json) {
    final bulananRaw = json['bulanan'] as Map<String, dynamic>? ?? {};
    final mapBulanan = <String, int>{};
    bulananRaw.forEach((key, value) {
      mapBulanan[key] = (value as num?)?.toInt() ?? 0;
    });

    return Asesi2026Item(
      namaAsesor: json['nama_asesor']?.toString() ?? '',
      tglExpired: json['tgl_expired']?.toString() ?? '',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? 'Tidak Diketahui',
      totalAsesi: (json['total_asesi'] as num?)?.toInt() ?? 0,
      totalJadwal: (json['total_jadwal'] as num?)?.toInt() ?? 0,
      bulanan: mapBulanan,
    );
  }
}

class Asesi2026Data {
  final List<Asesi2026Item> items;
  final int totalAsesor;
  final int totalAsesi;
  final int totalJadwal;
  final int tahun;

  const Asesi2026Data({
    required this.items,
    required this.totalAsesor,
    required this.totalAsesi,
    required this.totalJadwal,
    required this.tahun,
  });

  factory Asesi2026Data.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?)
            ?.map((e) => Asesi2026Item.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final meta = json['meta'] ?? {};
    return Asesi2026Data(
      items: list,
      totalAsesor: (meta['total_asesor'] as num?)?.toInt() ?? list.length,
      totalAsesi: (meta['total_asesi'] as num?)?.toInt() ?? 0,
      totalJadwal: (meta['total_jadwal'] as num?)?.toInt() ?? 0,
      tahun: (meta['tahun'] as num?)?.toInt() ?? 2026,
    );
  }
}

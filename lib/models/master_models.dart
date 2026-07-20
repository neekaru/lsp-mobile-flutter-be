class MasterItem {
  final String id;
  final String name;

  const MasterItem({
    required this.id,
    required this.name,
  });

  factory MasterItem.fromJson(Map<String, dynamic> json) {
    return MasterItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class MasterSkema {
  final int id;
  final String kodeSkema;
  final String namaSkema;
  final String? bidang;
  final String? statusAktif;

  const MasterSkema({
    required this.id,
    required this.kodeSkema,
    required this.namaSkema,
    this.bidang,
    this.statusAktif,
  });

  factory MasterSkema.fromJson(Map<String, dynamic> json) {
    return MasterSkema(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      bidang: json['bidang']?.toString(),
      statusAktif: json['status_aktif']?.toString(),
    );
  }

  String get displayName => '$kodeSkema - $namaSkema';
}

class MasterJadwal {
  final int id;
  final String jadwal;
  final String tanggal;
  final int kuota;
  final String statusJadwal;
  final String tuk;

  const MasterJadwal({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    required this.kuota,
    required this.statusJadwal,
    required this.tuk,
  });

  factory MasterJadwal.fromJson(Map<String, dynamic> json) {
    return MasterJadwal(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      jadwal: json['jadwal']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      kuota: json['kuota'] is int ? json['kuota'] : int.parse(json['kuota']?.toString() ?? '0'),
      statusJadwal: json['status_jadwal']?.toString() ?? '',
      tuk: json['tuk']?.toString() ?? '',
    );
  }

  String get displayName => '$jadwal ($tuk)';
}

class MasterPendidikan {
  final int id;
  final String namaPendidikan;

  const MasterPendidikan({
    required this.id,
    required this.namaPendidikan,
  });

  factory MasterPendidikan.fromJson(Map<String, dynamic> json) {
    return MasterPendidikan(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaPendidikan: json['nama_pendidikan']?.toString() ?? '',
    );
  }

  String get displayName => namaPendidikan;
}

class MasterPekerjaan {
  final int id;
  final String namaPekerjaan;

  const MasterPekerjaan({
    required this.id,
    required this.namaPekerjaan,
  });

  factory MasterPekerjaan.fromJson(Map<String, dynamic> json) {
    return MasterPekerjaan(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaPekerjaan: json['nama_pekerjaan']?.toString() ?? '',
    );
  }

  String get displayName => namaPekerjaan;
}

class MasterSumberAnggaran {
  final int id;
  final String jenisAnggaran;
  final List<int> pemberiIds;

  const MasterSumberAnggaran({
    required this.id,
    required this.jenisAnggaran,
    this.pemberiIds = const [],
  });

  factory MasterSumberAnggaran.fromJson(Map<String, dynamic> json) {
    final rawIds = json['pemberi_ids'];
    final List<int> ids = [];
    if (rawIds is List) {
      for (final e in rawIds) {
        if (e is int) {
          ids.add(e);
        } else {
          final n = int.tryParse(e?.toString() ?? '');
          if (n != null) ids.add(n);
        }
      }
    }
    return MasterSumberAnggaran(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      jenisAnggaran: json['jenis_anggaran']?.toString() ?? '',
      pemberiIds: ids,
    );
  }

  String get displayName => jenisAnggaran;
}

class MasterPemberiAnggaran {
  final int id;
  final String instansiPemberiAnggaran;
  final List<int> sumberIds;

  const MasterPemberiAnggaran({
    required this.id,
    required this.instansiPemberiAnggaran,
    this.sumberIds = const [],
  });

  factory MasterPemberiAnggaran.fromJson(Map<String, dynamic> json) {
    final rawIds = json['sumber_ids'];
    final List<int> ids = [];
    if (rawIds is List) {
      for (final e in rawIds) {
        if (e is int) {
          ids.add(e);
        } else {
          final n = int.tryParse(e?.toString() ?? '');
          if (n != null) ids.add(n);
        }
      }
    }
    return MasterPemberiAnggaran(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      instansiPemberiAnggaran: json['instansi_pemberi_anggaran']?.toString() ?? '',
      sumberIds: ids,
    );
  }

  String get displayName => instansiPemberiAnggaran;
}

class SkemaUnitItem {
  final int no;
  final String kode;
  final String judul;

  const SkemaUnitItem({
    required this.no,
    required this.kode,
    required this.judul,
  });

  factory SkemaUnitItem.fromJson(Map<String, dynamic> json) {
    return SkemaUnitItem(
      no: json['no'] is int
          ? json['no'] as int
          : int.tryParse(json['no']?.toString() ?? '0') ?? 0,
      kode: json['kode']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toUnitMap() => {
        'kode': kode,
        'judul': judul,
        'kompeten': true,
      };
}

class SkemaPersyaratanItem {
  final int id;
  final String key;
  final String jenisBukti;
  final String label;
  final String namaPersyaratan;
  final bool mandatory;
  final int urutan;

  const SkemaPersyaratanItem({
    required this.id,
    required this.key,
    required this.jenisBukti,
    required this.label,
    required this.namaPersyaratan,
    required this.mandatory,
    required this.urutan,
  });

  factory SkemaPersyaratanItem.fromJson(Map<String, dynamic> json) {
    return SkemaPersyaratanItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      key: json['key']?.toString() ?? '',
      jenisBukti: json['jenis_bukti']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      namaPersyaratan: json['nama_persyaratan']?.toString() ?? '',
      mandatory: json['mandatory'] == true || json['mandatory']?.toString() == '1',
      urutan: json['urutan'] is int
          ? json['urutan'] as int
          : int.tryParse(json['urutan']?.toString() ?? '0') ?? 0,
    );
  }
}

class SkemaPersyaratanAdminItem {
  final int id;
  final String key;
  final String label;
  final bool mandatory;
  final String source;

  const SkemaPersyaratanAdminItem({
    required this.id,
    required this.key,
    required this.label,
    required this.mandatory,
    required this.source,
  });

  factory SkemaPersyaratanAdminItem.fromJson(Map<String, dynamic> json) {
    return SkemaPersyaratanAdminItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      mandatory: json['mandatory'] == true || json['mandatory']?.toString() == '1',
      source: json['source']?.toString() ?? 'default',
    );
  }
}

class SkemaUnitPersyaratan {
  final int idSkema;
  final String kodeSkema;
  final String namaSkema;
  final List<SkemaUnitItem> unitKompetensi;
  final List<SkemaPersyaratanItem> persyaratanDasar;
  final List<SkemaPersyaratanAdminItem> persyaratanAdministratif;

  const SkemaUnitPersyaratan({
    required this.idSkema,
    required this.kodeSkema,
    required this.namaSkema,
    required this.unitKompetensi,
    required this.persyaratanDasar,
    required this.persyaratanAdministratif,
  });

  factory SkemaUnitPersyaratan.fromJson(Map<String, dynamic> json) {
    final units = (json['unit_kompetensi'] as List<dynamic>? ?? [])
        .map((e) => SkemaUnitItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final dasar = (json['persyaratan_dasar'] as List<dynamic>? ?? [])
        .map((e) => SkemaPersyaratanItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final admin = (json['persyaratan_administratif'] as List<dynamic>? ?? [])
        .map((e) => SkemaPersyaratanAdminItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SkemaUnitPersyaratan(
      idSkema: json['id_skema'] is int
          ? json['id_skema'] as int
          : int.tryParse(json['id_skema']?.toString() ?? '0') ?? 0,
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      unitKompetensi: units,
      persyaratanDasar: dasar,
      persyaratanAdministratif: admin,
    );
  }
}

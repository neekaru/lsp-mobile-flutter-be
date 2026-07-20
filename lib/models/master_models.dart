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

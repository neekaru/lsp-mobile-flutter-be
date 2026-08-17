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

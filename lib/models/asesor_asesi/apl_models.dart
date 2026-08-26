// ============================================================================
// Model formulir APL-01 & APL-02 (asesi).
// Diekstrak dari asesor_asesi_models.dart.
// ============================================================================

class APL01Data {
  final String status;
  final String rekomendasi;
  final String catatan;
  final String tanggalValidasi;
  final List<BuktiDokumenItem> persyaratanDasar;
  final List<BuktiDokumenItem> persyaratanAdministratif;
  final List<BuktiDokumenItem> buktiDokumen;

  APL01Data({
    required this.status,
    required this.rekomendasi,
    required this.catatan,
    required this.tanggalValidasi,
    this.persyaratanDasar = const [],
    this.persyaratanAdministratif = const [],
    required this.buktiDokumen,
  });

  factory APL01Data.fromJson(Map<String, dynamic> json) {
    String rawRekom = json['rekomendasi'] as String? ?? '';
    if (rawRekom.isEmpty || rawRekom == '0' || rawRekom == '1') {
      rawRekom = 'Diterima Sebagai Peserta Asesmen';
    } else if (rawRekom == '2') {
      rawRekom = 'Tidak Diterima Sebagai Peserta Asesmen';
    } else if (rawRekom == '3') {
      rawRekom = 'Perlu Perbaikan Dokumen';
    }

    final dasarList = (json['persyaratan_dasar'] as List<dynamic>? ?? [])
        .map((e) => BuktiDokumenItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final adminList = (json['persyaratan_administratif'] as List<dynamic>? ?? [])
        .map((e) => BuktiDokumenItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final buktiList = (json['bukti_dokumen'] as List<dynamic>? ?? [])
        .map((e) => BuktiDokumenItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return APL01Data(
      status: json['status'] as String? ?? 'Terverifikasi',
      rekomendasi: rawRekom,
      catatan: json['catatan'] as String? ?? '',
      tanggalValidasi: json['tanggal_validasi'] as String? ?? '',
      persyaratanDasar: dasarList,
      persyaratanAdministratif: adminList,
      buktiDokumen: buktiList,
    );
  }
}

class BuktiDokumenItem {
  final String nama;
  final String jenis;
  final String? jenisBukti;
  final bool ada;
  final String? fileName;
  final String? url;

  BuktiDokumenItem({
    required this.nama,
    required this.jenis,
    this.jenisBukti,
    required this.ada,
    this.fileName,
    this.url,
  });

  factory BuktiDokumenItem.fromJson(Map<String, dynamic> json) {
    return BuktiDokumenItem(
      nama: json['nama'] as String? ?? '',
      jenis: json['jenis'] as String? ?? 'Wajib',
      jenisBukti: json['jenis_bukti'] as String?,
      ada: json['ada'] as bool? ?? true,
      fileName: json['file_name'] as String?,
      url: json['url'] as String?,
    );
  }
}

class MapaOption {
  final int id;
  final String namaMapa;
  final String displayText;
  final String metode;
  final String insClo;
  final String insPraktik;
  final String insObservasi;
  final String insPortofolio;
  final String insPg;
  final String insEsai;
  final String insLisan;
  final String insVPortofolio;
  final String insWawancara;
  final List<String> instrumen;
  final bool hasIA01;
  final bool hasIA02;
  final bool hasIA03;
  final bool hasIA05;
  final bool hasIA06;
  final bool hasIA11;

  MapaOption({
    required this.id,
    required this.namaMapa,
    required this.displayText,
    this.metode = 'observasi',
    this.insClo = '0',
    this.insPraktik = '0',
    this.insObservasi = '0',
    this.insPortofolio = '0',
    this.insPg = '0',
    this.insEsai = '0',
    this.insLisan = '0',
    this.insVPortofolio = '0',
    this.insWawancara = '0',
    this.instrumen = const [],
    this.hasIA01 = true,
    this.hasIA02 = true,
    this.hasIA03 = true,
    this.hasIA05 = true,
    this.hasIA06 = false,
    this.hasIA11 = false,
  });

  bool get isPortofolio =>
      metode == 'portofolio' ||
      namaMapa.toUpperCase().contains('PORTOFOLIO') ||
      insPortofolio != '0' ||
      insVPortofolio != '0';

  bool isInstrumentActive(String formId, String selectedKandidat) {
    if (selectedKandidat == '3' || isPortofolio) {
      if (formId == 'IA11' || formId == 'IA08' || formId == 'IA09') return true;
      if (formId == 'IA03') return hasIA03;
      return false;
    }
    // Observasi / Terstruktur (Kandidat 1, 2, 4)
    switch (formId) {
      case 'IA01':
        return hasIA01 && (insClo == selectedKandidat || insClo == '1' || insClo == '0');
      case 'IA02':
        return hasIA02 && (insPraktik == selectedKandidat || insPraktik == '1' || insPraktik == '0');
      case 'IA03':
        return hasIA03;
      case 'IA05':
        return hasIA05 && (insPg == selectedKandidat || insPg == '1' || insPg == '0');
      case 'IA06':
        return hasIA06 && (insEsai == selectedKandidat || insEsai == '1' || insEsai == '0');
      default:
        return false;
    }
  }

  factory MapaOption.fromJson(Map<String, dynamic> json) {
    final rawNama = json['nama_mapa'] as String? ?? '';
    final isPortofolio = rawNama.toUpperCase().contains('PORTOFOLIO') ||
        (json['ins_portofolio'] != null && json['ins_portofolio'] != '0') ||
        (json['ins_vportofolio'] != null && json['ins_vportofolio'] != '0');
    final rawInstrumen = (json['instrumen'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return MapaOption(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      namaMapa: rawNama,
      displayText: json['display_text'] as String? ?? '',
      metode: json['metode'] as String? ?? (isPortofolio ? 'portofolio' : 'observasi'),
      insClo: json['ins_clo']?.toString() ?? '0',
      insPraktik: json['ins_praktik']?.toString() ?? '0',
      insObservasi: json['ins_observasi']?.toString() ?? '0',
      insPortofolio: json['ins_portofolio']?.toString() ?? '0',
      insPg: json['ins_pg']?.toString() ?? '0',
      insEsai: json['ins_esai']?.toString() ?? '0',
      insLisan: json['ins_lisan']?.toString() ?? '0',
      insVPortofolio: json['ins_vportofolio']?.toString() ?? '0',
      insWawancara: json['ins_wawancara']?.toString() ?? '0',
      instrumen: rawInstrumen,
      hasIA01: json['has_ia01'] ?? !isPortofolio,
      hasIA02: json['has_ia02'] ?? !isPortofolio,
      hasIA03: json['has_ia03'] ?? true,
      hasIA05: json['has_ia05'] ?? !isPortofolio,
      hasIA06: json['has_ia06'] ?? false,
      hasIA11: json['has_ia11'] ?? isPortofolio,
    );
  }
}

class KandidatOption {
  final String id;
  final String label;

  KandidatOption({
    required this.id,
    required this.label,
  });

  factory KandidatOption.fromJson(Map<String, dynamic> json) {
    return KandidatOption(
      id: json['id']?.toString() ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class APL02Data {
  final String status;
  final int totalUnit;
  final int totalK;
  final int totalBK;
  final List<APL02UnitItem> units;
  final String praAsesmen;
  final String rekomendasi;
  final String catatanRekomendasi;
  final String tanggal;
  final bool isApproved;
  final String kandidat;
  final String kandidatLabel;
  final int? idMapa;
  final String namaMapa;
  final String qrCodeData;
  final List<MapaOption> mapaOptions;
  final List<KandidatOption> kandidatOptions;

  APL02Data({
    required this.status,
    required this.totalUnit,
    required this.totalK,
    required this.totalBK,
    required this.units,
    this.praAsesmen = '0',
    this.rekomendasi = 'Belum Diverifikasi',
    this.catatanRekomendasi = 'Di rekomendasi menjadi peserta uji kompetensi',
    this.tanggal = '',
    this.isApproved = false,
    this.kandidat = '1',
    this.kandidatLabel = '',
    this.idMapa,
    this.namaMapa = '',
    this.qrCodeData = '',
    this.mapaOptions = const [],
    this.kandidatOptions = const [],
  });

  factory APL02Data.fromJson(Map<String, dynamic> json) {
    return APL02Data(
      status: json['status'] as String? ?? 'Lengkap',
      totalUnit: int.tryParse(json['total_unit']?.toString() ?? '') ?? 0,
      totalK: int.tryParse(json['total_k']?.toString() ?? '') ?? 0,
      totalBK: int.tryParse(json['total_bk']?.toString() ?? '') ?? 0,
      units: (json['units'] as List<dynamic>? ?? [])
          .map((e) => APL02UnitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      praAsesmen: json['pra_asesmen']?.toString() ?? '0',
      rekomendasi: json['rekomendasi'] as String? ?? 'Belum Diverifikasi',
      catatanRekomendasi: json['catatan_rekomendasi'] as String? ?? 'Di rekomendasi menjadi peserta uji kompetensi',
      tanggal: json['tanggal'] as String? ?? '',
      isApproved: json['is_approved'] as bool? ?? false,
      kandidat: json['kandidat']?.toString() ?? '1',
      kandidatLabel: json['kandidat_label'] as String? ?? '',
      idMapa: json['id_mapa'] != null ? int.tryParse(json['id_mapa'].toString()) : null,
      namaMapa: json['nama_mapa'] as String? ?? '',
      qrCodeData: json['qr_code_data'] as String? ?? '',
      mapaOptions: (json['mapa_options'] as List<dynamic>? ?? [])
          .map((e) => MapaOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      kandidatOptions: (json['kandidat_options'] as List<dynamic>? ?? [])
          .map((e) => KandidatOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class APL02UnitItem {
  final String idUnit;
  final String kodeUnit;
  final String judulUnit;
  final String statusKompeten;
  final String jenisBukti;

  APL02UnitItem({
    required this.idUnit,
    required this.kodeUnit,
    required this.judulUnit,
    required this.statusKompeten,
    required this.jenisBukti,
  });

  factory APL02UnitItem.fromJson(Map<String, dynamic> json) {
    return APL02UnitItem(
      idUnit: json['id_unit']?.toString() ?? '',
      kodeUnit: json['kode_unit'] as String? ?? '',
      judulUnit: json['judul_unit'] as String? ?? '',
      statusKompeten: json['status_kompeten'] as String? ?? 'K',
      jenisBukti: json['jenis_bukti'] as String? ?? 'Portofolio',
    );
  }
}

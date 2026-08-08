class BeritaItem {
  final int id;
  final String judul;
  final String headline;
  final String kategori;
  final int? idKategori;
  final String? foto;
  final String showImage;
  final String tanggalBuat;

  const BeritaItem({
    required this.id,
    required this.judul,
    required this.headline,
    required this.kategori,
    this.idKategori,
    this.foto,
    this.showImage = '1',
    required this.tanggalBuat,
  });

  factory BeritaItem.fromJson(Map<String, dynamic> json) {
    return BeritaItem(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      headline: json['headline'] ?? '',
      kategori: json['kategori'] ?? '',
      idKategori: json['id_kategori'] is int
          ? json['id_kategori']
          : int.tryParse(json['id_kategori']?.toString() ?? ''),
      foto: json['foto'],
      showImage: json['show_image']?.toString() ?? '1',
      tanggalBuat: json['tanggal_buat'] ?? '',
    );
  }
}

class BeritaDetail {
  final int id;
  final String judul;
  final String headline;
  final String isi;
  final String kategori;
  final int? idKategori;
  final String? foto;
  final String showImage;
  final String tanggalBuat;

  const BeritaDetail({
    required this.id,
    required this.judul,
    required this.headline,
    required this.isi,
    required this.kategori,
    this.idKategori,
    this.foto,
    this.showImage = '1',
    required this.tanggalBuat,
  });

  factory BeritaDetail.fromJson(Map<String, dynamic> json) {
    return BeritaDetail(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      headline: json['headline'] ?? '',
      isi: json['isi'] ?? '',
      kategori: json['kategori'] ?? '',
      idKategori: json['id_kategori'] is int
          ? json['id_kategori']
          : int.tryParse(json['id_kategori']?.toString() ?? ''),
      foto: json['foto'],
      showImage: json['show_image']?.toString() ?? '1',
      tanggalBuat: json['tanggal_buat'] ?? '',
    );
  }
}

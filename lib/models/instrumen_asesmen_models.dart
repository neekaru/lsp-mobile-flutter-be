import 'package:flutter/foundation.dart';

/// Item Langkah Kerja & Poin Observasi (FR.IA.01)
class IA01Item {
  final int no;
  final String langkahKerja;
  final List<String> poinObservasi;
  String? penilaian; // 'K' = Kompeten, 'BK' = Belum Kompeten, or null
  String catatan;

  IA01Item({
    required this.no,
    required this.langkahKerja,
    required this.poinObservasi,
    this.penilaian,
    this.catatan = '',
  });

  IA01Item copyWith({
    int? no,
    String? langkahKerja,
    List<String>? poinObservasi,
    String? penilaian,
    String? catatan,
  }) {
    return IA01Item(
      no: no ?? this.no,
      langkahKerja: langkahKerja ?? this.langkahKerja,
      poinObservasi: poinObservasi ?? this.poinObservasi,
      penilaian: penilaian ?? this.penilaian,
      catatan: catatan ?? this.catatan,
    );
  }
}

/// Unit Kompetensi pada FR.IA.01
class IA01UnitKompetensi {
  final int noUnit;
  final String kodeUnit;
  final String judulUnit;
  final List<IA01Item> items;
  String? rekomendasiUnit; // 'Kompeten' / 'Belum Kompeten' / null
  String catatanUnit;
  String perluPertanyaanPendukung; // 'Tidak' / 'Ya'
  String alasanPertanyaanPendukung;
  String perluBuktiTambahan; // 'Tidak' / 'Ya'
  String alasanBuktiTambahan;

  IA01UnitKompetensi({
    required this.noUnit,
    required this.kodeUnit,
    required this.judulUnit,
    required this.items,
    this.rekomendasiUnit,
    this.catatanUnit = '',
    this.perluPertanyaanPendukung = 'Tidak',
    this.alasanPertanyaanPendukung = 'Sudah terpenuhi saat TPD',
    this.perluBuktiTambahan = 'Tidak',
    this.alasanBuktiTambahan = '',
  });

  /// Status apakah seluruh item sudah dinilai
  bool get isSemuaDinilai => items.every((item) => item.penilaian != null && item.penilaian!.isNotEmpty);

  /// Status apakah ada nilai BK
  bool get adaBK => items.any((item) => item.penilaian == 'BK');
}

/// Mock Generator untuk FR.IA.01
class InstrumenAsesmenMock {
  static List<IA01UnitKompetensi> generateDefaultIA01Units() {
    return [
      IA01UnitKompetensi(
        noUnit: 1,
        kodeUnit: 'J.620100.004.02',
        judulUnit: 'Menggunakan Struktur Data',
        items: [
          IA01Item(
            no: 1,
            langkahKerja: 'Mengidentifikasi konsep data dan struktur data',
            poinObservasi: [
              'Konsep data dan struktur data diidentifikasi sesuai dengan konteks permasalahan.',
              'Alternatif struktur data dibandingkan kelebihan dan kekurangannya untuk konteks permasalahan yang diselesaikan.',
            ],
            penilaian: null,
          ),
          IA01Item(
            no: 2,
            langkahKerja: 'Menerapkan struktur data dan akses terhadap struktur data tersebut',
            poinObservasi: [
              'Struktur data diimplementasikan sesuai dengan bahasa pemrograman yang akan dipergunakan.',
              'Akses terhadap data dinyatakan dalam algoritma yang efisiensi sesuai bahasa pemrograman yang akan dipakai.',
            ],
            penilaian: null,
          ),
        ],
        catatanUnit: '',
      ),
      IA01UnitKompetensi(
        noUnit: 2,
        kodeUnit: 'J.620100.005.02',
        judulUnit: 'Mengimplementasikan Algoritma Pemrograman',
        items: [
          IA01Item(
            no: 1,
            langkahKerja: 'Menjelaskan varian dan invarian pada algoritma',
            poinObservasi: [
              'Varian dan invarian pada algoritma didefinisikan sesuai kebutuhan komputasi.',
              'Kondisi batas (boundary condition) ditentukan dalam logika algoritma.',
            ],
            penilaian: null,
          ),
          IA01Item(
            no: 2,
            langkahKerja: 'Membuat algoritma penyelesaian masalah',
            poinObservasi: [
              'Alur logika algoritma diwujudkan dalam pseudocode atau diagram alur.',
              'Algoritma diuji menggunakan kasus uji dasar untuk memastikan validitas hasil.',
            ],
            penilaian: null,
          ),
        ],
        catatanUnit: '',
      ),
      IA01UnitKompetensi(
        noUnit: 3,
        kodeUnit: 'J.620100.016.01',
        judulUnit: 'Menulis Kode dengan Prinsip Sesuai Guidelines dan Best Practices',
        items: [
          IA01Item(
            no: 1,
            langkahKerja: 'Menerapkan coding guidelines dan best practices',
            poinObservasi: [
              'Pedoman penulisan kode (coding guidelines) diterapkan secara konsisten.',
              'Penamaan variabel, fungsi, dan berkas mengikuti standar baku yang berlaku.',
            ],
            penilaian: null,
          ),
          IA01Item(
            no: 2,
            langkahKerja: 'Menggunakan dokumentasi dalam kode',
            poinObservasi: [
              'Komentar dan dokumentasi kode ditulis pada blok fungsi atau modul yang kompleks.',
              'Format dokumentasi kode mengikuti pedoman yang ditentukan.',
            ],
            penilaian: null,
          ),
        ],
        catatanUnit: '',
      ),
    ];
  }

  static IA02TugasPraktikData generateDefaultIA02Data({String namaAsesi = 'Raga fitrah banyu nabala'}) {
    return IA02TugasPraktikData(
      namaAsesi: namaAsesi,
      penyusunStatus: 'Penyusun',
      penyusunNama: '',
      penyusunNomorMet: '',
      penyusunTandaTangan: 'Belum Ditandatangani',
      validatorStatus: 'Validator',
      validatorNama: '',
      validatorNomorMet: '',
      validatorTandaTangan: 'Belum Divalidasi',
      skenarioTugas:
          'Asesi diminta untuk mengimplementasikan struktur data dan algoritma penyelesaian masalah ke dalam kode program sesuai spesifikasi proyek yang diberikan pada instruksi tugas.',
      perlengkapanPeralatan:
          'Komputer / Laptop, IDE / Code Editor, Compiler / Runtime Environment, Web Browser, Akses Internet.',
      durasiWaktu: '120 Menit',
      fileTugasPraktek: 'Belum Upload Tugas TPD',
      linkHasilPraktek: '',
      catatan: '',
    );
  }

  static IA03Data generateDefaultIA03Data({String namaAsesi = 'Raga fitrah banyu nabala'}) {
    return IA03Data(
      namaAsesi: namaAsesi,
      items: [
        IA03PertanyaanItem(
          no: 1,
          pertanyaan:
              'Jelaskan perbedaan mendasar antara struktur data Array dan Linked List serta situasi terbaik untuk menerapkannya!',
          kunciJawaban:
              'Array memiliki alokasi memori berurutan dengan akses acak O(1) namun ukuran tetap, sedangkan Linked List alokasi dinamis dengan penyisipan O(1) di awal/akhir namun akses sekuensial O(n).',
          pencapaian: null,
        ),
        IA03PertanyaanItem(
          no: 2,
          pertanyaan:
              'Bagaimana Anda mengidentifikasi dan menangani kondisi batas (boundary conditions) atau potensi error pada algoritma yang Anda buat?',
          kunciJawaban:
              'Menggunakan validasi input, memeriksa nilai null/empty/out of bounds, dan mengimplementasikan try-catch exception handling secara terstruktur.',
          pencapaian: null,
        ),
        IA03PertanyaanItem(
          no: 3,
          pertanyaan:
              'Sebutkan pedoman atau best practices penulisan kode bersih (clean code) yang Anda terapkan dalam proyek ini!',
          kunciJawaban:
              'Menggunakan penamaan variabel dan fungsi yang deskriptif, mematuhi DRY (Don\'t Repeat Yourself), membatasi fungsi hanya satu tanggung jawab (Single Responsibility), dan menambahkan komentar dokumentasi pada logika kompleks.',
          pencapaian: null,
        ),
        IA03PertanyaanItem(
          no: 4,
          pertanyaan:
              'Bagaimana langkah-langkah yang Anda lakukan saat melakukan debugging jika terjadi kesalahan logika (logical bug) pada sistem?',
          kunciJawaban:
              'Melakukan isolasi fungsi yang bermasalah, menelaah log error, menggunakan breakpoint / logging variabel state, dan menguji kembali dengan input kasus uji yang menyebabkan kegagalan.',
          pencapaian: null,
        ),
      ],
      umpanBalikUntukAsesi: '',
    );
  }

  static IA05Data generateDefaultIA05Data({String namaAsesi = 'Raga fitrah banyu nabala'}) {
    return IA05Data(
      namaAsesi: namaAsesi,
      items: [
        IA05SoalItem(
          no: 1,
          pertanyaan: 'tools untuk meriset hashtag adalah...',
          options: [
            IA05SoalOption(kode: 'A', teks: 'google trend', isKunci: false),
            IA05SoalOption(kode: 'B', teks: 'keyword every where', isKunci: false),
            IA05SoalOption(kode: 'C', teks: 'social blade', isKunci: true),
            IA05SoalOption(kode: 'D', teks: 'fb ads manager', isKunci: false),
          ],
          jawabanAsesi: 'C. social blade',
          pencapaian: null,
        ),
        IA05SoalItem(
          no: 2,
          pertanyaan: 'Fungsi hashtag pada postingan sosial media digunakan untuk...',
          options: [
            IA05SoalOption(kode: 'A', teks: 'mengelompokkan', isKunci: true),
            IA05SoalOption(kode: 'B', teks: 'ciri khas', isKunci: false),
            IA05SoalOption(kode: 'C', teks: 'agar unik', isKunci: false),
            IA05SoalOption(kode: 'D', teks: 'semua jawaban benar', isKunci: false),
          ],
          jawabanAsesi: 'A. mengelompokkan',
          pencapaian: null,
        ),
        IA05SoalItem(
          no: 3,
          pertanyaan: 'Struktur data yang beroperasi dengan prinsip LIFO (Last In First Out) adalah...',
          options: [
            IA05SoalOption(kode: 'A', teks: 'Queue', isKunci: false),
            IA05SoalOption(kode: 'B', teks: 'Stack', isKunci: true),
            IA05SoalOption(kode: 'C', teks: 'Array', isKunci: false),
            IA05SoalOption(kode: 'D', teks: 'Tree', isKunci: false),
          ],
          jawabanAsesi: 'B. Stack',
          pencapaian: null,
        ),
        IA05SoalItem(
          no: 4,
          pertanyaan: 'Algoritma pencarian yang bekerja dengan membagi dua rentang data yang telah terurut adalah...',
          options: [
            IA05SoalOption(kode: 'A', teks: 'Linear Search', isKunci: false),
            IA05SoalOption(kode: 'B', teks: 'Binary Search', isKunci: true),
            IA05SoalOption(kode: 'C', teks: 'Depth First Search', isKunci: false),
            IA05SoalOption(kode: 'D', teks: 'Breadth First Search', isKunci: false),
          ],
          jawabanAsesi: 'B. Binary Search',
          pencapaian: null,
        ),
      ],
      catatanAsesor: '',
    );
  }
}

/// Model Data untuk FR.IA.02 (Tugas Praktik Demonstrasi)
class IA02TugasPraktikData {
  final String namaAsesi;
  final String penyusunStatus;
  final String penyusunNama;
  final String penyusunNomorMet;
  final String penyusunTandaTangan;
  final String validatorStatus;
  final String validatorNama;
  final String validatorNomorMet;
  final String validatorTandaTangan;
  final String skenarioTugas;
  final String perlengkapanPeralatan;
  final String durasiWaktu;
  final String fileTugasPraktek;
  String? fileTugasPraktekUrl;
  String linkHasilPraktek;
  String catatan;
  String? rekomendasi; // 'K' = Kompeten, 'BK' = Belum Kompeten, or null

  IA02TugasPraktikData({
    required this.namaAsesi,
    this.penyusunStatus = 'Penyusun',
    this.penyusunNama = '',
    this.penyusunNomorMet = '',
    this.penyusunTandaTangan = 'Belum Ditandatangani',
    this.validatorStatus = 'Validator',
    this.validatorNama = '',
    this.validatorNomorMet = '',
    this.validatorTandaTangan = 'Belum Divalidasi',
    this.skenarioTugas = '',
    this.perlengkapanPeralatan = '',
    this.durasiWaktu = '120 Menit',
    this.fileTugasPraktek = 'Belum Upload Tugas TPD',
    this.fileTugasPraktekUrl,
    this.linkHasilPraktek = '',
    this.catatan = '',
    this.rekomendasi,
  });
}

/// Item Pertanyaan untuk FR.IA.03
class IA03PertanyaanItem {
  final int no;
  final String pertanyaan;
  final String kunciJawaban;
  String tanggapanAsesi;
  String? pencapaian; // 'Ya' = Memuaskan/Tercapai, 'Tidak' = Belum, or null

  IA03PertanyaanItem({
    required this.no,
    required this.pertanyaan,
    this.kunciJawaban = '',
    this.tanggapanAsesi = '',
    this.pencapaian,
  });
}

/// Model Data untuk FR.IA.03 (Pertanyaan Untuk Mendukung Observasi)
class IA03Data {
  final String namaAsesi;
  final List<IA03PertanyaanItem> items;
  String umpanBalikUntukAsesi;
  String catatan;

  IA03Data({
    required this.namaAsesi,
    required this.items,
    this.umpanBalikUntukAsesi = '',
    this.catatan = '',
  });

  bool get isSemuaDinilai => items.every((i) => i.pencapaian != null && i.pencapaian!.isNotEmpty);
}

/// Opsi Pilihan Ganda FR.IA.05
class IA05SoalOption {
  final String kode; // 'A', 'B', 'C', 'D'
  final String teks;
  final bool isKunci;

  IA05SoalOption({
    required this.kode,
    required this.teks,
    this.isKunci = false,
  });
}

/// Item Soal Tertulis FR.IA.05
class IA05SoalItem {
  final int no;
  final String pertanyaan;
  final List<IA05SoalOption> options;
  String jawabanAsesi;
  String? pencapaian; // 'Ya' = Benar/Tercapai, 'Tidak' = Salah/Belum, or null
  String catatan;

  IA05SoalItem({
    required this.no,
    required this.pertanyaan,
    required this.options,
    this.jawabanAsesi = '',
    this.pencapaian,
    this.catatan = '',
  });

  /// Kunci jawaban (misal 'C. social blade')
  String get kunciText {
    final k = options.firstWhere((o) => o.isKunci, orElse: () => IA05SoalOption(kode: '', teks: ''));
    if (k.kode.isEmpty) return '';
    return '${k.kode}. ${k.teks}';
  }
}

/// Model Data untuk FR.IA.05 (Pertanyaan Tertulis)
class IA05Data {
  final String namaAsesi;
  final List<IA05SoalItem> items;
  String catatanAsesor;

  IA05Data({
    required this.namaAsesi,
    required this.items,
    this.catatanAsesor = '',
  });

  int get totalBenar => items.where((i) => i.pencapaian == 'Ya').length;
  bool get isSemuaDinilai => items.every((i) => i.pencapaian != null && i.pencapaian!.isNotEmpty);
}

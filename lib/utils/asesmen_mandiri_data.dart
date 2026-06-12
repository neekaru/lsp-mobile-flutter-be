class AsesmenMandiriData {
  static String getKukCount(String kode) {
    if (kode.contains('001')) return '8 KUK';
    if (kode.contains('002')) return '10 KUK';
    if (kode.contains('003')) return '12 KUK';
    if (kode.contains('007')) return '13 KUK';
    return '11 KUK';
  }

  static List<Map<String, dynamic>> getElementsForUnit(String unitKode) {
    if (unitKode.contains('RIT') || unitKode.contains('055')) {
      return [
        {
          'title': 'Melakukan riset pasar dan tren pemasaran digital',
          'kukCount': '4 KUK',
          'kuks': [
            'Melakukan Aktivitas Pemasaran Digital untuk Bisnis Ritel',
            'melakukan Riset pasar dari sumber-sumber terpercaya untuk menentukan kebutuhan pelanggan',
            'mengidentifikasi Tren perkembangan pemasaran digital dan manfaat penggunaannya bagi bisnis ritel',
            'menyesuaikan Hasil penelitian dengan kebijakan dan prosedur perusahaan',
          ]
        },
        {
          'title': 'Melakukan aktivitas pemasaran digital',
          'kukCount': '5 KUK',
          'kuks': [
            'Memilih platform media sosial yang sesuai dengan segmen bisnis ritel',
            'Membuat profil bisnis ritel di media sosial resmi',
            'Membuat konten penawaran produk ritel yang menarik',
            'Menanggapi komentar dan pesan dari pelanggan secara responsif',
            'Mengevaluasi insight postingan berkala',
          ]
        }
      ];
    } else if (unitKode.contains('OPR') || unitKode.contains('001')) {
      return [
        {
          'title': 'Mempersiapkan penggunaan perangkat komputer',
          'kukCount': '3 KUK',
          'kuks': [
            'Memeriksa kabel daya dan periferal komputer terpasang dengan benar',
            'Menyalakan tombol daya utama sesuai dengan SOP',
            'Melakukan login menggunakan user ID dan password yang sah',
          ]
        },
        {
          'title': 'Mengoperasikan sistem komputer',
          'kukCount': '5 KUK',
          'kuks': [
            'Membuka aplikasi perkantoran yang dibutuhkan',
            'Menyimpan file dokumen ke media penyimpanan lokal atau cloud',
            'Menggunakan fitur pencarian file pada direktori',
            'Melakukan pencetakan dokumen ke printer aktif',
            'Mematikan komputer (shutdown) sesuai prosedur keselamatan',
          ]
        }
      ];
    } else if (unitKode.contains('007')) {
      return [
        {
          'title': 'Mempersiapkan penelusur situs web',
          'kukCount': '4 KUK',
          'kuks': [
            'Memastikan koneksi internet aktif dan stabil',
            'Membuka aplikasi penelusur web terinstal',
            'Melakukan pengaturan dasar penelusur web',
            'Mengidentifikasi fitur-fitur keamanan penelusur web',
          ]
        },
        {
          'title': 'Melakukan pencarian informasi',
          'kukCount': '5 KUK',
          'kuks': [
            'Memasukkan kata kunci pencarian yang relevan',
            'Menyaring hasil pencarian berdasarkan relevansi',
            'Mengunduh dokumen informasi yang dibutuhkan',
            'Menyimpan tautan situs web penting (bookmark)',
            'Memastikan keabsahan informasi dari sumber terpercaya',
          ]
        }
      ];
    } else {
      return [
        {
          'title': 'Merencanakan riset produk/merek',
          'kukCount': '4 KUK',
          'kuks': [
            'Menetapkan tujuan riset pemasaran secara jelas',
            'Menentukan metode pengumpulan data riset',
            'Membuat instrumen riset (kuesioner/panduan wawancara)',
            'Menentukan target responden/partisipan riset',
          ]
        },
        {
          'title': 'Mengumpulkan dan mengolah data riset',
          'kukCount': '4 KUK',
          'kuks': [
            'Menyebarkan instrumen riset sesuai target',
            'Memeriksa kelengkapan pengisian data responden',
            'Melakukan tabulasi data riset ke dalam spreadsheet',
            'Membuat visualisasi grafis tren data riset',
          ]
        }
      ];
    }
  }
}

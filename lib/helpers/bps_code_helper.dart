// ============================================================================
// BPS Code Helper
// ============================================================================
// Helper untuk mapping Province ID ke BPS Code (Kode Provinsi Indonesia)

class BpsCodeHelper {
  // BPS Code mapping untuk Provinsi Indonesia
  static const Map<String, int> _provinceMapping = {
    'IDAC': 11, // Aceh
    'IDSU': 12, // Sumatera Utara
    'IDSB': 13, // Sumatera Barat
    'IDRI': 14, // Riau
    'IDJA': 15, // Jambi
    'IDSS': 16, // Sumatera Selatan
    'IDBE': 17, // Bengkulu
    'IDLA': 18, // Lampung
    'IDBB': 19, // Bangka Belitung
    'IDKR': 21, // Kepulauan Riau
    'IDJK': 31, // DKI Jakarta
    'IDJB': 32, // Jawa Barat
    'IDJT': 33, // Jawa Tengah
    'IDYO': 34, // DI Yogyakarta
    'IDJI': 35, // Jawa Timur
    'IDBT': 36, // Banten
    'IDBA': 51, // Bali
    'IDNB': 52, // Nusa Tenggara Barat
    'IDNT': 53, // Nusa Tenggara Timur
    'IDKB': 61, // Kalimantan Barat
    'IDKT': 62, // Kalimantan Tengah
    'IDKS': 63, // Kalimantan Selatan
    'IDKI': 64, // Kalimantan Timur
    'IDKU': 65, // Kalimantan Utara
    'IDSA': 71, // Sulawesi Utara
    'IDST': 72, // Sulawesi Tengah
    'IDSG': 73, // Sulawesi Selatan
    'IDSN': 74, // Sulawesi Tenggara
    'IDGO': 75, // Gorontalo
    'IDSR': 76, // Sulawesi Barat
    'IDMA': 81, // Maluku
    'IDMU': 82, // Maluku Utara
    'IDPB': 91, // Papua Barat
    'IDPA': 92, // Papua
  };

  /// Mendapatkan BPS Code dari Province ID
  /// 
  /// Returns 0 jika province ID tidak ditemukan
  static int getBpsCode(String provinceId) {
    return _provinceMapping[provinceId] ?? 0;
  }

  /// Mengecek apakah province ID valid
  static bool isValidProvinceId(String provinceId) {
    return _provinceMapping.containsKey(provinceId);
  }

  /// Mendapatkan semua province IDs yang tersedia
  static List<String> getAllProvinceIds() {
    return _provinceMapping.keys.toList();
  }

  /// Mendapatkan semua BPS codes yang tersedia
  static List<int> getAllBpsCodes() {
    return _provinceMapping.values.toList();
  }
}

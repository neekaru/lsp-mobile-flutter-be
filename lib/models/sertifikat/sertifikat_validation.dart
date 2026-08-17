// ============================================================================
// Sertifikat Validation Models
// ============================================================================

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

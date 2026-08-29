import '../../models/lead_model.dart';

class ProposalGeneratorService {
  /// Generate draft format pesan WhatsApp untuk pitching ke PIC / Pimpinan institusi
  static String generateWhatsAppPitchText({
    required LeadModel lead,
    required String asesorName,
  }) {
    final institusi = lead.namaInstitusi.isNotEmpty ? lead.namaInstitusi : 'Bapak/Ibu Pimpinan';
    final kategori = lead.leadKategori;
    final jurusan = lead.jurusanList.isNotEmpty
        ? lead.jurusanList.join(', ')
        : 'Teknologi Informasi & Vokasi';
    final asesor = asesorName.isNotEmpty ? asesorName : 'Asesor LSP';

    final text = StringBuffer();
    text.writeln('Yth. Bapak/Ibu Pimpinan / Kaprodi');
    text.writeln('*$institusi*');
    text.writeln('');
    text.writeln('Salam hangat,');
    text.writeln('Perkenalkan saya *$asesor*, Asesor Kompetensi dari *LSP Teknologi Digital* (Lembaga Sertifikasi Profesi berlisensi resmi BNSP).');
    text.writeln('');
    text.writeln('Sehubungan dengan program peningkatan kompetensi dan daya saing lulusan $kategori di bidang *$jurusan*, kami ingin menawarkan program *Kerjasama Penyelenggaraan Uji Kompetensi & Sertifikasi Profesi BNSP*.');
    text.writeln('');
    text.writeln('🎯 *Manfaat Utama Program Sertifikasi BNSP:*');
    text.writeln('1. Sertifikat Kompetensi Nasional Berlogo Garuda Emas dari BNSP.');
    text.writeln('2. Peningkatan serapan kerja lulusan di Industri (DUDI).');
    text.writeln('3. Pemenuhan indikator Akreditasi & Surat Keterangan Pendamping Ijazah (SKPI).');
    text.writeln('4. Peluang Pembentukan TUK (Tempat Uji Kompetensi) Mandiri.');
    text.writeln('');
    if (lead.leadPotensi.isNotEmpty) {
      text.writeln('📊 *Rekomendasi Potensi:*');
      text.writeln(lead.leadPotensi);
      text.writeln('');
    }
    text.writeln('Bersama ini kami bermaksud mengirimkan *Draft Proposal Penawaran Kerjasama* resmi dari LSP Teknologi Digital.');
    text.writeln('');
    text.writeln('Apakah ada waktu yang luang minggu ini untuk kami diskusikan lebih lanjut via Call / Kunjungan Silaturahmi?');
    text.writeln('');
    text.writeln('Terima kasih banyak atas perhatian dan kesediaan Bapak/Ibu.');
    text.writeln('Hormat kami,');
    text.writeln('*$asesor*');
    text.writeln('Asesor Kompetensi - LSP Teknologi Digital');

    return text.toString();
  }

  /// Generate draft proposal lengkap
  static ProposalDocument generateProposalDocument({
    required LeadModel lead,
    required String asesorName,
  }) {
    final now = DateTime.now();
    final nomorSurat = '0${now.month}.${now.day}/LSP-TD/PROP/${now.year}';
    final institusi = lead.namaInstitusi.isNotEmpty ? lead.namaInstitusi : 'Institusi Mitra';
    final asesor = asesorName.isNotEmpty ? asesorName : 'Muhammad Hanafi';

    List<String> skemaList = [];
    switch (lead.leadKategori) {
      case 'SMK':
        skemaList = [
          'Junior Web Developer (Level II KKNI)',
          'Junior Network Administrator (Level II KKNI)',
          'Desain Grafis / DKV Pratama',
          'Pemrograman Dasar Python',
        ];
        break;
      case 'Kampus':
        skemaList = [
          'Software Engineer / Fullstack Developer',
          'Network Administrator Madya',
          'Database Administrator',
          'Data Analyst Associate',
          'Cyber Security Associate',
        ];
        break;
      case 'BLK':
      case 'LPK':
      case 'LKP':
        skemaList = [
          'Digital Marketing Specialist',
          'Teknisi Komputer & Jaringan',
          'Operator Komputer / Office Application',
          'Content Creator & Video Editing',
        ];
        break;
      case 'Dinas Pemda':
      case 'Perusahaan Swasta':
      default:
        skemaList = [
          'IT Governance & SPBE Specialist',
          'Network Security Engineer',
          'Project Manager Bidang TIK',
          'Digital Transformation Officer',
        ];
        break;
    }

    return ProposalDocument(
      nomorSurat: nomorSurat,
      tanggal: now,
      namaInstitusi: institusi,
      alamatInstitusi: lead.leadLocation,
      kategori: lead.leadKategori,
      namaAsesor: asesor,
      skemaRekomendasi: skemaList,
      estimasiPeserta: lead.estimasiSiswa > 0 ? lead.estimasiSiswa : 150,
      jurusan: lead.jurusanList,
      analisisPotensi: lead.leadPotensi,
    );
  }
}

class ProposalDocument {
  final String nomorSurat;
  final DateTime tanggal;
  final String namaInstitusi;
  final String alamatInstitusi;
  final String kategori;
  final String namaAsesor;
  final List<String> skemaRekomendasi;
  final int estimasiPeserta;
  final List<String> jurusan;
  final String analisisPotensi;

  const ProposalDocument({
    required this.nomorSurat,
    required this.tanggal,
    required this.namaInstitusi,
    required this.alamatInstitusi,
    required this.kategori,
    required this.namaAsesor,
    required this.skemaRekomendasi,
    required this.estimasiPeserta,
    required this.jurusan,
    required this.analisisPotensi,
  });
}


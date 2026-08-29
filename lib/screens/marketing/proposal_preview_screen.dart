import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lead_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/marketing/proposal_generator_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class ProposalPreviewScreen extends StatelessWidget {
  final LeadModel lead;

  const ProposalPreviewScreen({super.key, required this.lead});

  Future<void> _copyPitchText(BuildContext context) async {
    final asesorName =
        AuthRepository.currentUserInstance?.name ?? 'Muhammad Hanafi';
    final text = ProposalGeneratorService.generateWhatsAppPitchText(
      lead: lead,
      asesorName: asesorName,
    );

    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft teks proposal/WA berhasil disalin ke clipboard!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendViaWhatsApp(BuildContext context) async {
    final asesorName =
        AuthRepository.currentUserInstance?.name ?? 'Muhammad Hanafi';
    final message = ProposalGeneratorService.generateWhatsAppPitchText(
      lead: lead,
      asesorName: asesorName,
    );

    String phone = lead.telepon.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    final url =
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final asesorName =
        AuthRepository.currentUserInstance?.name ?? 'Muhammad Hanafi';
    final doc = ProposalGeneratorService.generateProposalDocument(
      lead: lead,
      asesorName: asesorName,
    );
    final dateStr =
        DateFormat('dd MMMM yyyy', 'id_ID').format(doc.tanggal);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Proposal Penawaran LSP',
            onBack: () => Navigator.pop(context),
            rightWidget: IconButton(
              icon: const Icon(Icons.copy_rounded, color: Color(0xFF2563EB)),
              onPressed: () => _copyPitchText(context),
              tooltip: 'Salin Teks Pitching',
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Kop Surat
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFE2E8F0), width: 1),
                          ),
                          child: Image.asset('assets/logo.png',
                              fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LEMBAGA SERTIFIKASI PROFESI',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'LSP TEKNOLOGI DIGITAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Lisensi BNSP No: KEP.0275/BNSP/III/2021',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(thickness: 2, color: Color(0xFF0F172A)),
                    const SizedBox(height: 12),

                    // Nomor & Tanggal Surat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'No: ${doc.nomorSurat}',
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Kepada Yth
                    const Text(
                      'Kepada Yth.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Pimpinan / Kepala ${doc.namaInstitusi}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (doc.alamatInstitusi.isNotEmpty) ...[
                      Text(
                        doc.alamatInstitusi,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Perihal
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text(
                        'Perihal: Penawaran Kerjasama Uji Kompetensi & Sertifikasi Profesi BNSP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pembuka
                    const Text(
                      'Dengan hormat,',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sehubungan dengan upaya peningkatan daya saing dan standar kompetensi lulusan di bidang Teknologi Informasi dan Komunikasi (TIK), kami dari LSP Teknologi Digital menawarkan kerjasama pelaksanaan Sertifikasi Profesi Berlisensi BNSP bagi siswa/mahasiswa/peserta di lingkungan ${doc.namaInstitusi}.',
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
                    ),
                    const SizedBox(height: 14),

                    // Skema Rekomendasi
                    const Text(
                      '📌 Rekomendasi Skema Sertifikasi BNSP:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...doc.skemaRekomendasi.map((skema) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB))),
                            Expanded(
                              child: Text(
                                skema,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 14),

                    // Manfaat Kerjasama
                    const Text(
                      '🎯 Manfaat Penyelenggaraan:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildBenefitItem(
                        '1', 'Sertifikat Kompetensi resmi berlogo Garuda Emas BNSP diakui secara nasional & internasional.'),
                    _buildBenefitItem(
                        '2', 'Meningkatkan akreditasi institusi dan dokumen pendamping ijazah (SKPI).'),
                    _buildBenefitItem(
                        '3', 'Fasilitasi pembentukan Tempat Uji Kompetensi (TUK) Mandiri di lokasi institusi.'),
                    const SizedBox(height: 16),

                    // Tanda Tangan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Hormat kami,\nAsesor Pengusul Program,',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 36),
                            Text(
                              doc.namaAsesor,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const Text(
                              'LSP Teknologi Digital',
                              style: TextStyle(
                                  fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyPitchText(context),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin Draft',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sendViaWhatsApp(context),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Kirim ke WA',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF475569), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}


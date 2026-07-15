import 'package:flutter/material.dart';
import '../../models/sertifikat_models.dart';
import '../../widgets/custom_app_bar.dart';

class DetailSertifikatScreen extends StatelessWidget {
  final SertifikatItem item;

  const DetailSertifikatScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Detail Sertifikat',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Certificate Top Status Banner Card
                  _buildHeaderCard(),
                  const SizedBox(height: 20),

                  // Detail Information Group 1: Informasi Pemegang & Skema
                  _buildSectionHeader('Informasi Skema & Pemegang'),
                  const SizedBox(height: 8),
                  _buildInfoCard([
                    _buildInfoRow('Nama Pemegang', item.pemegang, Icons.person_outline_rounded),
                    _buildInfoDivider(),
                    _buildInfoRow('Skema Sertifikasi', item.skema, Icons.assignment_outlined),
                    _buildInfoDivider(),
                    _buildInfoRow('Tempat Uji (TUK)', item.tempatUji, Icons.business_outlined),
                    _buildInfoDivider(),
                    _buildInfoRow('Asesor', item.namaAsesor, Icons.record_voice_over_outlined),
                  ]),
                  const SizedBox(height: 20),

                  // Detail Information Group 2: Dokumen Sertifikat
                  _buildSectionHeader('Nomor & Dokumen'),
                  const SizedBox(height: 8),
                  _buildInfoCard([
                    _buildInfoRow('No. Registrasi', item.nomorRegistrasi, Icons.badge_outlined),
                    _buildInfoDivider(),
                    _buildInfoRow('No. Sertifikat', item.nomorSertifikat, Icons.workspace_premium_outlined),
                    _buildInfoDivider(),
                    _buildInfoRow('No. Blanko', item.nomorBlanko, Icons.description_outlined),
                    _buildInfoDivider(),
                    _buildInfoRow('No. Seri', item.nomorSeri, Icons.tag_rounded),
                  ]),
                  const SizedBox(height: 20),

                  // Detail Information Group 3: Masa Berlaku
                  _buildSectionHeader('Masa Berlaku'),
                  const SizedBox(height: 8),
                  _buildInfoCard([
                    _buildInfoRow('Diterbitkan Kapan', item.tanggalTerbit, Icons.calendar_today_outlined),
                    _buildInfoDivider(),
                    _buildInfoRow('Berlaku Sampai', item.tanggalBerlaku, Icons.event_busy_outlined),
                  ]),
                  const SizedBox(height: 24),

                  // Footnote Keterangan
                  _buildFootnoteCard(),
                  const SizedBox(height: 32),

                  // Download Button
                  _buildDownloadButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    bool isActive = item.status.toLowerCase() == 'aktif';
    bool isPending = item.status.toLowerCase() == 'akan_kadaluarsa';

    Color bannerColor = isActive
        ? const Color(0xFF10B981)
        : (isPending ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    Color bannerBgColor = isActive
        ? const Color(0xFFECFDF5)
        : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2));
    String statusText = isActive
        ? 'Sertifikat Aktif'
        : (isPending ? 'Sertifikat Akan Berakhir' : 'Sertifikat Kadaluarsa');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bannerBgColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: bannerColor.withAlpha(76)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive
                      ? Icons.check_circle_outline_rounded
                      : (isPending ? Icons.warning_amber_rounded : Icons.cancel_outlined),
                  color: bannerColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: bannerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.skema,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'No. Regis: ${item.nomorRegistrasi}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF475569),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }

  Widget _buildFootnoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD97706),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Keterangan: Sertifikat ini akan berakhir pada ${item.tanggalBerlaku}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mengunduh sertifikat ${item.skema}...'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.download_rounded, size: 20),
        label: const Text(
          'Download Sertifikat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B9FD8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

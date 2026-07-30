import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/status_notification_dialog.dart';
import 'edit_pendaftaran_screen.dart';

class DetailPermohonanScreen extends StatelessWidget {
  final Map<String, String> itemData;

  const DetailPermohonanScreen({
    super.key,
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = itemData['status'] == 'Terverifikasi' || itemData['status'] == 'Terferivikasi';
    final nama = itemData['nama'] ?? 'Aldi Taher';
    final skema = itemData['skema'] ?? 'Digital Marketing';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Detail Permohonan',
              onBack: () => Navigator.pop(context),
            ),

          // Main Scrollable Content Body matching Screenshot
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ==========================================================
                  // 1. Profile Header Card
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Icon Box
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: Color(0xFF3B82F6),
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name, Skema, & No UJK
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                skema,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'No UJK : 987577382222',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isVerified ? 'Terverifikasi' : 'Menunggu',
                            style: TextStyle(
                              color: isVerified ? const Color(0xFF10B981) : const Color(0xFFD97706),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==========================================================
                  // 2. Information Details Card
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tanggal Daftar',
                          value: '${itemData['tanggal'] ?? '20/07/2026'} ${itemData['jam'] ?? '09:03:54'}',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Asessor',
                          value: 'Karina',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Jadwal Uji\nKompetensi',
                          value: '26/07/2026 - 09:00 WIB',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Tempat Uji\nKompetensi',
                          value: 'LPP Semarang',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Lembaga/\nPerusahaan',
                          value: 'SMA 5 Semarang,\nJl. Bahagia, Semarang.',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==========================================================
                  // 3. Action Cards (Edit Data, Unduh Data, Hapus Data)
                  // ==========================================================
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    iconColor: const Color(0xFF3B82F6),
                    label: 'Edit Data',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPendaftaranScreen(
                            namaPemohon: nama,
                            skemaSertifikasi: skema,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildActionButton(
                    icon: Icons.download_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: 'Unduh Data',
                    onTap: () {
                      StatusNotificationDialog.showSuccess(
                        context: context,
                        title: 'Dokumen Berhasil Diunduh',
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildActionButton(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFEF4444),
                    label: 'Hapus Data',
                    onTap: () {
                      StatusNotificationDialog.showError(
                        context: context,
                        title: 'Yakin Ingin Menghapus Data?',
                        buttonText: 'Hapus',
                        onOk: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

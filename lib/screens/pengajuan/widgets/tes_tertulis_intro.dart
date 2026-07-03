import 'package:flutter/material.dart';
import '../../../widgets/custom_app_bar.dart';

class TesTertulisIntro extends StatelessWidget {
  final String title;
  final int questionsCount;
  final VoidCallback onStartTest;
  final VoidCallback onBack;

  const TesTertulisIntro({
    super.key,
    required this.title,
    required this.questionsCount,
    required this.onStartTest,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Tes Tertulis',
            onBack: onBack,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tes Tertulis',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tahap terpenting untuk menguji kemampuan Anda sesuai Skema Sertifikasi',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF1E40AF),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment_rounded,
                            color: Color(0xFF3B82F6),
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informasi Tes Tertulis',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Skema Sertifikasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDD5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Belum Dikerjakan',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.assignment_outlined,
                          iconColor: const Color(0xFF3B82F6),
                          bgColor: const Color(0xFFDBEAFE),
                          title: 'Jumlah Soal',
                          subtitle: '$questionsCount Soal',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoItem(
                          icon: Icons.workspace_premium_outlined,
                          iconColor: const Color(0xFFD97706),
                          bgColor: const Color(0xFFFEF3C7),
                          title: 'Nilai Kelulusan',
                          subtitle: '70 total nilai',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoItem(
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFDCFCE7),
                          title: 'Durasi Ujian',
                          subtitle: '60 Menit',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEEAD2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Informasi Pengerjaan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint('1. Pastikan koneksi internet lancar'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('2. Kerjakan semua soal secara mandiri.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('3. Waktu akan berjalan setelah tes di mulai, sesuai dengan peraturan.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('4. Jawaban Anda akan tersimpan otomatis.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint('5. Pastikan semua soal terjawab sebelum mengirim test atau waktu yang ditentukan habis.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: onStartTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9FD8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Mulai Test',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF92400E),
        height: 1.45,
      ),
    );
  }
}

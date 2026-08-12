import 'package:flutter/material.dart';

/// Layar detail struktur organisasi / tugas pengurus LSP.
class AdminOrganisasiDetailScreen extends StatelessWidget {
  final String type;
  final String title;

  const AdminOrganisasiDetailScreen({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (type) {
      case 'struktur':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bagan Struktur Organisasi LSP TD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Berdasarkan ketetapan dan lisensi BNSP, berikut pembagian struktur utama:',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            _buildHierarchyNode('Dewan Pengarah / Pleno', isRoot: true),
            _buildHierarchyArrow(),
            _buildHierarchyNode('Direktur Utama / Pimpinan LSP'),
            _buildHierarchyArrow(),
            Row(
              children: [
                Expanded(child: _buildHierarchyNode('Komite Skema')),
                const SizedBox(width: 12),
                Expanded(child: _buildHierarchyNode('Bagian Manajemen Mutu')),
              ],
            ),
            _buildHierarchyArrow(),
            Row(
              children: [
                Expanded(
                  child: _buildHierarchyNode('Bagian Sertifikasi & Asesmen'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHierarchyNode('Bagian Administrasi & IT'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Fungsi Utama',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Struktur di atas memastikan pemisahan fungsi yang jelas antara perumus kebijakan (Pengarah), penjamin mutu sertifikasi (Mutu & Skema), serta pelaksana operasional teknis asesi (Sertifikasi & Administrasi).',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
          ],
        );
      case 'tugas':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tugas & Tanggung Jawab LSP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildTaskItem(
              '1',
              'Mengembangkan Skema Sertifikasi',
              'Membuat dan memperbarui skema kompetensi kerja nasional di bidang teknologi informasi sesuai kebutuhan pasar industri.',
            ),
            _buildTaskItem(
              '2',
              'Melaksanakan Asesmen / Uji Kompetensi',
              'Menyelenggarakan ujian teori dan praktik secara adil, objektif, dan sistematis bagi calon tenaga kerja profesional.',
            ),
            _buildTaskItem(
              '3',
              'Menerbitkan Sertifikat Kompetensi',
              'Memberikan sertifikasi kompetensi resmi berstandar BNSP kepada peserta yang dinyatakan kompeten.',
            ),
            _buildTaskItem(
              '4',
              'Memelihara & Meninjau Kompetensi',
              'Melakukan monitoring berkala terhadap pemegang sertifikat guna menjaga relevansi keterampilan mereka.',
            ),
            _buildTaskItem(
              '5',
              'Verifikasi Tempat Uji Kompetensi (TUK)',
              'Melakukan audit kelayakan fasilitas penunjang asesmen di berbagai instansi mitra.',
            ),
          ],
        );
      case 'pengurus':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unsur Pengurus Operasional',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pengurus operasional bertanggung jawab penuh atas kegiatan administratif dan teknis harian LSP.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            _buildMemberTile('Roni Gunawan, M.T.', 'Direktur Utama LSP'),
            _buildMemberTile(
              'Siti Aminah, S.Kom.',
              'Manajer Sertifikasi & Asesmen',
            ),
            _buildMemberTile(
              'Andi Wijaya, M.Sc.',
              'Manajer Penjaminan Mutu',
            ),
            _buildMemberTile(
              'Riana Fitriani, A.Md.',
              'Kepala Administrasi & Keuangan',
            ),
            _buildMemberTile(
              'Dani Setiawan, S.T.',
              'Kepala Divisi IT & Sistem Informasi',
            ),
          ],
        );
      default:
        return const Center(child: Text('Data tidak ditemukan'));
    }
  }

  Widget _buildHierarchyNode(String title, {bool isRoot = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isRoot ? const Color(0xFF0284C7) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isRoot ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isRoot ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildHierarchyArrow() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Icon(
          Icons.arrow_downward_rounded,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTaskItem(String number, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(String name, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../sertifikat/skema_sertifikasi_screen.dart';

class AsesorMarketingScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AsesorMarketingScreen({super.key, this.onBackToHome});

  @override
  State<AsesorMarketingScreen> createState() => _AsesorMarketingScreenState();
}

class _AsesorMarketingScreenState extends State<AsesorMarketingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Teknologi Informasi',
    'Digital Marketing',
    'Multimedia & Desain',
    'Jaringan & Cyber',
  ];

  final List<Map<String, dynamic>> _promoSchemes = [
    {
      'title': 'Digital Marketing Specialist',
      'kode': 'SKM-DM-2026',
      'category': 'Digital Marketing',
      'peserta': '320+ Asesi Terdaftar',
      'color': const Color(0xFF2563EB),
      'icon': Icons.campaign_rounded,
      'description':
          'Skema sertifikasi pengelolaan kampanye digital, SEO, SEM, content strategy, dan analytics.',
    },
    {
      'title': 'Junior Web Developer',
      'kode': 'SKM-JWD-2026',
      'category': 'Teknologi Informasi',
      'peserta': '450+ Asesi Terdaftar',
      'color': const Color(0xFF0D9488),
      'icon': Icons.code_rounded,
      'description':
          'Standar kompetensi pengembangan aplikasi web front-end dan back-end berbasis framework.',
    },
    {
      'title': 'Desainer Grafis Muda',
      'kode': 'SKM-DGM-2026',
      'category': 'Multimedia & Desain',
      'peserta': '280+ Asesi Terdaftar',
      'color': const Color(0xFFEA580C),
      'icon': Icons.palette_rounded,
      'description':
          'Keahlian perancangan aset visual, branding, tipografi, dan layout media cetak/digital.',
    },
    {
      'title': 'Network Administrator Pratama',
      'kode': 'SKM-NAP-2026',
      'category': 'Jaringan & Cyber',
      'peserta': '190+ Asesi Terdaftar',
      'color': const Color(0xFF7C3AED),
      'icon': Icons.hub_rounded,
      'description':
          'Kompetensi konfigurasi routing, switching, subnetting, dan pemeliharaan keamanan jaringan.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final filteredSchemes = _promoSchemes.where((scheme) {
      final matchesCat = _selectedCategory == 'Semua' ||
          scheme['category'] == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          scheme['title']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          scheme['kode']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Marketing & Promosi',
            onBack: widget.onBackToHome,
            rightWidget: const SizedBox(width: 32),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 400));
                if (mounted) setState(() {});
              },
              color: const Color(0xFF2563EB),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // Hero Marketing Banner
                  _buildHeroBanner(),
                  const SizedBox(height: 18),

                  // Quick Action Tools
                  _buildQuickActionTools(),
                  const SizedBox(height: 20),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  _buildCategoryFilterChips(),
                  const SizedBox(height: 16),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Skema Unggulan Promosi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SkemaSertifikasiScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Semua Skema',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List of Promo Schemes
                  if (filteredSchemes.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredSchemes.map((scheme) => _buildSchemeCard(scheme)),

                  const SizedBox(height: 18),

                  // Marketing Support Contact
                  _buildMarketingContactCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Program Kemitraan & Sertifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Bagikan informasi skema uji kompetensi LSP kepada mitra TUK, SMK, Perguruan Tinggi, dan calon asesi profesional.',
            style: TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTools() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.menu_book_rounded,
            title: 'Katalog Skema',
            subtitle: 'Lihat seluruh skema',
            color: const Color(0xFF0284C7),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkemaSertifikasiScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionCard(
            icon: Icons.share_rounded,
            title: 'Bagikan Brosur',
            subtitle: 'Materi promosi digital',
            color: const Color(0xFF059669),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan brosur promosi siap dibagikan.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF059669),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Cari materi atau skema promosi...',
                hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18),
              color: const Color(0xFF94A3B8),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSchemeCard(Map<String, dynamic> scheme) {
    final Color color = scheme['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  scheme['icon'] as IconData,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme['title'] as String,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      scheme['kode'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  scheme['peserta'] as String,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            scheme['description'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Link promosi untuk ${scheme['title']} telah disalin.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF2563EB),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.link_rounded, size: 15),
                label: const Text('Salin Link Pendaftaran'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingContactCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.headset_mic_rounded,
            color: Color(0xFF2563EB),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh Bantuan Marketing LSP?',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hubungi tim kemitraan untuk proposal & kerjasama TUK.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 8),
          Text(
            'Tidak ada skema promosi yang cocok',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
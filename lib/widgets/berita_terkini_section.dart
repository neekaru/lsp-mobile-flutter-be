import 'package:flutter/material.dart';
import '../models/berita_model.dart';
import '../screens/dashboard/berita_screen.dart';
import '../screens/dashboard/berita_detail_screen.dart';

class BeritaTerkiniSection extends StatelessWidget {
  final List<BeritaItem>? data;
  final bool isLoading;

  const BeritaTerkiniSection({
    super.key,
    required this.data,
    required this.isLoading,
  });


  @override
  Widget build(BuildContext context) {
    // If not loading and there's no data, hide the section
    if (!isLoading && (data == null || data!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row (Title and "Lihat semua >")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berita Terkini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A), // Slate-900
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BeritaScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6), // Premium blue accent
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF3B82F6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Horizontal news list
        SizedBox(
          height: 145,
          child: isLoading
              ? _buildShimmerLoading()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    final item = data![index];
                    return _buildBeritaCard(context, item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBeritaCard(BuildContext context, BeritaItem item) {
    final String? imageUrl = item.foto != null && item.foto!.isNotEmpty
        ? 'https://mobile.lspdigital.id/upload/foto_berita/${item.foto}'
        : null;

    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9), // Light slate border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BeritaDetailScreen(beritaId: item.id),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(item.judul),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF8FAFC),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : _buildImagePlaceholder(item.judul),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), Color(0xFF2563EB)], // Soft gradient blue
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.newspaper_rounded,
              size: 70,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.newspaper_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          width: 220,
          margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: const Color(0xFFF1F5F9),
              ),
            ),
          ),
        );
      },
    );
  }
}

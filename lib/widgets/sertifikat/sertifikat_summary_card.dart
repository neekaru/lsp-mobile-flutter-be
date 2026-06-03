import 'package:flutter/material.dart';

class SertifikatSummaryCard extends StatelessWidget {
  final String totalPemegang;
  final String totalSkema;
  final String? topSkemaName;
  final String? topSkemaPemegang;
  final String? trendPemegang;
  final String? trendSkema;
  final String? trendPemegangDirection;
  final String? trendSkemaDirection;

  const SertifikatSummaryCard({
    super.key,
    required this.totalPemegang,
    required this.totalSkema,
    this.topSkemaName,
    this.topSkemaPemegang,
    this.trendPemegang,
    this.trendSkema,
    this.trendPemegangDirection,
    this.trendSkemaDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Section 1: Total Pemegang Sertifikat
            Expanded(
              child: _buildSummaryColumn(
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF1E6CBE),
                iconBgColor: const Color(0xFFD4E7F9),
                title: 'Total Pemegang Sertifikat',
                titleColor: const Color(0xFF1D5A9E),
                value: totalPemegang,
                valueColor: const Color(0xFF339AF0),
                sublabel: 'Orang',
                percentage: trendPemegang ?? '+0.0%',
                direction: trendPemegangDirection ?? 'stable',
              ),
            ),
            
            // Divider 1
            const VerticalDivider(
              color: Color(0xFFE5E5E5),
              thickness: 1,
              width: 16,
              indent: 4,
              endIndent: 4,
            ),
            
            // Section 2: Total Skema
            Expanded(
              child: _buildSummaryColumn(
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF27AE60),
                iconBgColor: const Color(0xFFD3F2E3),
                title: 'Total Skema',
                titleColor: const Color(0xFF1B6A42),
                value: totalSkema,
                valueColor: const Color(0xFF2ECC71),
                sublabel: 'Skema',
                percentage: trendSkema ?? '+0.0%',
                direction: trendSkemaDirection ?? 'stable',
              ),
            ),
            
            // Divider 2
            const VerticalDivider(
              color: Color(0xFFE5E5E5),
              thickness: 1,
              width: 16,
              indent: 4,
              endIndent: 4,
            ),
            
            // Section 3: Tren Skema Teratas
            Expanded(
              child: _buildSummaryColumn(
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFFD35400),
                iconBgColor: const Color(0xFFFDE8D4),
                title: 'Tren Skema Teratas',
                titleColor: const Color(0xFFB05B17),
                value: topSkemaName ?? 'N/A',
                valueColor: const Color(0xFFE67E22),
                sublabel: topSkemaPemegang ?? 'Tidak ada data',
                percentage: null, // No trend for top skema
                direction: 'stable',
                isTextValue: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryColumn({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required Color titleColor,
    required String value,
    required Color valueColor,
    required String sublabel,
    required String? percentage,
    required String direction,
    bool isTextValue = false,
  }) {
    // Determine icon and color based on direction
    IconData trendIcon;
    Color trendColor;
    
    if (direction == 'up') {
      trendIcon = Icons.arrow_drop_up_rounded;
      trendColor = const Color(0xFF4CAF50);
    } else if (direction == 'down') {
      trendIcon = Icons.arrow_drop_down_rounded;
      trendColor = const Color(0xFFE74C3C);
    } else {
      trendIcon = Icons.remove_rounded;
      trendColor = const Color(0xFF95A5A6);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        
        // Right Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTextValue ? 12 : 20,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (percentage != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendIcon,
                      color: trendColor,
                      size: 14,
                    ),
                    Text(
                      percentage,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

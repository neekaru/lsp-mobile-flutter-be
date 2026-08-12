import 'package:flutter/material.dart';

import '../../models/jadwal_models.dart';
import '../../screens/jadwal/profil_asesor_screen.dart';

/// Item daftar asesor rekomendasi — buka [ProfilAsesorScreen] saat diketuk.
class AsesorListItem extends StatelessWidget {
  final AsesorDetailItem asesor;
  final String skemaTitle;

  const AsesorListItem({
    super.key,
    required this.asesor,
    required this.skemaTitle,
  });

  // Static const to avoid re-allocation on every build
  static const _cardMargin = EdgeInsets.only(bottom: 12);
  static const _cardPadding = EdgeInsets.all(16.0);
  static const _cardRadius = BorderRadius.all(Radius.circular(8));
  static const _cardDecoration = BoxDecoration(
    color: Color(0xFFFAFAFA),
    borderRadius: _cardRadius,
    border: Border.fromBorderSide(
      BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
    ),
  );
  static const _avatarDecoration = BoxDecoration(
    color: Color(0xFFE2E8F0),
    shape: BoxShape.circle,
  );
  static const _nameStyle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F172A),
  );
  static const _locationStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF64748B),
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _cardMargin,
      decoration: _cardDecoration,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilAsesorScreen(
                name: asesor.namaAsesor,
                skema: skemaTitle,
                lokasi: asesor.kabupatenKota,
                asesorDetail: asesor,
              ),
            ),
          );
        },
        borderRadius: _cardRadius,
        child: Padding(
          padding: _cardPadding,
          child: Row(
            children: [
              const DecoratedBox(
                decoration: _avatarDecoration,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asesor.namaAsesor, style: _nameStyle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            asesor.kabupatenKota,
                            style: _locationStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Widget & helper dasar bersama untuk form asesi (APL-01, APL-02, AK-01..AK-05).
//
// Diekstrak dari asesi_form_sections.dart agar tiap bagian form (APL/AK/kartu
// info) menjadi modul tersendiri.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/asesor_asesi_models.dart';
import '../../services/api_service.dart';
import '../../utils/url_helper.dart';

Future<void> _openDocumentUrl(BuildContext context, String? rawUrl) async {
  if (rawUrl == null || rawUrl.trim().isEmpty) return;
  final fullUrl = UrlHelper.resolveUrl(rawUrl);
  final uri = Uri.tryParse(fullUrl);
  if (uri != null) {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka file: $fullUrl')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka file: $e')),
        );
      }
    }
  }
}

/// Row label–nilai standar untuk detail asesi.
class AsesiDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const AsesiDetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu status header form (judul + badge status).
class FormSectionHeader extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.status,
    this.statusColor = const Color(0xFF059669),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Container kartu putih standar untuk section form.
class FormSectionCard extends StatelessWidget {
  final Widget child;

  const FormSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }
}

/// Item bukti dokumen (APL-01).
class DocItem extends StatelessWidget {
  final String name;
  final String jenis;
  final bool ada;
  final String? url;
  final int? index;

  const DocItem({
    super.key,
    required this.name,
    required this.jenis,
    required this.ada,
    this.url,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    final isClickable = ada && hasUrl;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: ada ? const Color(0xFFF8FAFC) : const Color(0xFFFDF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ada ? const Color(0xFFE2E8F0) : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(
              ada ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 18,
              color: ada ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index != null)
                      Text(
                        '$index. ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ada ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: jenis == 'Wajib'
                            ? const Color(0xFFFEF2F2)
                            : (jenis == 'Administratif'
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFEFF6FF)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        jenis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: jenis == 'Wajib'
                              ? const Color(0xFFDC2626)
                              : (jenis == 'Administratif'
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF2563EB)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (isClickable)
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _openDocumentUrl(context, url),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            LucideIcons.external_link,
                            size: 13,
                            color: Color(0xFF2563EB),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Buka Dokumen',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    ada ? 'Dokumen terlampir' : 'Belum diunggah',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: ada ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
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

/// Stat mini (APL-02).
class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color textCol;
  final Color bgCol;

  const MiniStat(this.label, this.value, this.textCol, this.bgCol, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item unit kompetensi (APL-02).
class UnitItem extends StatelessWidget {
  final APL02UnitItem unit;

  const UnitItem({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final isK = unit.statusKompeten == 'K';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isK ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              unit.statusKompeten,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isK ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unit.kodeUnit.isNotEmpty)
                  Text(
                    unit.kodeUnit,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                Text(
                  unit.judulUnit,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
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

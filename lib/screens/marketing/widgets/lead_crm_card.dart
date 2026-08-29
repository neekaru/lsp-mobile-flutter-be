import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';
import 'lead_status_badge.dart';

class LeadCrmCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback onTap;
  final VoidCallback onWhatsApp;
  final VoidCallback onProposal;
  final Function(String newStatus) onStatusChange;

  const LeadCrmCard({
    super.key,
    required this.lead,
    required this.onTap,
    required this.onWhatsApp,
    required this.onProposal,
    required this.onStatusChange,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'SMK':
        return const Color(0xFF2563EB);
      case 'Kampus':
        return const Color(0xFF7C3AED);
      case 'BLK':
        return const Color(0xFF059669);
      case 'LPK':
      case 'LKP':
        return const Color(0xFFD97706);
      case 'Dinas Pemda':
        return const Color(0xFFDC2626);
      case 'Perusahaan Swasta':
      default:
        return const Color(0xFF0F172A);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'SMK':
        return Icons.school_rounded;
      case 'Kampus':
        return Icons.account_balance_rounded;
      case 'BLK':
        return Icons.build_circle_rounded;
      case 'LPK':
      case 'LKP':
        return Icons.menu_book_rounded;
      case 'Dinas Pemda':
        return Icons.domain_rounded;
      case 'Perusahaan Swasta':
      default:
        return Icons.business_center_rounded;
    }
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Tahapan Prospek',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusOption(context, 'lead', 'Lead Terdata',
                    'Baru ditambahkan dari peta / pencarian', Icons.bookmark_border_rounded),
                _buildStatusOption(context, 'prospek', 'Kirim Proposal',
                    'Tahap pengiriman draft proposal kerjasama', Icons.send_rounded),
                _buildStatusOption(context, 'interest', 'Follow Up / Minat',
                    'Diskusi teknis skema & tanggal uji', Icons.forum_rounded),
                _buildStatusOption(context, 'sales', 'Deal / Kerjasama',
                    'MoU disepakati & siap pelaksanaan asesmen', Icons.check_circle_rounded),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String statusKey,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isCurrent = lead.leadStatus.toLowerCase() == statusKey.toLowerCase();
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onStatusChange(statusKey);
      },
      leading: Icon(
        icon,
        color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF64748B),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
          color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
      ),
      trailing: isCurrent
          ? const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 20)
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getCategoryColor(lead.leadKategori);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tag + Status Badge + Status Change Icon
            Row(
              children: [
                // Category Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getCategoryIcon(lead.leadKategori),
                          size: 13, color: themeColor),
                      const SizedBox(width: 4),
                      Text(
                        lead.leadKategori,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showStatusPicker(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LeadStatusBadge(status: lead.leadStatus, isSmall: true),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_rounded,
                          size: 18, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Institution Name & Address
            Text(
              lead.namaInstitusi,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              lead.leadLocation,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Potensi / AI Estimasi Box
            if (lead.estimasiSiswa > 0 || lead.jurusanList.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 14, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lead.estimasiSiswa > 0
                            ? 'Estimasi ±${lead.estimasiSiswa} Calon Asesi/Th (${lead.jurusanList.isNotEmpty ? lead.jurusanList.take(2).join(', ') : 'Vokasi'})'
                            : (lead.jurusanList.isNotEmpty
                                ? lead.jurusanList.join(', ')
                                : 'Potensi Uji Kompetensi BNSP'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Action Buttons: Chat WA + Proposal + Detail
            Row(
              children: [
                if (lead.picName.isNotEmpty) ...[
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin_rounded,
                            size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lead.picName,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ],
                // WA Pitch Button
                InkWell(
                  onTap: onWhatsApp,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_rounded,
                            size: 14, color: Color(0xFF16A34A)),
                        SizedBox(width: 4),
                        Text(
                          'WA',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Proposal Button
                InkWell(
                  onTap: onProposal,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_rounded,
                            size: 14, color: Color(0xFF2563EB)),
                        SizedBox(width: 4),
                        Text(
                          'Proposal',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


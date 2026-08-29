import 'package:material_ui/material_ui.dart';

class LeadStatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const LeadStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'lead':
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        label = 'Lead Terdata';
        icon = Icons.bookmark_border_rounded;
        break;
      case 'prospek':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        label = 'Kirim Proposal';
        icon = Icons.send_rounded;
        break;
      case 'interest':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        label = 'Follow Up / Minat';
        icon = Icons.forum_rounded;
        break;
      case 'sales':
      case 'deal':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'Deal / Kerjasama';
        icon = Icons.check_circle_rounded;
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = status.toUpperCase();
        icon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}


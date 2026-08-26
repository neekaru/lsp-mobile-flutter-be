// ============================================================================
// Helper warna/ikon/format untuk modul Lead Generator.
// Diekstrak dari lead_generator_screen.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

Color leadStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'sales':
      return const Color(0xFF16A34A);
    case 'interest':
      return const Color(0xFF2563EB);
    case 'prospek':
      return const Color(0xFFD97706);
    case 'lead':
    default:
      return const Color(0xFF64748B);
  }
}

Color leadCategoryColor(String cat) {
  switch (cat) {
    case 'SMK':
      return const Color(0xFF2563EB);
    case 'Kampus':
      return const Color(0xFF7C3AED);
    case 'LPK':
    case 'LKP':
      return const Color(0xFF0D9488);
    case 'BLK':
      return const Color(0xFFEA580C);
    case 'Dinas Pemda':
      return const Color(0xFF0284C7);
    case 'Perusahaan Swasta':
      return const Color(0xFF4F46E5);
    default:
      return const Color(0xFF64748B);
  }
}

IconData leadCategoryIcon(String cat) {
  switch (cat) {
    case 'SMK':
      return LucideIcons.graduation_cap;
    case 'Kampus':
      return LucideIcons.building;
    case 'LPK':
    case 'LKP':
      return LucideIcons.award;
    case 'BLK':
      return LucideIcons.hammer;
    case 'Dinas Pemda':
      return LucideIcons.landmark;
    case 'Perusahaan Swasta':
      return LucideIcons.briefcase;
    default:
      return LucideIcons.map_pin;
  }
}

String formatLeadStatus(String status) {
  switch (status.toLowerCase()) {
    case 'sales':
      return 'Sales';
    case 'interest':
      return 'Interest';
    case 'prospek':
      return 'Prospek';
    case 'lead':
    default:
      return 'Lead';
  }
}

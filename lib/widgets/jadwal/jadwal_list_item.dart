import 'package:material_ui/material_ui.dart';
import '../../models/jadwal_models.dart';
import '../../services/auth/auth_repository.dart';
import 'jadwal_admin_card.dart';
import 'jadwal_asesi_card.dart';
import 'jadwal_asesor_card.dart';

class JadwalListItem extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;

  /// Tampilkan tanggal dibuat (created_when) sebagai pengganti tanggal
  /// selesai. Hanya dipakai di tab Draft admin.
  final bool showCreatedDate;

  const JadwalListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.showCreatedDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final role = AuthRepository.currentUserInstance?.role;
    final bool isAsesi = role == 'asesi';
    final bool isAsesor = role == 'asesor';

    if (isAsesi) {
      return JadwalAsesiCard(item: item, onTap: onTap);
    }
    if (isAsesor) {
      return JadwalAsesorCard(item: item, onTap: onTap);
    }

    return JadwalAdminCard(
      item: item,
      onTap: onTap,
      showCreatedDate: showCreatedDate,
    );
  }
}

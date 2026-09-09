import 'package:material_ui/material_ui.dart';
import '../../models/jadwal_models.dart';
import '../../services/auth/auth_repository.dart';

/// Tombol pindah asesi ke asesor lain (kanan bawah card).
/// Null bila caller bukan asesor pemilik asesi tersebut dan asesi tidak dalam status Tidak Hadir.
Widget? buildAsesiTransferButton({
  required AsesiItem item,
  required bool isJadwalSelesai,
  required int? transferringAsesiId,
  required VoidCallback onTap,
}) {
  final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
  final hasAsesor = (item.idAsesor ?? 0) > 0;
  final isAbsent = item.isAbsent;
  if (isJadwalSelesai || !isAsesor || (!item.isMyAsesi && !isAbsent) || !hasAsesor) return null;

  final isFinal = !isAbsent && (item.rekomendasiAsesor == '1' ||
      item.rekomendasiAsesor == '2' ||
      item.hasilRekomendasi == 'K' ||
      item.hasilRekomendasi == 'BK');
  final isProcessing = transferringAsesiId == item.id;
  final canTransfer = !isFinal && transferringAsesiId == null;

  final tooltipMsg = isFinal
      ? 'Rekomendasi sudah final, asesi tidak dapat dipindahkan'
      : (isAbsent
          ? 'Pindahkan atau batalkan status tidak hadir'
          : 'Pindahkan ke asesor lain');

  return Tooltip(
    message: tooltipMsg,
    child: InkWell(
      key: ValueKey('transfer-asesi-${item.id}'),
      onTap: canTransfer ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: canTransfer
              ? const Color(0xFFEFF6FF)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canTransfer
                ? const Color(0xFFBFDBFE)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Center(
          child: isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.swap_horiz_rounded,
                  size: 18,
                  color: canTransfer
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                ),
        ),
      ),
    ),
  );
}

Future<bool?> showAsesiTransferConfirmDialog(
  BuildContext context, {
  required AsesiItem item,
  required AsesorDetailItem target,
}) {
  final isTargetTidakHadir = target.idAsesor == 99999 || target.idAsesor == 9999;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        isTargetTidakHadir ? 'Tandai Tidak Hadir' : 'Pindahkan Asesi',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: Text(
        isTargetTidakHadir
            ? 'Tandai ${item.namaLengkap} sebagai Tidak Hadir pada jadwal ini?'
            : 'Pindahkan ${item.namaLengkap} dari ${item.namaAsesor?.isNotEmpty == true ? item.namaAsesor : (item.isAbsent ? "status Tidak Hadir" : "asesor saat ini")} ke ${target.namaAsesor}?',
        style: const TextStyle(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isTargetTidakHadir
                ? const Color(0xFFDC2626)
                : const Color(0xFF2563EB),
          ),
          child: Text(
            isTargetTidakHadir ? 'Ya, Tidak Hadir' : 'Pindahkan',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

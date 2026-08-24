import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../../models/blanko_models.dart';
import '../../../models/jadwal_models.dart';
import '../../../utils/date_format_helper.dart';
import '../../jadwal/jadwal_detail_screen.dart';

/// Menampilkan daftar Jadwal Asesmen / Jadwal ID sebagai item interaktif yang rapi.
///
/// - Jika tersedia [jadwalList], menampilkan card lengkap (Nama Jadwal, Tanggal, TUK).
/// - Bisa diklik untuk langsung membuka detail jadwal asesmen terkait.
/// - Jika hanya ada [jadwalIds], menampilkan chip ID yang bisa disalin dan diklik.
class BlankoJadwalIdChips extends StatelessWidget {
  final List<String> jadwalIds;
  final List<BlankoJadwalDetailItem>? jadwalList;
  final int maxPreview;

  const BlankoJadwalIdChips({
    super.key,
    required this.jadwalIds,
    this.jadwalList,
    this.maxPreview = 3,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Jika ada list detail jadwal yang kaya informasi
    if (jadwalList != null && jadwalList!.isNotEmpty) {
      final preview = jadwalList!.take(maxPreview).toList();
      final remaining = jadwalList!.length - preview.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...preview.map((item) => _buildJadwalCard(context, item)),
          if (remaining > 0)
            InkWell(
              onTap: () => _openDetailSheet(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list_alt_rounded,
                        size: 15, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      'Lihat $remaining jadwal lainnya',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // 2. Fallback jika hanya ada daftar ID
    if (jadwalIds.isEmpty) {
      return const Text(
        '-',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
          height: 1.3,
        ),
      );
    }

    final preview = jadwalIds.take(maxPreview).toList();
    final remaining = jadwalIds.length - preview.length;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...preview.map(
          (id) => InkWell(
            onTap: () => _navigateToJadwal(
              context,
              BlankoJadwalDetailItem(
                id: int.tryParse(id) ?? 0,
                namaJadwal: 'Jadwal #$id',
                tanggal: '-',
                tuk: '-',
              ),
            ),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    id,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 9,
                    color: Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (remaining > 0)
          InkWell(
            onTap: () => _openDetailSheet(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+$remaining lainnya',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJadwalCard(BuildContext context, BlankoJadwalDetailItem item) {
    final formattedDate = item.tanggal.isNotEmpty && item.tanggal != '-'
        ? DateFormatHelper.formatToIndonesian(item.tanggal)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToJadwal(context, item),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.event_available_rounded,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.namaJadwal.isNotEmpty
                                  ? item.namaJadwal
                                  : (item.skema.isNotEmpty ? item.skema : 'Jadwal #${item.id}'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Text(
                              '#${item.id}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 11, color: Color(0xFF64748B)),
                              const SizedBox(width: 3),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (item.tuk.isNotEmpty && item.tuk != '-')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.business_outlined,
                                    size: 11, color: Color(0xFF64748B)),
                                const SizedBox(width: 3),
                                Text(
                                  item.tuk,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToJadwal(BuildContext context, BlankoJadwalDetailItem item) {
    if (item.id <= 0) return;

    final dummyJadwal = JadwalItem(
      id: item.id,
      skema: item.skema.isNotEmpty ? item.skema : item.namaJadwal,
      tuk: item.tuk,
      tanggalMulai: item.tanggal,
      tanggalSelesai: item.tanggal,
      createdWhen: '',
      status: 'completed',
      statusJadwal: '1',
      statusLabel: 'Selesai',
      jumlahAsesi: item.jumlahPeserta,
      asesor: const [],
      sisaHari: 0,
      totalAsesi: item.jumlahPeserta,
      jumlahKompeten: item.jumlahPeserta,
      jumlahBelumKompeten: 0,
      needsAcc: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JadwalDetailScreen(
          jadwal: dummyJadwal,
          userRole: UserRole.admin,
        ),
      ),
    );
  }

  void _openDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _JadwalIdSheet(
        ids: jadwalIds,
        items: jadwalList ?? const [],
        onSelect: (item) => _navigateToJadwal(context, item),
      ),
    );
  }
}

class _JadwalIdSheet extends StatelessWidget {
  final List<String> ids;
  final List<BlankoJadwalDetailItem> items;
  final Function(BlankoJadwalDetailItem)? onSelect;

  const _JadwalIdSheet({
    required this.ids,
    this.items = const [],
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = math.max(mediaQuery.padding.bottom, 16.0) + bottomInset;
    final totalCount = items.isNotEmpty ? items.length : ids.length;

    return SafeArea(
      top: false,
      bottom: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.8,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.event_note_outlined,
                      size: 20, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Daftar Jadwal Asesmen',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Text(
                    '$totalCount jadwal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        size: 20, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: items.isNotEmpty
                      ? Column(
                          children: items
                            .map(
                              (item) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Material(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (onSelect != null) {
                                        onSelect!(item);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.namaJadwal.isNotEmpty
                                                      ? item.namaJadwal
                                                      : 'Jadwal #${item.id}',
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${item.tanggal.isNotEmpty ? DateFormatHelper.formatToIndonesian(item.tanggal) : '-'} • ${item.tuk}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 12,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ids
                            .map(
                              (id) => InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  if (onSelect != null) {
                                    onSelect!(
                                      BlankoJadwalDetailItem(
                                        id: int.tryParse(id) ?? 0,
                                        namaJadwal: 'Jadwal #$id',
                                        tanggal: '-',
                                        tuk: '-',
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Jadwal ID $id',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1D4ED8),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 10,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _copyAll(context),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Salin Semua ID'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Future<void> _copyAll(BuildContext context) async {
    final copyText = items.isNotEmpty
        ? items.map((i) => '${i.id} (${i.namaJadwal})').join(', ')
        : ids.join(', ');
    await Clipboard.setData(ClipboardData(text: copyText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar ID Jadwal disalin')),
      );
    }
  }
}

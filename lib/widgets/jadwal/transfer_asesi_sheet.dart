import 'package:material_ui/material_ui.dart';

import '../../models/jadwal_models.dart';

/// Bottom sheet pemilihan asesor tujuan untuk memindahkan asesi.
/// Mengembalikan [AsesorDetailItem] yang dipilih melalui `Navigator.pop`.
class TransferAsesiSheet extends StatefulWidget {
  final String namaAsesi;
  final String? asesorSaatIni;
  final List<AsesorDetailItem> kandidat;
  final String errorMessage;
  final VoidCallback? onRetry;

  const TransferAsesiSheet({
    super.key,
    required this.namaAsesi,
    required this.kandidat,
    this.asesorSaatIni,
    this.errorMessage = '',
    this.onRetry,
  });

  @override
  State<TransferAsesiSheet> createState() => _TransferAsesiSheetState();
}

class _TransferAsesiSheetState extends State<TransferAsesiSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AsesorDetailItem> get _filtered {
    if (_query.isEmpty) return widget.kandidat;
    final q = _query.toLowerCase();
    return widget.kandidat.where((a) {
      return a.namaAsesor.toLowerCase().contains(q) ||
          a.noReg.toLowerCase().contains(q) ||
          a.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 8,
                  top: 4,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.swap_horiz_rounded,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pindahkan Asesi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.namaAsesi,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Asesor saat ini: ${widget.asesorSaatIni?.isNotEmpty == true ? widget.asesorSaatIni : '-'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              if (widget.errorMessage.isEmpty && widget.kandidat.length > 5)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _query = val.trim()),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari asesor tujuan...',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ),
                ),
              Expanded(child: _buildBody(scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (widget.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626)),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: widget.onRetry,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final items = _filtered;
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Tidak ada asesor lain yang sedang bertugas pada jadwal ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final asesor = items[index];
        final subtitle = [
          if (asesor.noReg.isNotEmpty) asesor.noReg,
          if (asesor.email.isNotEmpty) asesor.email,
        ].join(' • ');

        return Material(
          color: Colors.transparent,
          child: ListTile(
            key: ValueKey('transfer-target-${asesor.idAsesor}'),
            dense: true,
            leading: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE5F1FC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  asesor.namaAsesor.isNotEmpty
                      ? asesor.namaAsesor
                            .trim()
                            .split(' ')
                            .map((s) => s.isNotEmpty ? s[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C6C9C),
                  ),
                ),
              ),
            ),
            title: Text(
              asesor.namaAsesor.isNotEmpty
                  ? asesor.namaAsesor
                  : 'Asesor #${asesor.idAsesor}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            subtitle: subtitle.isEmpty
                ? null
                : Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
            onTap: () => Navigator.pop(context, asesor),
          ),
        );
      },
    );
  }
}

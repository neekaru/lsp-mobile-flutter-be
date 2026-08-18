// ============================================================================
// Step 2 BuatLaporanScreen — daftar peserta & kehadiran.
//
// Diekstrak dari buat_laporan_steps.dart agar tiap step menjadi modul
// tersendiri. Semua state tetap dimiliki oleh screen; widget ini hanya
// menerima data + callback.
// ============================================================================

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'participant_widgets.dart';

class BuatLaporanStep2Form extends StatefulWidget {
  final List<ParticipantItem> participants;
  final String selectedSkema;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const BuatLaporanStep2Form({
    super.key,
    required this.participants,
    required this.selectedSkema,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  State<BuatLaporanStep2Form> createState() => _BuatLaporanStep2FormState();
}

class _BuatLaporanStep2FormState extends State<BuatLaporanStep2Form> {
  Timer? _searchDebounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  List<ParticipantItem> get _filtered {
    return widget.participants.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.nim.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFDBFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Asessi Skema ${widget.selectedSkema}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.participants.length} Asessi',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: widget.searchController,
            onChanged: (val) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                setState(() {
                  _searchQuery = val;
                });
                widget.onSearchChanged(val);
              });
            },
            decoration: const InputDecoration(
              hintText: 'Cari nama/NIM peserta',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFDBEAFE),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Nama Asessi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'NIM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Kehadiran',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ..._filtered.map((participant) {
                return AttendanceRow(
                  key: ValueKey(participant.nim),
                  participant: participant,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

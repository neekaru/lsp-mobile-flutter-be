// ============================================================================
// Step 3 BuatLaporanScreen — penilaian kompetensi peserta.
//
// Diekstrak dari buat_laporan_steps.dart agar tiap step menjadi modul
// tersendiri. Semua state tetap dimiliki oleh screen; widget ini hanya
// menerima data + callback.
// ============================================================================

import 'package:flutter/material.dart';

import 'participant_widgets.dart';

class BuatLaporanStep3Form extends StatelessWidget {
  final List<ParticipantItem> participants;
  final bool allKSelected;
  final bool allTKSelected;
  final VoidCallback onBulkK;
  final VoidCallback onBulkTK;
  final ValueChanged<bool> onCompetenceChanged;

  const BuatLaporanStep3Form({
    super.key,
    required this.participants,
    required this.allKSelected,
    required this.allTKSelected,
    required this.onBulkK,
    required this.onBulkTK,
    required this.onCompetenceChanged,
  });

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
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Penilaian Asessi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tugas yang diberikan assessor dikerjakan dengan baik, Tingkat kehadiran tidak absen, dan asessi mengerjakan tugas secara mandiri.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Text(
                    '> ',
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Kompeten [K]',
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Text(
                    '> ',
                    style: TextStyle(
                      color: Color(0xFFBE123C),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Tidak Kompeten [TK]',
                    style: TextStyle(
                      color: Color(0xFFBE123C),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PILIHAN MASSAL (BULK ACTION)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: allKSelected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFCBD5E1),
                          ),
                          backgroundColor: allKSelected
                              ? const Color(0xFFECFDF5)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: allKSelected
                              ? const Color(0xFF047857)
                              : const Color(0xFF475569),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: onBulkK,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              allKSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 16,
                              color: allKSelected
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Semua [K]',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: allTKSelected
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFCBD5E1),
                          ),
                          backgroundColor: allTKSelected
                              ? const Color(0xFFFEF2F2)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: allTKSelected
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFF475569),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: onBulkTK,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              allTKSelected
                                  ? Icons.cancel_rounded
                                  : Icons.cancel_outlined,
                              size: 16,
                              color: allTKSelected
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Semua [TK]',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Column(
          children: participants.map((participant) {
            return Step3ParticipantCard(
              key: ValueKey(participant.nim),
              participant: participant,
              onCompetenceChanged: onCompetenceChanged,
            );
          }).toList(),
        ),
      ],
    );
  }
}

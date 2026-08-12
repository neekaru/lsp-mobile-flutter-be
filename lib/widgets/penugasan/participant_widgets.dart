import 'package:flutter/material.dart';

/// Data peserta laporan (nama, NIM, kehadiran, kompetensi).
class ParticipantItem {
  final String name;
  final String nim;
  bool isPresent;
  bool isCompetent; // For Step 3

  ParticipantItem({
    required this.name,
    required this.nim,
    this.isPresent = true,
    this.isCompetent = true,
  });
}

/// Card peserta step 3 (penilaian kompetensi K/TK) — buat laporan.
class Step3ParticipantCard extends StatefulWidget {
  final ParticipantItem participant;
  final ValueChanged<bool> onCompetenceChanged;

  const Step3ParticipantCard({
    super.key,
    required this.participant,
    required this.onCompetenceChanged,
  });

  @override
  State<Step3ParticipantCard> createState() => _Step3ParticipantCardState();
}

class _Step3ParticipantCardState extends State<Step3ParticipantCard> {
  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    final firstLetter = participant.name.isNotEmpty
        ? participant.name[0].toUpperCase()
        : 'A';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Left: Avatar + Name & NIM
          Expanded(
            flex: 11,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NIM: ${participant.nim}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Premium Mobile-First Selector Switch/Buttons
          Expanded(
            flex: 9,
            child: Row(
              children: [
                // Pill for Kompeten [K]
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        participant.isCompetent = true;
                      });
                      widget.onCompetenceChanged(true);
                    },
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: participant.isCompetent
                            ? const Color(0xFFECFDF5)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: participant.isCompetent
                              ? const Color(0xFF10B981)
                              : const Color(0xFFE2E8F0),
                          width: participant.isCompetent ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '[K]',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: participant.isCompetent
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          if (participant.isCompetent) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 12,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Pill for Tidak Kompeten [TK]
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        participant.isCompetent = false;
                      });
                      widget.onCompetenceChanged(false);
                    },
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: !participant.isCompetent
                            ? const Color(0xFFFEF2F2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !participant.isCompetent
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFE2E8F0),
                          width: !participant.isCompetent ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '[TK]',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: !participant.isCompetent
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          if (!participant.isCompetent) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.cancel_rounded,
                              color: Color(0xFFEF4444),
                              size: 12,
                            ),
                          ],
                        ],
                      ),
                    ),
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

/// Baris kehadiran peserta (Hadir/Absen toggle) — buat laporan.
class AttendanceRow extends StatefulWidget {
  final ParticipantItem participant;

  const AttendanceRow({super.key, required this.participant});

  @override
  State<AttendanceRow> createState() => _AttendanceRowState();
}

class _AttendanceRowState extends State<AttendanceRow> {
  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Name Col
              Expanded(
                flex: 2,
                child: Text(
                  participant.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // NIM Col
              Expanded(
                flex: 2,
                child: Text(
                  participant.nim,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              // Attendance Switch Col
              SizedBox(
                width: 80,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildAttendanceSwitch(participant),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
      ],
    );
  }

  Widget _buildAttendanceSwitch(ParticipantItem participant) {
    return GestureDetector(
      onTap: () {
        setState(() {
          participant.isPresent = !participant.isPresent;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        height: 28,
        decoration: BoxDecoration(
          color: participant.isPresent
              ? const Color(0xFF22C55E)
              : const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: participant.isPresent
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            if (participant.isPresent) ...[
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Hadir',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Absen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

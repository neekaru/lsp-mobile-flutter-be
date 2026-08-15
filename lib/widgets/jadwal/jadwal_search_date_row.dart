// ============================================================================
// Jadwal Search + Date Filter Row
//
// Diekstrak dari jadwal_screen.dart — baris pencarian & filter tanggal untuk
// tab Selesai (kriteria: tanggal asesmen + TUK).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JadwalSearchDateRow extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final String searchQuery;
  final DateTime? selectedDate;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onResetSearch;
  final VoidCallback onSelectDate;

  const JadwalSearchDateRow({
    super.key,
    required this.searchController,
    required this.isSearching,
    required this.searchQuery,
    required this.selectedDate,
    required this.onSearchChanged,
    required this.onResetSearch,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedDate = selectedDate != null;
    final String dateLabel = hasSelectedDate
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : 'Tanggal';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Search TextField container
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Cari tanggal asesmen atau TUK',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (isSearching) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ] else if (searchQuery.isNotEmpty) ...[
                    GestureDetector(
                      onTap: onResetSearch,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Date filter button
          GestureDetector(
            onTap: onSelectDate,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: hasSelectedDate ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasSelectedDate
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFCBD5E1),
                  width: hasSelectedDate ? 1.5 : 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: hasSelectedDate
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: hasSelectedDate
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: hasSelectedDate
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFF475569),
                    ),
                  ),
                  if (hasSelectedDate) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onResetSearch,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

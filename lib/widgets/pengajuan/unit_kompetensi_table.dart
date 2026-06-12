import 'package:flutter/material.dart';

class UnitKompetensiTable extends StatefulWidget {
  final String selectedSkema;
  final List<Map<String, dynamic>> unitKompetensi;

  const UnitKompetensiTable({
    super.key,
    required this.selectedSkema,
    required this.unitKompetensi,
  });

  @override
  State<UnitKompetensiTable> createState() => _UnitKompetensiTableState();
}

class _UnitKompetensiTableState extends State<UnitKompetensiTable> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> displayedUnits = _isExpanded
        ? widget.unitKompetensi
        : widget.unitKompetensi.take(5).toList();

    final hasMore = widget.unitKompetensi.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title of selected schema
        Text(
          widget.selectedSkema,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),

        // Table widget for Unit Kompetensi
        Table(
          columnWidths: const {
            0: FixedColumnWidth(36), // No
            1: FixedColumnWidth(110), // Kode Unit
            2: FlexColumnWidth(), // Judul UnitKompetensi
          },
          border: TableBorder.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Table Header Row
            const TableRow(
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA),
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    child: Text(
                      'Kode Unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    child: Text(
                      'Judul UnitKompetensi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            
            // Table Data Rows
            ...List.generate(displayedUnits.length, (index) {
              final item = displayedUnits[index];
              return TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                      child: Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF334155),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                      child: Text(
                        item['kode'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: Text(
                        item['judul'] ?? '',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF334155),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),

        // "Lainnya" expand/collapse dropdown button
        if (hasMore) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFFD4E6F1), // Light blue matching the screenshot
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'Sembunyikan' : 'Lainnya',
                    style: const TextStyle(
                      color: Color(0xFF1B4F72),
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF1B4F72),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildWarningBanner(),
      ],
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E6F1), // Light blue background matching screenshot
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '1. Upload dapat lebih dari 1 file. Klik Browse.',
            style: TextStyle(
              color: Color(0xFF1B4F72), // Dark blue text
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '2. Ekstensi file yang di perbolehkan Image dan PDF',
            style: TextStyle(
              color: Color(0xFF1B4F72),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '3. Maksimal Ukuran File adalah 2 MB',
            style: TextStyle(
              color: Color(0xFF1B4F72),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

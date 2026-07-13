import 'package:flutter/material.dart';

class HonorAsesorScreen extends StatefulWidget {
  const HonorAsesorScreen({super.key});

  @override
  State<HonorAsesorScreen> createState() => _HonorAsesorScreenState();
}

class _HonorAsesorScreenState extends State<HonorAsesorScreen> {
  String _selectedMonth = 'Juli 2026';

  final List<Map<String, dynamic>> monthlyHistory = [
    {
      'month': 'Juli 2026',
      'total': 'Rp. 2.500.000',
      'count': '4 Asesmen selesai',
      'details': [
        {
          'title': 'Uji Kompetensi: Junior Web Programmer',
          'date': '12 Juli 2026',
          'tuk': 'Politeknik Sampit',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Digital Marketing',
          'date': '10 Juli 2026',
          'tuk': 'TUK Sewaktu LSP',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Network Administrator',
          'date': '06 Juli 2026',
          'tuk': 'SMKN 1 Sampit',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Junior Graphic Designer',
          'date': '02 Juli 2026',
          'tuk': 'Politeknik Sampit',
          'honor': 'Rp. 625.000',
        },
      ]
    },
    {
      'month': 'Juni 2026',
      'total': 'Rp. 1.875.000',
      'count': '3 Asesmen selesai',
      'details': [
        {
          'title': 'Uji Kompetensi: Junior Web Programmer',
          'date': '24 Juni 2026',
          'tuk': 'Politeknik Sampit',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Digital Marketing',
          'date': '18 Juni 2026',
          'tuk': 'TUK Sewaktu LSP',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Junior Graphic Designer',
          'date': '11 Juni 2026',
          'tuk': 'Politeknik Sampit',
          'honor': 'Rp. 625.000',
        },
      ]
    },
    {
      'month': 'Mei 2026',
      'total': 'Rp. 3.125.000',
      'count': '5 Asesmen selesai',
      'details': [
        {
          'title': 'Uji Kompetensi: Junior Web Programmer',
          'date': '28 Mei 2026',
          'tuk': 'Politeknik Sampit',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Digital Marketing',
          'date': '22 Mei 2026',
          'tuk': 'TUK Sewaktu LSP',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Network Administrator',
          'date': '15 Mei 2026',
          'tuk': 'SMKN 1 Sampit',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Junior Graphic Designer',
          'date': '08 Mei 2026',
          'tuk': 'Politeknik Sampit',
          'honor': 'Rp. 625.000',
        },
        {
          'title': 'Uji Kompetensi: Network Administrator',
          'date': '04 Mei 2026',
          'tuk': 'SMKN 1 Sampit',
          'honor': 'Rp. 625.000',
        },
      ]
    }
  ];

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Periode Bulan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...monthlyHistory.map((item) {
                    final monthName = item['month'] as String;
                    final isSelected = monthName == _selectedMonth;
                    return ListTile(
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        color: isSelected ? const Color(0xFF378CE7) : const Color(0xFF64748B),
                      ),
                      title: Text(
                        monthName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF378CE7) : const Color(0xFF1E293B),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF378CE7))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedMonth = monthName;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Get selected month details
    final selectedData = monthlyHistory.firstWhere(
      (item) => item['month'] == _selectedMonth,
      orElse: () => monthlyHistory.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header to match the screenshot design
          Container(
            color: const Color(0xFFF5F5F5),
            padding: EdgeInsets.only(
              top: statusBarHeight + 8,
              bottom: 12,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF1E293B),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Honor',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Picker Button
                  GestureDetector(
                    onTap: () => _showMonthPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF378CE7),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedMonth,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Highlight Total Honor Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Honor',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              selectedData['total'] as String,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              selectedData['count'] as String,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        // Premium Vector Illustration of smartphone & transaction details
                        _buildIllustration(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu Profil Section
                  const Text(
                    'Menu Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Collapsible Month Card detailed view
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFDBFE), // Soft blue square
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Total Honor ($_selectedMonth)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Text(
                          selectedData['count'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        trailing: Text(
                          selectedData['total'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        children: [
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (selectedData['details'] as List).length,
                            separatorBuilder: (context, i) =>
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, i) {
                              final detail = (selectedData['details'] as List)[i]
                                  as Map<String, String>;
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail['title']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${detail['date']} | ${detail['tuk']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          detail['honor']!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF378CE7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFBFDBFE).withValues(alpha: 0.6), // Light blue background box
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Green Money Note (rotated)
            Positioned(
              left: 10,
              bottom: 12,
              child: Transform.rotate(
                angle: -0.25,
                child: Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80), // Green bill
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Smartphone body
            Positioned(
              right: 15,
              top: 10,
              child: Container(
                width: 42,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A), // Dark blue phone
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    // Speaker line
                    Center(
                      child: Container(
                        width: 10,
                        height: 1.5,
                        color: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Screen content with a tiny credit card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6), // Blue screen
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Tiny credit card
                            Positioned(
                              top: 4,
                              child: Container(
                                width: 30,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF97316), Color(0xFFEA580C)], // Orange card
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Mini receipt/check lines
                            Positioned(
                              bottom: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: 25, height: 2, color: Colors.white),
                                  const SizedBox(height: 2),
                                  Container(width: 18, height: 2, color: Colors.white70),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // White receipt in front of the phone
            Positioned(
              right: 5,
              bottom: 12,
              child: Transform.rotate(
                angle: 0.15,
                child: Container(
                  width: 32,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white, // White receipt paper
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 20, height: 2, color: Colors.grey[400]),
                      const SizedBox(height: 2),
                      Container(width: 15, height: 1.5, color: Colors.grey[300]),
                      const SizedBox(height: 2),
                      Container(width: 18, height: 1.5, color: Colors.grey[300]),
                      const SizedBox(height: 2),
                      Container(width: 10, height: 1.5, color: Colors.grey[300]),
                    ],
                  ),
                ),
              ),
            ),
            // Gold Coin
            Positioned(
              left: 14,
              bottom: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24), // Gold color
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

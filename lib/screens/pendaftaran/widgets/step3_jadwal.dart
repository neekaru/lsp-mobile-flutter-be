// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class Step3Jadwal extends StatefulWidget {
  const Step3Jadwal({super.key});

  @override
  State<Step3Jadwal> createState() => _Step3JadwalState();
}

class _Step3JadwalState extends State<Step3Jadwal> {
  int _selectedJadwalIndex = 0;

  final List<Map<String, String>> _jadwalList = [
    {
      'jadwal': 'Sertifikasi SMA 5 Semarang - DG Muda 200726',
      'tglPra': '20/07/2026',
      'tglAsesmen': '20/07/2026',
    },
    {
      'jadwal': 'Uji Desainer Grafis Muda - Jabshun 010826',
      'tglPra': '01/08/2026',
      'tglAsesmen': '01/08/2026',
    },
    {
      'jadwal': 'Uji Desainer Grafis Muda - Jabshun 010826',
      'tglPra': '01/08/2026',
      'tglAsesmen': '01/08/2026',
    },
    {
      'jadwal': 'Uji Desainer Grafis Muda - Jabshun 010826',
      'tglPra': '01/08/2026',
      'tglAsesmen': '01/08/2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Center(
            child: Text(
              'Jadwal Pra-Asesmen dan Asesmen',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Text(
                          'Jadwal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Tanggal Pra\nAsesmen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Tanggal\nAsesmen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _jadwalList.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (context, index) {
                  final item = _jadwalList[index];
                  final isSelected = _selectedJadwalIndex == index;

                  return InkWell(
                    onTap: () => setState(() => _selectedJadwalIndex = index),
                    child: Container(
                      color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              item['jadwal'] ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                item['tglPra'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                item['tglAsesmen'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Radio<int>(
                                value: index,
                                groupValue: _selectedJadwalIndex,
                                activeColor: const Color(0xFF3B82F6),
                                onChanged: (val) => setState(() => _selectedJadwalIndex = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

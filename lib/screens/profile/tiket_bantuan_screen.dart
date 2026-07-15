import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'buat_tiket_screen.dart';
import 'detail_tiket_screen.dart';

class TiketBantuanScreen extends StatefulWidget {
  const TiketBantuanScreen({super.key});

  @override
  State<TiketBantuanScreen> createState() => _TiketBantuanScreenState();
}

class _TiketBantuanScreenState extends State<TiketBantuanScreen> {
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TK-072026-001',
      'title': 'Jadwal Tidak Dapat Dibuka',
      'date': '20 Juli 2026, 13:00',
      'category': 'Jadwal',
      'status': 'Proses',
      'messages': [
        {
          'sender': 'Asesor',
          'time': '20 Juli 2026 13:00',
          'text': 'Saya tidak bisa membuka detail jadwal asesmen saya pada hari ini. Muncul pesan error koneksi.',
        },
        {
          'sender': 'LSP Admin',
          'time': '20 Juli 2026 13:15',
          'text': 'Halo Pak, mohon pastikan koneksi internet stabil atau coba restart aplikasi ya.',
        }
      ]
    },
    {
      'id': 'TK-072026-002',
      'title': 'Surat Tugas Tidak ada',
      'date': '18 Juli 2026, 08:00',
      'category': 'Surat Tugas',
      'status': 'Proses',
      'messages': [
        {
          'sender': 'Asesor',
          'time': '18 Juli 2026 08:00',
          'text': 'Mohon bantuannya, surat tugas untuk skema sertifikasi UI/UX tidak terlampir di dashboard.',
        }
      ]
    },
    {
      'id': 'TK-072026-003',
      'title': 'Surat Tugas Tidak ada',
      'date': '18 Juli 2026, 08:00',
      'category': 'Surat Tugas',
      'status': 'Proses',
      'messages': [
        {
          'sender': 'Asesor',
          'time': '18 Juli 2026 08:00',
          'text': 'Surat tugas untuk jadwal tanggal 18 Juli tidak muncul di akun saya.',
        }
      ]
    },
  ];

  void _navigateToCreateTicket() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const BuatTiketScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        final String newId = 'TK-072026-0${_tickets.length + 1}';
        _tickets.insert(0, {
          'id': newId,
          'title': result['title'],
          'date': 'Hari ini',
          // Auto resolve category from title keywords
          'category': result['title'].toString().toLowerCase().contains('surat') ? 'Surat Tugas' : 'Jadwal',
          'status': 'Proses',
          'messages': [
            {
              'sender': 'Asesor',
              'time': 'Hari ini',
              'text': result['message'],
            }
          ]
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket bantuan berhasil dibuat!'),
          backgroundColor: Color(0xFF2563EB),
        ),
      );
    }
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTiketScreen(ticket: ticket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(title: 'Tiket Bantuan'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tiket Bantuan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Kelola permintaan bantuan dan pantau terus status perkembangannya.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Premium Chatbot illustration
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF), // Soft blue bg
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/ticket_helper.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 2. Vertical list of Tickets
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _tickets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      return GestureDetector(
                        onTap: () => _showTicketDetails(ticket),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Icon: Calendar icon in light blue container
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Middle details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#${ticket['id']}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ticket['title']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ticket['category']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ticket['date']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
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
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 24.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _navigateToCreateTicket,
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text(
              'Buat Tiket Baru',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF54A0EB), // Sky blue color from design
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

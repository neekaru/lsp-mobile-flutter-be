import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class TiketBantuanScreen extends StatefulWidget {
  const TiketBantuanScreen({super.key});

  @override
  State<TiketBantuanScreen> createState() => _TiketBantuanScreenState();
}

class _TiketBantuanScreenState extends State<TiketBantuanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TKT-2026-0043',
      'title': 'Gagal Input Rekomendasi Asesmen',
      'date': '12 Juli 2026 14:22',
      'category': 'Sistem Asesmen',
      'status': 'Proses',
      'messages': [
        {
          'sender': 'Asesor',
          'time': '12 Juli 2026 14:22',
          'text': 'Saya tidak bisa menginputkan rekomendasi "Kompeten" pada peserta Muhammad Hanafi. Tombol Simpan tidak merespon saat diklik.',
        },
        {
          'sender': 'LSP Admin',
          'time': '12 Juli 2026 16:05',
          'text': 'Halo Pak Muhammad, kendala ini sedang kami periksa ke bagian IT. Mohon ditunggu terlebih dahulu ya.',
        }
      ]
    },
    {
      'id': 'TKT-2026-0012',
      'title': 'Verifikasi Akun Asesor Tertunda',
      'date': '18 Juni 2026 09:15',
      'category': 'Akun & Profil',
      'status': 'Selesai',
      'messages': [
        {
          'sender': 'Asesor',
          'time': '18 Juni 2026 09:15',
          'text': 'Mohon bantuan untuk verifikasi pergantian nomor HP dan email pada akun saya.',
        },
        {
          'sender': 'LSP Admin',
          'time': '18 Juni 2026 11:30',
          'text': 'Verifikasi pergantian nomor HP dan email berhasil diproses dan diaktifkan. Terima kasih.',
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateTicketDialog() {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Sistem Asesmen');
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Buat Tiket Baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori Kendala',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: categoryController.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sistem Asesmen', child: Text('Sistem Asesmen')),
                    DropdownMenuItem(value: 'Akun & Profil', child: Text('Akun & Profil')),
                    DropdownMenuItem(value: 'Honor & Keuangan', child: Text('Honor & Keuangan')),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      categoryController.text = val;
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Judul Kendala',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Masalah Login',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Detail Deskripsi',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan kendala Anda secara rinci...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harap isi semua bidang!')),
                  );
                  return;
                }
                setState(() {
                  _tickets.insert(0, {
                    'id': 'TKT-2026-00${44 + _tickets.length}',
                    'title': titleController.text,
                    'date': 'Hari ini ${TimeOfDay.now().format(context)}',
                    'category': categoryController.text,
                    'status': 'Proses',
                    'messages': [
                      {
                        'sender': 'Asesor',
                        'time': 'Hari ini',
                        'text': descController.text,
                      }
                    ]
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tiket bantuan berhasil dibuat!'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF378CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Kirim Tiket'),
            ),
          ],
        );
      },
    );
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet line indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: #${ticket['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF378CE7)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket['status'] == 'Selesai' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket['status']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ticket['status'] == 'Selesai' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket['title']!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                'Kategori: ${ticket['category']} | dibuat pada ${ticket['date']}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),
              const Text(
                'Pesan Kendala & Tanggapan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: (ticket['messages'] as List).length,
                  itemBuilder: (context, idx) {
                    final msg = (ticket['messages'] as List)[idx];
                    final isAsesor = msg['sender'] == 'Asesor';
                    return Align(
                      alignment: isAsesor ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAsesor ? const Color(0xFFE3F2FD) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isAsesor ? const Radius.circular(12) : const Radius.circular(0),
                            bottomRight: isAsesor ? const Radius.circular(0) : const Radius.circular(12),
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  msg['sender']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isAsesor ? const Color(0xFF378CE7) : const Color(0xFF475569),
                                  ),
                                ),
                                Text(
                                  msg['time']!,
                                  style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              msg['text']!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final activeTickets = _tickets.where((t) => t['status'] == 'Proses').toList();
    final completedTickets = _tickets.where((t) => t['status'] == 'Selesai').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Tiket Bantuan',
            rightWidget: SizedBox(width: 32),
          ),
          
          // Tab bar Custom
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF378CE7),
              labelColor: const Color(0xFF378CE7),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Aktif'),
                Tab(text: 'Selesai'),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTicketList(activeTickets),
                _buildTicketList(completedTickets),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _showCreateTicketDialog,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Buat Tiket Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF378CE7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList(List<Map<String, dynamic>> ticketsList) {
    if (ticketsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplane_ticket_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Tidak ada tiket bantuan',
              style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      itemCount: ticketsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = ticketsList[index];
        final isSelesai = ticket['status'] == 'Selesai';
        return GestureDetector(
          onTap: () => _showTicketDetails(ticket),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${ticket['id']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF378CE7),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelesai ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticket['status']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelesai ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  ticket['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori: ${ticket['category']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      ticket['date']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

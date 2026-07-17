import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/asesor_service.dart';
import '../../services/admin_tiket_service.dart';
import '../../services/auth_repository.dart';
import 'buat_tiket_screen.dart';
import 'detail_tiket_screen.dart';

class TiketBantuanScreen extends StatefulWidget {
  const TiketBantuanScreen({super.key});

  @override
  State<TiketBantuanScreen> createState() => _TiketBantuanScreenState();
}

class _TiketBantuanScreenState extends State<TiketBantuanScreen> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  bool get _isAdmin =>
      AuthRepository.currentUserInstance?.role == 'admin';

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tickets = _isAdmin
          ? await AdminTiketService.getTiketList()
          : await AsesorService.getTiketList();
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToCreateTicket() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const BuatTiketScreen()),
    );

    if (result == true && mounted) {
      _fetchTickets();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket bantuan berhasil dibuat!'),
          backgroundColor: Color(0xFF2563EB),
        ),
      );
    }
  }

  void _showTicketDetails(Map<String, dynamic> ticket) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTiketScreen(ticket: ticket),
      ),
    );
    // Refresh list on return to see if new replies exist
    _fetchTickets();
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
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    )
                  else if (_tickets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.forum_outlined,
                                color: Color(0xFF94A3B8),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Tiket Bantuan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Jika Anda mengalami kendala pada sistem, silakan buat tiket baru.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _tickets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        // Admin list uses 'judul' field, asesor uses 'title'
                        final String titleText =
                            ticket['title'] ?? ticket['judul'] ?? '-';
                        final String categoryText =
                            ticket['category'] ?? ticket['kategori'] ?? '-';
                        final String dateText =
                            ticket['date'] ?? ticket['tanggal'] ?? '-';

                        return GestureDetector(
                          onTap: () => _showTicketDetails(ticket),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Icon
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        titleText,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        categoryText,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      // Admin: tampilkan pengirim
                                      if (_isAdmin &&
                                          ticket['pengirim'] != null) ...
                                        [
                                          const SizedBox(height: 2),
                                          Text(
                                            'Dari: ${ticket['pengirim']}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF3B82F6),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      const SizedBox(height: 4),
                                      Text(
                                        dateText,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ticket['status'] == 'Selesai'
                                        ? const Color(0xFFDCFCE7)
                                        : ticket['status'] == 'Batal'
                                            ? const Color(0xFFFEE2E2)
                                            : const Color(0xFFFFEDD5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    ticket['status'] ?? 'Proses',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: ticket['status'] == 'Selesai'
                                          ? const Color(0xFF15803D)
                                          : ticket['status'] == 'Batal'
                                              ? const Color(0xFFB91C1C)
                                              : const Color(0xFFD97706),
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
          ),
        ],
      ),
      // Admin: tidak perlu tombol buat tiket baru
      bottomNavigationBar: _isAdmin
          ? null
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 12.0, bottom: 24.0),
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
                    backgroundColor: const Color(0xFF54A0EB),
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

import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/asesor_service.dart';

class DetailTiketScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const DetailTiketScreen({super.key, required this.ticket});

  @override
  State<DetailTiketScreen> createState() => _DetailTiketScreenState();
}

class _DetailTiketScreenState extends State<DetailTiketScreen> {
  late List<Map<String, dynamic>> _messages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(
      widget.ticket['messages'] ?? [],
    );
    _fetchTicketDetail();
  }

  Future<void> _fetchTicketDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await AsesorService.getTiketDetail(widget.ticket['id']);
      if (res != null && mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(res['messages'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final ticket = widget.ticket;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(title: 'Detail Tiket #${ticket['id']}'),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFF3B82F6),
              backgroundColor: Color(0xFFEFF6FF),
            ),

          // Ticket Metadata Info Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori: ${ticket['category']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                const SizedBox(height: 8),
                Text(
                  ticket['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dibuat pada ${ticket['date']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.history_rounded, size: 16, color: Color(0xFF64748B)),
                SizedBox(width: 6),
                Text(
                  'Riwayat Aktivitas & Tanggapan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Messages / Ticket Updates List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 48,
                          color: const Color(0xFF64748B).withAlpha(100),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada tanggapan atau aktivitas.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isAsesor = msg['sender'] == 'Asesor';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAsesor
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFFCBD5E1),
                            width: isAsesor ? 1.0 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top header strip in card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: isAsesor
                                    ? const Color(0xFFF8FAFC)
                                    : const Color(0xFFF0FDF4),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  topRight: Radius.circular(11),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isAsesor
                                          ? const Color(0xFFEFF6FF)
                                          : const Color(0xFFDCFCE7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isAsesor
                                          ? Icons.person_outline_rounded
                                          : Icons.support_agent_rounded,
                                      size: 15,
                                      color: isAsesor
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF16A34A),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          msg['sender'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Role Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isAsesor
                                                ? const Color(0xFFEFF6FF)
                                                : const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: isAsesor
                                                  ? const Color(0xFFDBEAFE)
                                                  : const Color(0xFFBBF7D0),
                                            ),
                                          ),
                                          child: Text(
                                            isAsesor ? 'Asesor' : 'Admin LSP',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: isAsesor
                                                  ? const Color(0xFF2563EB)
                                                  : const Color(0xFF15803D),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    msg['time'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Message Content
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(
                                msg['text'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Info/Banner Section (Read-only Ticket)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: MediaQuery.of(context).padding.bottom + 16.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tiket bersifat satu arah. Silakan tunggu tanggapan dari Admin LSP.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
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
}

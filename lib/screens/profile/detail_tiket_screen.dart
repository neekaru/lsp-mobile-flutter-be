import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class DetailTiketScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const DetailTiketScreen({super.key, required this.ticket});

  @override
  State<DetailTiketScreen> createState() => _DetailTiketScreenState();
}

class _DetailTiketScreenState extends State<DetailTiketScreen> {
  final _replyController = TextEditingController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(widget.ticket['messages'] ?? []);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'Asesor',
        'time': 'Hari ini',
        'text': text,
      });
      _replyController.clear();
    });

    // Scroll to bottom if list controller is attached
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticket['status'] ?? 'Proses',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
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
                Icon(Icons.forum_outlined, size: 16, color: Color(0xFF64748B)),
                SizedBox(width: 6),
                Text(
                  'Pesan Kendala & Tanggapan',
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

          // Messages / Chat Box
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isAsesor = msg['sender'] == 'Asesor';
                return Align(
                  alignment: isAsesor ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAsesor ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isAsesor ? const Radius.circular(12) : const Radius.circular(0),
                        bottomRight: isAsesor ? const Radius.circular(0) : const Radius.circular(12),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              msg['sender'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAsesor ? const Color(0xFF2563EB) : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              msg['time'] ?? '',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          msg['text'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E293B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Reply Action Box
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Tulis tanggapan...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendReply,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF54A0EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
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

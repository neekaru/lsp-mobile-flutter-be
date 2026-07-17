import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/asesor_service.dart';
import '../../services/admin_tiket_service.dart';
import '../../services/auth_repository.dart';

class DetailTiketScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const DetailTiketScreen({super.key, required this.ticket});

  @override
  State<DetailTiketScreen> createState() => _DetailTiketScreenState();
}

class _DetailTiketScreenState extends State<DetailTiketScreen> {
  final _replyController = TextEditingController();
  late List<Map<String, dynamic>> _messages;
  late String _currentStatus;
  bool _isLoading = false;
  bool _isSending = false;

  bool get _isAdmin =>
      AuthRepository.currentUserInstance?.role == 'admin';

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(
      widget.ticket['messages'] ?? [],
    );
    _currentStatus = widget.ticket['status'] ?? 'Proses';
    _fetchTicketDetail();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _fetchTicketDetail() async {
    setState(() => _isLoading = true);
    try {
      final id = widget.ticket['id'] as int;
      final res = _isAdmin
          ? await AdminTiketService.getTiketDetail(id)
          : await AsesorService.getTiketDetail(id);

      if (res != null && mounted) {
        setState(() {
          _messages =
              List<Map<String, dynamic>>.from(res['messages'] ?? []);
          _currentStatus = res['status'] ?? _currentStatus;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Admin only: reply ────────────────────────────────────────────────────────
  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final id = widget.ticket['id'] as int;

    setState(() => _isSending = true);
    _replyController.clear();

    final res = await AdminTiketService.replyTiket(id, text);
    if (mounted) {
      if (res != null) {
        await _fetchTicketDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim tanggapan.')),
        );
      }
      setState(() => _isSending = false);
    }
  }

  // ── Admin only: ubah status ──────────────────────────────────────────────────
  Future<void> _changeStatus(String newStatus) async {
    final id = widget.ticket['id'] as int;
    final ok = await AdminTiketService.updateStatus(id, newStatus);
    if (mounted) {
      if (ok) {
        setState(() => _currentStatus = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status diubah menjadi $newStatus.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah status.')),
        );
      }
    }
  }

  void _showChangeStatusDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Status Tiket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _statusOption(ctx, 'Proses', const Color(0xFFFFEDD5),
                  const Color(0xFFD97706)),
              const SizedBox(height: 10),
              _statusOption(ctx, 'Selesai', const Color(0xFFDCFCE7),
                  const Color(0xFF15803D)),
              const SizedBox(height: 10),
              _statusOption(ctx, 'Batal', const Color(0xFFFEE2E2),
                  const Color(0xFFB91C1C)),
            ],
          ),
        );
      },
    );
  }

  Widget _statusOption(
      BuildContext ctx, String label, Color bg, Color textColor) {
    final bool isSelected = _currentStatus == label;
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        if (!isSelected) _changeStatus(label);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? textColor : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(Icons.check_rounded, color: textColor, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  // ── Badge logic: prefer field `role`, fallback ke `sender` ───────────────────
  bool _isAsesorMessage(Map<String, dynamic> msg) {
    final role = (msg['role'] ?? '').toString().toLowerCase();
    if (role.isNotEmpty) return role == 'asesor';
    // fallback ke sender
    return (msg['sender'] ?? '') == 'Asesor';
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

          // Ticket Metadata Card
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
                      'Kategori: ${ticket['category'] ?? ticket['kategori'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    // Status badge — tappable for admin
                    GestureDetector(
                      onTap: _isAdmin ? _showChangeStatusDialog : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _currentStatus == 'Selesai'
                              ? const Color(0xFFDCFCE7)
                              : _currentStatus == 'Batal'
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentStatus,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _currentStatus == 'Selesai'
                                    ? const Color(0xFF15803D)
                                    : _currentStatus == 'Batal'
                                        ? const Color(0xFFB91C1C)
                                        : const Color(0xFFD97706),
                              ),
                            ),
                            if (_isAdmin) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit_rounded,
                                size: 10,
                                color: _currentStatus == 'Selesai'
                                    ? const Color(0xFF15803D)
                                    : _currentStatus == 'Batal'
                                        ? const Color(0xFFB91C1C)
                                        : const Color(0xFFD97706),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ticket['title'] ?? ticket['judul'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dibuat pada ${ticket['date'] ?? ticket['tanggal'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                // Admin: info pengirim
                if (_isAdmin && ticket['pengirim'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Dari: ${ticket['pengirim']} (${ticket['role_pengirim'] ?? ''})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.history_rounded,
                    size: 16, color: Color(0xFF64748B)),
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

          // Messages list
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
                      final isAsesor = _isAsesorMessage(msg);

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
                            // Header strip
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
                                            borderRadius:
                                                BorderRadius.circular(4),
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

                            // Message body
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

          // ── Bottom bar: Admin → form reply | Asesor → info banner ─────────────
          if (_isAdmin)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 12.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kirim Tanggapan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _replyController,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText:
                          'Tulis tanggapan untuk pengguna di sini...',
                      hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF3B82F6), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendReply,
                        icon: _isSending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.reply_rounded,
                                color: Colors.white, size: 16),
                        label: Text(
                          _isSending ? 'Mengirim...' : 'Kirim Tanggapan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF54A0EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // Asesor / non-admin: read-only banner
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

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import '../../services/auth/auth_repository.dart';

class AsesorAiScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final VoidCallback? onNavigateToJadwal;

  const AsesorAiScreen({
    super.key,
    this.onBackToHome,
    this.onNavigateToJadwal,
  });

  @override
  State<AsesorAiScreen> createState() => _AsesorAiScreenState();
}

class _ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _AsesorAiScreenState extends State<AsesorAiScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isAiThinking = false;
  final List<_ChatMessage> _messages = [];

  final List<String> _quickPrompts = [
    '🎯 Daftar Skema Sertifikasi',
    '📅 Cek jadwal asesmen aktif',
    '⏳ Laporan menunggu verifikasi',
    '👥 Daftar asesi belum dinilai',
    '📜 Syarat pemeliharaan RCC Asesor',
    '💡 Panduan penilaian uji kompetensi',
  ];

  @override
  void initState() {
    super.initState();
    _initWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initWelcomeMessage() {
    final user = AuthRepository.currentUserInstance;
    final asesorName = (user?.name != null && user!.name.isNotEmpty)
        ? user.name
        : 'Bapak/Ibu Asesor';

    _messages.add(
      _ChatMessage(
        id: 'welcome-1',
        text:
            'Halo $asesorName! 👋\n\nSaya Asisten AI LSP Teknologi Digital. Anda dapat bertanya seputar agenda asesmen, verifikasi berkas, status asesi, atau materi uji kompetensi.\n\nKetik pesan Anda atau pilih salah satu prompt di bawah untuk mencoba:',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = _ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isAiThinking = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Simulasi respons AI (Dummy Automation - Ready to hook with n8n webhook)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      final aiReply = _generateAiResponse(trimmed);
      setState(() {
        _isAiThinking = false;
        _messages.add(aiReply);
      });
      _scrollToBottom();
    });
  }

  _ChatMessage _generateAiResponse(String prompt) {
    final lower = prompt.toLowerCase();
    final now = DateTime.now();

    // 1. Cek Jadwal Asesmen
    if (lower.contains('jadwal') ||
        lower.contains('asesmen') ||
        lower.contains('agenda') ||
        lower.contains('kegiatan')) {
      return _ChatMessage(
        id: now.millisecondsSinceEpoch.toString(),
        text:
            'Berikut ringkasan jadwal asesmen aktif Anda saat ini:\n\n'
            '1. **AJJ Network Administrator Muda**\n'
            '   • Waktu: 28 Agustus 2026, 08:30 WIB\n'
            '   • TUK: CV. Mitra Buana Solusindo\n'
            '   • Status: *Asesmen Berlangsung*\n\n'
            '2. **Sertifikasi Pemrogram Web Pratama**\n'
            '   • Waktu: 30 Agustus 2026, 09:00 WIB\n'
            '   • TUK: PT. Solusi Digital Indonesia\n'
            '   • Status: *Running / Menunggu Verifikasi*\n\n'
            'Apakah Anda ingin melihat daftar peserta pada jadwal tersebut?',
        isUser: false,
        timestamp: now,
      );
    }

    // 2. Laporan Menunggu Verifikasi
    if (lower.contains('laporan') ||
        lower.contains('verifikasi') ||
        lower.contains('tugas')) {
      return _ChatMessage(
        id: now.millisecondsSinceEpoch.toString(),
        text:
            '📋 **Status Laporan Asesmen:**\n\n'
            'Terdapat **1 laporan** yang menunggu verifikasi Anda:\n\n'
            '• **Sertifikasi Digital Marketing - Media Digital 290726**\n'
            '  - Status: Menunggu Verifikasi Asesor\n'
            '  - Kelengkapan: FR.AK.05 & FR.AK.06 belum difinalisasi\n\n'
            'Silakan tinjau berkas pelaporan tersebut di menu **Jadwal** -> tab **Pelaporan**.',
        isUser: false,
        timestamp: now,
      );
    }

    // 3. Asesi / Peserta
    if (lower.contains('asesi') ||
        lower.contains('peserta') ||
        lower.contains('nilai') ||
        lower.contains('kompeten')) {
      return _ChatMessage(
        id: now.millisecondsSinceEpoch.toString(),
        text:
            '👥 **Ringkasan Penilaian Asesi:**\n\n'
            '• Total Asesi Ditugaskan: **12 Peserta**\n'
            '• Belum Dinilai (FR.APL.02 / AK.01): **8 Peserta**\n'
            '• Selesai Dinilai (Kompeten): **4 Peserta**\n\n'
            'Anda dapat membuka tab **Asesi** di menu bawah untuk memeriksa dokumen portofolio dan asesmen mandiri tiap asesi.',
        isUser: false,
        timestamp: now,
      );
    }

    // 4. RCC & Syarat Perpanjangan Asesor
    if (lower.contains('rcc') ||
        lower.contains('perpanjang') ||
        lower.contains('sertifikat') ||
        lower.contains('masa aktif') ||
        lower.contains('spt')) {
      return _ChatMessage(
        id: now.millisecondsSinceEpoch.toString(),
        text:
            '📜 **Status Pemeliharaan Kompetensi Asesor (RCC):**\n\n'
            '• **Total SPT Tercatat:** 6 SPT (Target 6 SPT tercapai ✅)\n'
            '• **Status Masa Aktif:** Aktif s/d 2028\n'
            '• **Perangkat MUK:** 4 Dokumen MUK terverifikasi\n\n'
            'Anda telah memenuhi syarat untuk rekomendasi perpanjangan sertifikat asesor (RCC) LSP.',
        isUser: false,
        timestamp: now,
      );
    }

    // 5. Panduan / MUK / Format
    if (lower.contains('panduan') ||
        lower.contains('muk') ||
        lower.contains('mapa') ||
        lower.contains('format')) {
      return _ChatMessage(
        id: now.millisecondsSinceEpoch.toString(),
        text:
            '💡 **Panduan Asesmen & Dokumen MUK:**\n\n'
            'Langkah utama proses asesmen:\n'
            '1. **Pra-Asesmen:** Verifikasi Form FR.APL.01 & FR.APL.02 asesi.\n'
            '2. **Pelaksanaan Uji:** Gunakan instrumen observasi/praktik (FR.IA.01 - FR.IA.03).\n'
            '3. **Keputusan Asesmen:** Tuangkan rekomendasi K (Kompeten) atau BK (Belum Kompeten) pada FR.AK.02.\n'
            '4. **Laporan Asesmen:** Finalisasi laporan penugasan FR.AK.05 & FR.AK.06.',
        isUser: false,
        timestamp: now,
      );
    }

    // Default Fallback Response
    return _ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      text:
          'Terima kasih atas pertanyaannya! 🤖\n\nPesan Anda: *"$prompt"*\n\n'
          '*(Fitur ini terhubung ke workflow automation n8n untuk integrasi data LSP dan model AI secara langsung)*\n\n'
          'Ada hal lain yang dapat saya bantu seputar penugasan asesmen Anda?',
      isUser: false,
      timestamp: now,
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat Chat?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: const Text(
          'Apakah Anda yakin ingin mengosongkan riwayat percakapan ini?',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _initWelcomeMessage();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Header AI Assistant
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A2563EB),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Back Button (if provided)
                if (widget.onBackToHome != null)
                  GestureDetector(
                    onTap: widget.onBackToHome,
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                // AI Icon Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'LSP AI Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(width: 6),
                          // Online pill
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Asisten Cerdas Asesor • Automation n8n Ready',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Clear Chat button
                IconButton(
                  onPressed: _clearChat,
                  tooltip: 'Hapus Chat',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // 2. Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length + (_isAiThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isAiThinking) {
                  return _buildAiThinkingBubble();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // 3. Quick Prompts Suggestion Bar
          Container(
            height: 42,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPrompts.length,
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  backgroundColor: const Color(0xFFEFF6FF),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () => _sendMessage(prompt.replaceFirst(RegExp(r'^[^\w\s]+\s*'), '')),
                );
              },
            ),
          ),

          // 4. Chat Input Bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tanya AI (contoh: cek jadwal asesmen)...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x332563EB),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
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

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isUser = msg.isUser;
    final timeStr = DateFormat('HH:mm').format(msg.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF2563EB),
                  size: 16,
                ),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF2563EB),
                size: 16,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'AI sedang berpikir...',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
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

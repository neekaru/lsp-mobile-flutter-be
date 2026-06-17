import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_menu_bar.dart';
import '../../main.dart';
import '../../services/api_service.dart';
import '../../models/auth_models.dart';

class KeamananScreen extends StatefulWidget {
  const KeamananScreen({super.key});

  @override
  State<KeamananScreen> createState() => _KeamananScreenState();
}

class _KeamananScreenState extends State<KeamananScreen> {
  List<LoginSession> _sessions = [];
  bool _isLoadingSessions = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoadingSessions = true;
    });
    final sessions = await ApiService.getActiveSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoadingSessions = false;
      });
    }
  }

  Future<void> _handleDeleteSession(LoginSession session) async {
    final String deviceLabel = session.deviceHint.isNotEmpty 
        ? session.deviceHint 
        : (session.platform.isNotEmpty ? session.platform : 'Perangkat Tidak Dikenal');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Hapus Sesi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus sesi login di perangkat $deviceLabel?',
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Menghapus sesi...'),
            ],
          ),
          duration: Duration(days: 1),
        ),
      );

      final success = await ApiService.deleteSession(session.id);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Sesi $deviceLabel berhasil dihapus!'),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _loadSessions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Gagal menghapus sesi. Silakan coba lagi.'),
                ],
              ),
              backgroundColor: const Color(0xFFD32F2F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  String _formatDateTime(String? utcString) {
    if (utcString == null || utcString.isEmpty) {
      return '-';
    }
    try {
      final dateTime = DateTime.parse(utcString);
      final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
      return formatter.format(dateTime.toLocal());
    } catch (_) {
      return utcString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const Text(
                  'Keamanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 32, height: 32),
              ],
            ),
          ),
          
          // Main Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Shield & Lock Circular Icon
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD6E4FF), // Very soft blue outer circle
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            size: 75,
                            color: Color(0xFF5B9FD8), // Shield color
                          ),
                          Positioned(
                            bottom: 23,
                            child: const Icon(
                              Icons.lock_rounded,
                              size: 24,
                              color: Colors.white, // Lock inside shield
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Status Text
                  const Text(
                    'Akun Anda Aman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sandi Anda terakhir diperbarui pada : 20 Mei 2024',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Terakhir Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Login Terakhir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (!_isLoadingSessions)
                              GestureDetector(
                                onTap: _loadSessions,
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: Color(0xFF378CE7),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_isLoadingSessions)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Color(0xFF378CE7),
                              ),
                            ),
                          )
                        else if (_sessions.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Text(
                                'Tidak ada riwayat login aktif.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          )
                        else
                          // Table container
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1.2),
                                  1: FlexColumnWidth(1.6),
                                  2: FixedColumnWidth(60),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  // Table Header Row
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF8FAFC),
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          'Perangkat',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          'Terakhir Aktif',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(
                                            'Aksi',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Table Body Rows
                                  ..._sessions.map((session) {
                                    final isAndroid = session.platform.toLowerCase().contains('android');
                                    final isIos = session.platform.toLowerCase().contains('ios') || session.platform.toLowerCase().contains('iphone');
                                    final platformIcon = isAndroid 
                                        ? Icons.phone_android_rounded 
                                        : (isIos ? Icons.phone_iphone_rounded : Icons.computer_rounded);
                                    final platformColor = isAndroid 
                                        ? const Color(0xFF3DDC84) 
                                        : (isIos ? Colors.black87 : const Color(0xFF378CE7));

                                    final String deviceLabel = session.deviceHint.isNotEmpty 
                                        ? session.deviceHint 
                                        : (session.platform.isNotEmpty ? session.platform : 'Perangkat Tidak Dikenal');

                                    return TableRow(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(platformIcon, color: platformColor, size: 16),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      deviceLabel,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF1E293B),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (session.active)
                                                      Container(
                                                        margin: const EdgeInsets.only(top: 2),
                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFDCFCE7),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: const Text(
                                                          'Aktif',
                                                          style: TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF15803D),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            _formatDateTime(session.updatedAt ?? session.createdAt),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Color(0xFFEF4444),
                                                size: 18,
                                              ),
                                              onPressed: () => _handleDeleteSession(session),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Spacing before buttons
                  
                  // Action Buttons (Batal & Simpan)
                  Row(
                    children: [
                      // Batal Button
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDCDCDC), // Grey background
                              foregroundColor: const Color(0xFF4A4A4A),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Simpan Button
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pengaturan keamanan berhasil disimpan!'),
                                  backgroundColor: Color(0xFF4FA8E8),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B9FD8), // Blue background
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Bar to mimic the persistent layout
          BottomMenuBar(
            selectedIndex: 4, // "Profil" tab selected
            onTap: (index) {
              Navigator.pop(context); // Go back to profile screen
              mainNavigatorKey.currentState?.setTab(index); // Switch to the target tab
            },
          ),
        ],
      ),
    );
  }
}

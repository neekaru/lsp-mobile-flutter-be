import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../services/api_service.dart';
import '../../models/jadwal_models.dart';
import '../../utils/date_format_helper.dart';
import '../../services/common/app_notification_storage.dart';
import '../../services/common/notification_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../core/navigation/main_navigator.dart';
import '../../screens/jadwal/jadwal_detail_screen.dart';
import '../../screens/dashboard/faq_screen.dart';
import '../../screens/asesi/asesi_ak03_form_screen.dart';
import 'notification_card.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  bool _isLoading = true;
  List<WaitingSchedule> _schedules = [];
  int _totalWaiting = 0;

  List<AppNotification> _appNotifications = [];
  int _unreadAppCount = 0;
  int _selectedTab = 0; // 0: Jadwal, 1: Aplikasi
  StreamSubscription<void>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _notificationSubscription = NotificationService
        .onNotificationReceived
        .stream
        .listen((_) {
          _loadAllData();
        });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    final schedulesResponse = await ApiService.getWaitingSchedules(limit: 20);
    final localNotifs = await AppNotificationStorage.instance
        .getNotifications();
    final unreadLocalCount = await AppNotificationStorage.instance
        .getUnreadCount();

    if (mounted) {
      setState(() {
        _schedules = schedulesResponse.data;
        _totalWaiting = schedulesResponse.meta.totalWaiting;
        _appNotifications = localNotifs;
        _unreadAppCount = unreadLocalCount;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAppNotifications() async {
    final localNotifs = await AppNotificationStorage.instance
        .getNotifications();
    final unreadLocalCount = await AppNotificationStorage.instance
        .getUnreadCount();
    if (mounted) {
      setState(() {
        _appNotifications = localNotifs;
        _unreadAppCount = unreadLocalCount;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await AppNotificationStorage.instance.markAllAsRead();
    await _refreshAppNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua notifikasi ditandai dibaca'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    await AppNotificationStorage.instance.clearAll();
    await _refreshAppNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua notifikasi berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      if (_selectedTab == 1 && _appNotifications.isNotEmpty)
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Color(0xFF64748B),
                          ),
                          onSelected: (value) {
                            if (value == 'read_all') {
                              _markAllAsRead();
                            } else if (value == 'clear_all') {
                              _clearAllNotifications();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'read_all',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.done_all,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Tandai Semua Dibaca'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'clear_all',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_sweep,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Hapus Semua'),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(width: 48, height: 48),
                    ],
                  ),
                ),
              ),

              // Segmented Control (Tabs)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Tab 0: Jadwal Asesmen
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: _selectedTab == 0
                                    ? const Color(0xFF4A9EDF)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Jadwal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedTab == 0
                                      ? const Color(0xFF1E293B)
                                      : Colors.grey[600],
                                ),
                              ),
                              if (_totalWaiting > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF5252),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    '$_totalWaiting',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Tab 1: Notifikasi Aplikasi
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_android_rounded,
                                size: 16,
                                color: _selectedTab == 1
                                    ? const Color(0xFF4A9EDF)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Aplikasi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedTab == 1
                                      ? const Color(0xFF1E293B)
                                      : Colors.grey[600],
                                ),
                              ),
                              if (_unreadAppCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4A9EDF),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    '$_unreadAppCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content Area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedTab == 0
                    ? (_schedules.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.notifications_off_outlined,
                              title: 'Tidak ada notifikasi jadwal',
                              subtitle: 'Semua jadwal sudah ditindaklanjuti',
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _schedules.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final role =
                                    AuthRepository.currentUserInstance?.role;
                                return NotificationCard(
                                  schedule: _schedules[index],
                                  canConfirm:
                                      role == 'admin' || role == 'asesor',
                                  onStatusUpdated: _loadAllData,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ))
                    : (_appNotifications.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.message_outlined,
                              title: 'Tidak ada notifikasi aplikasi',
                              subtitle:
                                  'Anda akan menerima pemberitahuan penting di sini',
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _appNotifications.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final notif = _appNotifications[index];
                                return AppNotificationCard(
                                  notification: notif,
                                  onTap: () async {
                                    await AppNotificationStorage.instance
                                        .markAsRead(notif.id);
                                    _refreshAppNotifications();
                                  },
                                  onActionPressed: () {
                                    Navigator.pop(context); // Close bottom sheet
                                    final type = notif.type.toLowerCase();
                                    final state = mainNavigatorKey.currentState;
                                    if (state == null || !state.mounted) return;
                                    final role = AuthRepository.currentUserInstance?.role;
                                    final isAsesi = role == 'asesi';
                                    final isAsesor = role == 'asesor';
                                    final jadwalIdStr = (notif.data['jadwal_id'] ?? '').toString().trim();
                                    final jadwalId = int.tryParse(jadwalIdStr);

                                    if (isAsesor) {
                                      if (type == 'spt_asesor' ||
                                          type == 'rekomendasi_asesor' ||
                                          type == 'pendaftaran_asesor' ||
                                          type.contains('jadwal')) {
                                        state.setTab(1); // Asesor: Tab Jadwal
                                      } else if (type == 'status_kompeten' ||
                                          type == 'sertifikat_terbit') {
                                        state.setTab(3); // Asesor: Tab Statistik/Sertifikat
                                      } else {
                                        state.setTab(1);
                                      }
                                    } else if (isAsesi) {
                                      if (type == 'status_kompeten' ||
                                          type == 'sertifikat_terbit') {
                                        state.setTab(3); // Asesi: Tab Sertifikat
                                      } else if (type == 'spt_asesor' ||
                                          type == 'rekomendasi_asesor' ||
                                          type == 'link_persetujuan_asesmen' ||
                                          type == 'persetujuan_asesmen' ||
                                          type == 'link_umpan_balik' ||
                                          type == 'umpan_balik' ||
                                          type == 'link_tugas_praktek' ||
                                          type == 'tugas_praktek' ||
                                          type == 'link_kegiatan_terstruktur' ||
                                          type == 'kegiatan_terstruktur') {
                                        state.setTab(2); // Asesi: Tab Jadwal
                                      } else {
                                        state.setTab(2);
                                      }
                                    } else {
                                      // Admin
                                      if (type == 'status_kompeten' ||
                                          type == 'sertifikat_terbit') {
                                        state.setTab(3);
                                      } else {
                                        state.setTab(2);
                                      }
                                    }

                                    final navContext = navigatorKey.currentContext ?? context;

                                    // 1. FAQ direct navigation
                                    if (type == 'faq') {
                                      Navigator.push(
                                        navContext,
                                        MaterialPageRoute(
                                          builder: (context) => const FaqScreen(),
                                        ),
                                      );
                                      return;
                                    }

                                    // 2. Direct Jadwal / Form Navigation if specific jadwal_id is provided
                                    if (jadwalId != null && jadwalId > 0) {
                                      final currentUser = AuthRepository.currentUserInstance;
                                      final userRole = currentUser != null
                                          ? UserRole(
                                              role: currentUser.role,
                                              name: currentUser.name,
                                              email: currentUser.email ?? '',
                                            )
                                          : const UserRole(role: 'asesor', name: 'User', email: '');

                                      final jadwalItem = JadwalItem(
                                        id: jadwalId,
                                        skema: (notif.data['skema'] ?? notif.data['nama_jadwal'] ?? 'Jadwal Asesmen').toString(),
                                        tuk: (notif.data['tuk'] ?? 'TUK Mandiri').toString(),
                                        tanggalMulai: (notif.data['tanggal'] ?? '').toString(),
                                        tanggalSelesai: (notif.data['tanggal'] ?? '').toString(),
                                        createdWhen: '',
                                        status: 'running',
                                        statusJadwal: '3',
                                        statusLabel: 'Aktif',
                                        statusJadwalLabel: 'Aktif',
                                        statusRekaman: '',
                                        statusBlanko: '',
                                        statusPengiriman: '',
                                        jumlahAsesi: 0,
                                        asesor: [],
                                        sisaHari: 0,
                                        totalAsesi: 0,
                                        jumlahKompeten: 0,
                                        jumlahBelumKompeten: 0,
                                        needsAcc: false,
                                      );

                                      if (isAsesi && (type == 'link_umpan_balik' || type == 'umpan_balik')) {
                                        Navigator.push(
                                          navContext,
                                          MaterialPageRoute(
                                            builder: (context) => AsesiAK03FormScreen(
                                              jadwal: jadwalItem,
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          navContext,
                                          MaterialPageRoute(
                                            builder: (context) => JadwalDetailScreen(
                                              jadwal: jadwalItem,
                                              userRole: userRole,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  onDelete: () async {
                                    await AppNotificationStorage.instance
                                        .deleteNotification(notif.id);
                                    _refreshAppNotifications();
                                  },
                                );
                              },
                            )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class AppNotificationCard extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onActionPressed;

  const AppNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
    this.onActionPressed,
  });

  @override
  State<AppNotificationCard> createState() => _AppNotificationCardState();
}

class _AppNotificationCardState extends State<AppNotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final type = notification.type.toLowerCase();
    IconData iconData = Icons.notifications_active_rounded;
    Color iconColor = const Color(0xFF4A9EDF);

    if (type == 'spt_asesor') {
      iconData = Icons.assignment_ind_rounded;
      iconColor = const Color(0xFF0284C7); // Sky Blue
    } else if (type == 'rekomendasi_asesor') {
      iconData = Icons.rate_review_rounded;
      iconColor = const Color(0xFFFF9800); // Orange
    } else if (type == 'link_persetujuan_asesmen' || type == 'persetujuan_asesmen') {
      iconData = Icons.fact_check_rounded;
      iconColor = const Color(0xFF10B981); // Emerald
    } else if (type == 'link_umpan_balik' || type == 'umpan_balik') {
      iconData = Icons.feedback_rounded;
      iconColor = const Color(0xFF8B5CF6); // Purple
    } else if (type == 'link_tugas_praktek' || type == 'tugas_praktek') {
      iconData = Icons.draw_rounded;
      iconColor = const Color(0xFF06B6D4); // Cyan
    } else if (type == 'link_kegiatan_terstruktur' || type == 'kegiatan_terstruktur') {
      iconData = Icons.view_timeline_rounded;
      iconColor = const Color(0xFFF59E0B); // Amber
    } else if (type == 'pendaftaran_asesor') {
      iconData = Icons.person_add_alt_1_rounded;
      iconColor = const Color(0xFF3B82F6); // Blue
    } else if (type == 'faq') {
      iconData = Icons.help_outline_rounded;
      iconColor = const Color(0xFF64748B); // Slate
    } else if (type == 'status_kompeten') {
      iconData = Icons.verified_user_rounded;
      iconColor = const Color(0xFF2E7D32); // Green
    } else if (type == 'sertifikat_terbit') {
      iconData = Icons.workspace_premium_rounded;
      iconColor = const Color(0xFFE0A96D); // Gold
    }

    // Mute colors if read
    if (notification.isRead) {
      iconColor = const Color(0xFF94A3B8); // Muted grey
    }

    final hasAction = widget.onActionPressed != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: const BoxDecoration(color: Color(0xFFFFEBEE)),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFC62828),
          ),
        ),
        onDismissed: (_) => widget.onDelete(),
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFFF8F9FA)
                : const Color(0xFFE3F2FD).withValues(alpha: 0.35),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xFFE9ECEF)
                  : const Color(0xFF90CAF9).withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              widget.onTap();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(
                            alpha: notification.isRead ? 0.05 : 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: notification.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                      color: notification.isRead
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                if (!notification.isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4A9EDF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 6),
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              style: TextStyle(
                                fontSize: 12,
                                color: notification.isRead
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF334155),
                                height: 1.3,
                              ),
                              maxLines: _isExpanded ? null : 2,
                              overflow: _isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatRelativeTime(notification.timestamp),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isExpanded && hasAction) ...[
                    const SizedBox(height: 12),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE9ECEF),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onActionPressed,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _getActionLabel(notification.type),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4A9EDF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getActionLabel(String type) {
    final t = type.toLowerCase();
    if (t == 'spt_asesor') return 'Detail Jadwal';
    if (t == 'rekomendasi_asesor') return 'Lihat Jadwal';
    if (t == 'link_persetujuan_asesmen' || t == 'persetujuan_asesmen') return 'Persetujuan Asesmen';
    if (t == 'link_umpan_balik' || t == 'umpan_balik') return 'Isi Umpan Balik';
    if (t == 'link_tugas_praktek' || t == 'tugas_praktek') return 'Tugas Praktek';
    if (t == 'link_kegiatan_terstruktur' || t == 'kegiatan_terstruktur') return 'Kegiatan Terstruktur';
    if (t == 'pendaftaran_asesor') return 'Detail Pendaftaran';
    if (t == 'faq') return 'Buka FAQ';
    if (t == 'status_kompeten' || t == 'sertifikat_terbit') return 'Buka Sertifikat';
    return 'Detail Jadwal';
  }

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return DateFormatHelper.formatToIndonesian(
        dateTime.toIso8601String().split('T')[0],
      );
    }
  }
}

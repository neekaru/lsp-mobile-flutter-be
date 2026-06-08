import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/jadwal_models.dart';
import '../helpers/date_format_helper.dart';
import '../services/app_notification_storage.dart';
import '../services/notification_service.dart';
import '../main.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _notificationCount = 0;
  StreamSubscription<void>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
    _notificationSubscription = NotificationService.onNotificationReceived.stream.listen((_) {
      _loadNotificationCount();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadNotificationCount() async {
    final backendCount = await ApiService.getNotificationCount();
    final unreadLocalCount = await AppNotificationStorage.instance.getUnreadCount();
    if (mounted) {
      setState(() {
        _notificationCount = backendCount + unreadLocalCount;
      });
    }
  }

  void _showNotificationPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    ).then((_) {
      // Refresh count after closing panel
      _loadNotificationCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: _showNotificationPanel,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF5252),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _notificationCount > 99 ? '99+' : '$_notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

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
    _notificationSubscription = NotificationService.onNotificationReceived.stream.listen((_) {
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
    final localNotifs = await AppNotificationStorage.instance.getNotifications();
    final unreadLocalCount = await AppNotificationStorage.instance.getUnreadCount();

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
    final localNotifs = await AppNotificationStorage.instance.getNotifications();
    final unreadLocalCount = await AppNotificationStorage.instance.getUnreadCount();
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
                        icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
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
                                Icon(Icons.done_all, size: 18, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Tandai Semua Dibaca'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'clear_all',
                            child: Row(
                              children: [
                                Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus Semua'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
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
                            color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
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
                                color: _selectedTab == 0 ? const Color(0xFF4A9EDF) : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Jadwal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedTab == 0 ? const Color(0xFF1E293B) : Colors.grey[600],
                                ),
                              ),
                              if (_totalWaiting > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF5252),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
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
                                color: _selectedTab == 1 ? const Color(0xFF4A9EDF) : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Aplikasi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedTab == 1 ? const Color(0xFF1E293B) : Colors.grey[600],
                                ),
                              ),
                              if (_unreadAppCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4A9EDF),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return NotificationCard(
                                    schedule: _schedules[index],
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
                                subtitle: 'Anda akan menerima pemberitahuan penting di sini',
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _appNotifications.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final notif = _appNotifications[index];
                                  return AppNotificationCard(
                                    notification: notif,
                                    onTap: () async {
                                      await AppNotificationStorage.instance.markAsRead(notif.id);
                                      _refreshAppNotifications();
                                    },
                                    onActionPressed: () {
                                      Navigator.pop(context); // Close bottom sheet
                                      final type = notif.type;
                                      if (type == 'status_kompeten' || type == 'sertifikat_terbit') {
                                        mainNavigatorKey.currentState?.setTab(3); // Switch to Sertifikat Tab
                                      } else if (type == 'rekomendasi_asesor') {
                                        mainNavigatorKey.currentState?.setTab(2); // Switch to Jadwal Tab
                                      }
                                    },
                                    onDelete: () async {
                                      await AppNotificationStorage.instance.deleteNotification(notif.id);
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
          Icon(
            icon,
            size: 80,
            color: Colors.grey[300],
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
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
    IconData iconData = Icons.notifications_active_rounded;
    Color iconColor = const Color(0xFF4A9EDF);

    if (notification.type == 'status_kompeten') {
      iconData = Icons.verified_user_rounded;
      iconColor = const Color(0xFF2E7D32);
    } else if (notification.type == 'rekomendasi_asesor') {
      iconData = Icons.rate_review_rounded;
      iconColor = const Color(0xFFFF9800);
    } else if (notification.type == 'sertifikat_terbit') {
      iconData = Icons.workspace_premium_rounded;
      iconColor = const Color(0xFFE0A96D);
    }

    // Mute colors if read
    if (notification.isRead) {
      iconColor = const Color(0xFF94A3B8); // Muted grey
    }

    final hasAction = widget.onActionPressed != null &&
        (notification.type == 'status_kompeten' ||
            notification.type == 'rekomendasi_asesor' ||
            notification.type == 'sertifikat_terbit');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFFFEBEE),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFC62828),
          ),
        ),
        onDismissed: (_) => widget.onDelete(),
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? const Color(0xFFF8F9FA) : const Color(0xFFE3F2FD).withValues(alpha: 0.35),
            border: Border.all(
              color: notification.isRead ? const Color(0xFFE9ECEF) : const Color(0xFF90CAF9).withValues(alpha: 0.5),
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
                          color: iconColor.withValues(alpha: notification.isRead ? 0.05 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: iconColor,
                          size: 20,
                        ),
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
                                      fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                                      color: notification.isRead ? const Color(0xFF64748B) : const Color(0xFF1E293B),
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
                                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
                                color: notification.isRead ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                                height: 1.3,
                              ),
                              maxLines: _isExpanded ? null : 2,
                              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onActionPressed,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text(
                            notification.type == 'rekomendasi_asesor' ? 'Lihat Jadwal' : 'Buka Sertifikat',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4A9EDF),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return DateFormatHelper.formatToIndonesian(dateTime.toIso8601String().split('T')[0]);
    }
  }
}

class NotificationCard extends StatelessWidget {
  final WaitingSchedule schedule;
  final VoidCallback onTap;
  final VoidCallback onStatusUpdated;

  const NotificationCard({
    super.key,
    required this.schedule,
    required this.onTap,
    required this.onStatusUpdated,
  });

  void _confirmStatusUpdate(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF2E7D32),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Konfirmasi Jadwal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin mengonfirmasi jadwal "${schedule.jadwal}"?\n\nStatus jadwal ini akan berubah menjadi Running.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF455A64),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _performStatusUpdate(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Konfirmasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performStatusUpdate(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            ),
          ),
        );
      },
    );

    // Call API
    final result = await ApiService.updateJadwalStatus(
      jadwalId: schedule.id,
      rule: 'draft_to_ongoing',
    );

    // Hide loading indicator
    if (context.mounted) {
      Navigator.pop(context);
    }

    if (result['success'] == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jadwal "${schedule.jadwal}" berhasil dikonfirmasi ke Running.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      onStatusUpdated();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Gagal memperbarui status jadwal.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE9ECEF),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.statusLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Jadwal Name
            Text(
              schedule.jadwal,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // TUK Info
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    schedule.tuk,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Date Info
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateRange(schedule.tanggal, schedule.tanggalAkhir),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom Info
            Row(
              children: [
                // Asesi Count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 12,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${schedule.jumlahAsesi} Asesi',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Asesor
                Expanded(
                  child: Text(
                    'Asesor: ${schedule.asesor}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _confirmStatusUpdate(context),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Konfirmasi Jadwal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32), // Forest Green
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(String startDate, String? endDate) {
    try {
      final start = DateFormatHelper.formatToIndonesian(startDate);
      if (endDate == null || endDate.isEmpty) {
        return start;
      }
      final end = DateFormatHelper.formatToIndonesian(endDate);
      return '$start - $end';
    } catch (e) {
      return startDate;
    }
  }
}

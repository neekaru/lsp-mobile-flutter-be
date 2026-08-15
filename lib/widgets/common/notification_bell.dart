import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/common/app_notification_storage.dart';
import '../../services/common/notification_service.dart';
import '../../services/auth/auth_repository.dart';
import 'notification_panel.dart';

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
    // Skip notification setup for guests to avoid 401 Unauthorized errors
    if (AuthRepository.currentUserInstance == null) return;

    // Defer notification loading by 1s to avoid initial API burst
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadNotificationCount();
      }
    });
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
    // Hide UI icon and disable modal panel entirely for guest users
    if (AuthRepository.currentUserInstance == null) {
      return const SizedBox.shrink();
    }

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

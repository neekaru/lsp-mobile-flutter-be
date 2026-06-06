import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_repository.dart';
import '../main.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request Permission
    await requestPermission();

    // 2. Set up foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Listen to Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📨 Foreground FCM: ${message.notification?.title}');
      }
      _showForegroundNotification(message);
    });

    // 4. Listen to Notification Clicks (App in background but running)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📨 FCM Clicked (Background): ${message.data}');
      }
      _handleNotificationClick(message);
    });

    // 5. Check if app was opened from a terminated state via notification
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint('📨 FCM Clicked (Terminated): ${initialMessage.data}');
      }
      // Delay click handling slightly to ensure navigation tree is fully built
      Future.delayed(const Duration(milliseconds: 1000), () {
        _handleNotificationClick(initialMessage);
      });
    }

    // Register pre-logout hook to unregister FCM token before auth token is cleared
    AuthRepository.preLogoutHooks.add(() async {
      await unregisterCurrentToken();
    });

    _isInitialized = true;
  }

  Future<void> requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        debugPrint('User notification permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> registerCurrentToken() async {
    final user = AuthRepository.currentUserInstance;
    if (user == null) {
      if (kDebugMode) {
        debugPrint('ℹ️ FCM Token Registration skipped: User is null.');
      }
      return;
    }

    final fcmToken = await getToken();
    if (fcmToken == null) {
      debugPrint('⚠️ Cannot register FCM token: token is null.');
      return;
    }

    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final response = await ApiService.dio.post(
        '/api/notifications/register',
        data: {
          'device_token': fcmToken,
          'platform': platform,
        },
      );
      if (kDebugMode) {
        debugPrint('✅ FCM Token registered successfully: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error registering FCM Token to backend: $e');
    }
  }

  Future<void> unregisterCurrentToken() async {
    final user = AuthRepository.currentUserInstance;
    if (user == null) {
      return;
    }

    final fcmToken = await getToken();
    if (fcmToken == null) {
      debugPrint('⚠️ Cannot unregister FCM token: token is null.');
      return;
    }

    try {
      final response = await ApiService.dio.post(
        '/api/notifications/unregister',
        data: {
          'device_token': fcmToken,
        },
      );
      if (kDebugMode) {
        debugPrint('✅ FCM Token unregistered successfully: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error unregistering FCM Token from backend: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? _getTitleFromData(message.data);
    final body = message.notification?.body ?? _getBodyFromData(message.data);
    final type = message.data['type'] ?? '';

    // Choose icon and color based on notification type
    IconData iconData = Icons.notifications_active_rounded;
    Color iconColor = const Color(0xFF4A9EDF);

    if (type == 'status_kompeten') {
      iconData = Icons.verified_user_rounded;
      iconColor = const Color(0xFF2E7D32); // Competent Green
    } else if (type == 'rekomendasi_asesor') {
      iconData = Icons.rate_review_rounded;
      iconColor = const Color(0xFFFF9800); // Recommendation Orange
    } else if (type == 'sertifikat_terbit') {
      iconData = Icons.workspace_premium_rounded;
      iconColor = const Color(0xFFE0A96D); // Certificate Gold
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        duration: const Duration(seconds: 5),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type accent bar
                  Container(
                    width: 6,
                    color: iconColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Leading Circular Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              color: iconColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Notification Texts
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  body,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // View Button
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              _handleNotificationClick(message);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: const Size(60, 36),
                              backgroundColor: iconColor.withValues(alpha: 0.08),
                              foregroundColor: iconColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Buka',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    final type = message.data['type'] ?? '';
    if (kDebugMode) {
      debugPrint('Handling notification click: type=$type, data=${message.data}');
    }

    if (type == 'status_kompeten' || type == 'sertifikat_terbit') {
      // Switch to Sertifikat Tab (Index 3)
      mainNavigatorKey.currentState?.setTab(3);
    } else if (type == 'rekomendasi_asesor') {
      // Switch to Jadwal Tab (Index 2)
      mainNavigatorKey.currentState?.setTab(2);
    }
  }

  String _getTitleFromData(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    switch (type) {
      case 'status_kompeten':
        return 'Status Kelulusan';
      case 'rekomendasi_asesor':
        return 'Rekomendasi Asesor';
      case 'sertifikat_terbit':
        return 'Sertifikat Terbit';
      default:
        return 'Notifikasi Baru';
    }
  }

  String _getBodyFromData(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    final skema = data['skema'] ?? 'Skema';
    final asesor = data['asesor'] ?? 'Asesor';
    
    switch (type) {
      case 'status_kompeten':
        return 'Selamat! Anda dinyatakan kompeten pada skema $skema.';
      case 'rekomendasi_asesor':
        return 'Asesor $asesor telah memberikan rekomendasi.';
      case 'sertifikat_terbit':
        return 'Sertifikat untuk skema $skema telah diterbitkan.';
      default:
        return 'Ketuk untuk melihat detail selengkapnya.';
    }
  }

  // Simulates an incoming notification (useful for testing/demo)
  void simulateIncomingNotification(RemoteMessage message) {
    _showForegroundNotification(message);
  }

  // Simulates a notification click (useful for testing/demo)
  void simulateNotificationClick(RemoteMessage message) {
    _handleNotificationClick(message);
  }
}

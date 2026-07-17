import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:januscaler_flutter_ringtone_player/flutter_ringtone_player.dart';
import 'api_service.dart';
import 'auth_repository.dart';
import '../helpers/api_routes.dart';
import '../main.dart';
import '../widgets/top_notification_banner.dart';
import 'app_notification_storage.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  static final StreamController<void> onNotificationReceived = StreamController<void>.broadcast();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Register hooks to clear FCM token on logout or token expiration
    AuthRepository.preLogoutHooks.add(() async {
      await deleteToken();
    });
    AuthRepository.registerTokenExpiredCallback(() {
      deleteToken();
    });

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

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      if (kDebugMode) {
        debugPrint('✅ FCM Token deleted successfully from Firebase.');
      }
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
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
        ApiRoutes.notificationsRegister,
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

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final currentUserId = AuthRepository.currentUserInstance?.id;
    final notifUserId = message.data['user_id']?.toString();

    if (notifUserId != null && notifUserId.isNotEmpty) {
      if (currentUserId == null || notifUserId != currentUserId) {
        if (kDebugMode) {
          debugPrint('⚠️ Ignored foreground notification: user_id mismatch (notif: $notifUserId, current: $currentUserId)');
        }
        return;
      }
    }

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

    // 1. Save to local notifications storage so they can be viewed again
    await AppNotificationStorage.instance.saveNotification(
      title,
      body,
      type,
      message.data,
    );

    // Notify listeners that a new notification has been saved
    onNotificationReceived.add(null);

    // Play default notification sound in foreground
    try {
      FlutterRingtonePlayer().playNotification();
    } catch (e) {
      debugPrint('⚠️ Error playing notification sound: $e');
    }

    // Retrieve OverlayState using the global navigatorKey to display banner above any active screen/dialog
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    // 2. Show top notification banner (overlay)
    TopNotificationBanner.show(
      overlayState: overlayState,
      title: title,
      body: body,
      icon: iconData,
      color: iconColor,
      onTap: () {
        _handleNotificationClick(message);
      },
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    final currentUserId = AuthRepository.currentUserInstance?.id;
    final notifUserId = message.data['user_id']?.toString();

    if (notifUserId != null && notifUserId.isNotEmpty) {
      if (currentUserId == null || notifUserId != currentUserId) {
        if (kDebugMode) {
          debugPrint('⚠️ Ignored notification click: user_id mismatch (notif: $notifUserId, current: $currentUserId)');
        }
        return;
      }
    }

    final type = message.data['type'] ?? '';
    if (kDebugMode) {
      debugPrint('Handling notification click: type=$type, data=${message.data}');
    }

    final title = message.notification?.title ?? _getTitleFromData(message.data);
    final body = message.notification?.body ?? _getBodyFromData(message.data);

    // Save notification locally just in case it was a background click and wasn't stored yet
    AppNotificationStorage.instance.saveNotification(
      title,
      body,
      type,
      message.data,
    );

    // Defensive: only call setTab if MainNavigator is alive and mounted.
    // Prevents "setState() called after dispose()" when FCM fires after logout.
    final state = mainNavigatorKey.currentState;
    if (state == null || !state.mounted) {
      if (kDebugMode) {
        debugPrint('⚠️ MainNavigator not mounted, skipping setTab for notification');
      }
      return;
    }

    final isAsesi = AuthRepository.currentUserInstance?.role == 'asesi';
    if (isAsesi) {
      if (type == 'status_kompeten' || type == 'sertifikat_terbit') {
        state.setTab(3); // Switch to Sertifikat tab
      } else if (type == 'rekomendasi_asesor') {
        state.setTab(2); // Switch to Jadwal tab
      }
    } else {
      if (type == 'status_kompeten' || type == 'sertifikat_terbit') {
        state.setTab(3); // Switch to Sertifikat tab
      } else if (type == 'rekomendasi_asesor') {
        state.setTab(2); // Switch to Jadwal tab
      }
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

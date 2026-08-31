import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:januscaler_flutter_ringtone_player/flutter_ringtone_player.dart';
import '../api_service.dart';
import '../auth/auth_repository.dart';
import '../../utils/api_routes.dart';
import '../../models/jadwal_models.dart';
import '../../screens/jadwal/jadwal_detail_screen.dart';
import '../../screens/dashboard/faq_screen.dart';
import '../../screens/asesi/asesi_ak03_form_screen.dart';
import '../../core/navigation/main_navigator.dart';
import '../../widgets/common/top_notification_banner.dart';
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
    final type = (message.data['type'] ?? '').toString().toLowerCase();

    // Choose icon and color based on notification type
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
      iconColor = const Color(0xFF2E7D32); // Competent Green
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

    final type = (message.data['type'] ?? '').toString().toLowerCase();
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

    navigateFromNotificationData(
      null,
      type: type,
      data: message.data,
    );
  }

  /// Centralized notification routing for both push notifications and in-app clicks
  static void navigateFromNotificationData(
    BuildContext? context, {
    required String type,
    required Map<String, dynamic> data,
  }) {
    final cleanType = type.toLowerCase().trim();
    final state = mainNavigatorKey.currentState;
    if (state == null || !state.mounted) {
      if (kDebugMode) {
        debugPrint('⚠️ MainNavigator not mounted, skipping setTab for notification');
      }
      return;
    }

    final role = AuthRepository.currentUserInstance?.role;
    final isAsesi = role == 'asesi';
    final isAsesor = role == 'asesor';
    final jadwalIdStr = (data['jadwal_id'] ?? '').toString().trim();
    final jadwalId = int.tryParse(jadwalIdStr);

    if (isAsesor) {
      if (cleanType == 'spt_asesor' ||
          cleanType == 'rekomendasi_asesor' ||
          cleanType == 'pendaftaran_asesor' ||
          cleanType.contains('jadwal')) {
        state.setTab(1); // Asesor: Tab Jadwal
      } else if (cleanType == 'status_kompeten' || cleanType == 'sertifikat_terbit') {
        state.setTab(3); // Asesor: Tab Statistik/Sertifikat
      } else {
        state.setTab(1);
      }
    } else if (isAsesi) {
      if (cleanType == 'status_kompeten' || cleanType == 'sertifikat_terbit') {
        state.setTab(3); // Asesi: Tab Sertifikat
      } else if (cleanType == 'spt_asesor' ||
          cleanType == 'rekomendasi_asesor' ||
          cleanType == 'link_persetujuan_asesmen' ||
          cleanType == 'persetujuan_asesmen' ||
          cleanType == 'link_umpan_balik' ||
          cleanType == 'umpan_balik' ||
          cleanType == 'link_tugas_praktek' ||
          cleanType == 'tugas_praktek' ||
          cleanType == 'link_kegiatan_terstruktur' ||
          cleanType == 'kegiatan_terstruktur') {
        state.setTab(2); // Asesi: Tab Jadwal
      } else {
        state.setTab(2);
      }
    } else {
      if (cleanType == 'status_kompeten' || cleanType == 'sertifikat_terbit') {
        state.setTab(3);
      } else {
        state.setTab(2);
      }
    }

    final navContext = context ?? navigatorKey.currentContext;

    // 1. FAQ direct navigation
    if (cleanType == 'faq' && navContext != null) {
      Navigator.push(
        navContext,
        MaterialPageRoute(
          builder: (context) => const FaqScreen(),
        ),
      );
      return;
    }

    // 2. Direct Jadwal / Form Navigation if specific jadwal_id is provided
    if (jadwalId != null && jadwalId > 0 && navContext != null) {
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
        skema: (data['skema'] ?? data['nama_jadwal'] ?? 'Jadwal Asesmen').toString(),
        tuk: (data['tuk'] ?? 'TUK Mandiri').toString(),
        tanggalMulai: (data['tanggal'] ?? '').toString(),
        tanggalSelesai: (data['tanggal'] ?? '').toString(),
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

      if (isAsesi && (cleanType == 'link_umpan_balik' || cleanType == 'umpan_balik')) {
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
  }

  String _getTitleFromData(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    switch (type) {
      case 'spt_asesor':
        return 'SPT Asesor';
      case 'rekomendasi_asesor':
        return 'Rekomendasi Asesor';
      case 'link_persetujuan_asesmen':
      case 'persetujuan_asesmen':
        return 'Persetujuan Asesmen';
      case 'link_umpan_balik':
      case 'umpan_balik':
        return 'Mengisi Umpan Balik';
      case 'link_tugas_praktek':
      case 'tugas_praktek':
        return 'Tugas Praktek';
      case 'link_kegiatan_terstruktur':
      case 'kegiatan_terstruktur':
        return 'Kegiatan Terstruktur';
      case 'pendaftaran_asesor':
        return 'Pendaftaran Asesor';
      case 'faq':
        return 'Bantuan FAQ';
      case 'status_kompeten':
        return 'Status Kelulusan';
      case 'sertifikat_terbit':
        return 'Sertifikat Terbit';
      default:
        return 'Notifikasi Baru';
    }
  }

  String _getBodyFromData(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    final skema = data['skema'] ?? 'Skema';
    final asesor = data['asesor'] ?? 'Asesor';
    
    switch (type) {
      case 'spt_asesor':
        return 'SPT Melaksanakan Asesmen Jadwal ${data['nama_jadwal'] ?? skema}';
      case 'rekomendasi_asesor':
        return 'Asesor $asesor telah memberikan rekomendasi asesmen.';
      case 'link_persetujuan_asesmen':
      case 'persetujuan_asesmen':
        return 'Silakan lakukan persetujuan asesmen untuk skema $skema.';
      case 'link_umpan_balik':
      case 'umpan_balik':
        return 'Lakukan umpan balik terhadap proses sertifikasi $skema.';
      case 'link_tugas_praktek':
      case 'tugas_praktek':
        return 'Silakan kerjakan tugas praktek untuk skema $skema.';
      case 'link_kegiatan_terstruktur':
      case 'kegiatan_terstruktur':
        return 'Silakan lengkapi kegiatan terstruktur untuk skema $skema.';
      case 'pendaftaran_asesor':
        return 'Pendaftaran penugasan asesor telah diperbarui.';
      case 'faq':
        return 'Informasi bantuan dan pertanyaan umum terbaru.';
      case 'status_kompeten':
        return 'Selamat! Anda dinyatakan kompeten pada skema $skema.';
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

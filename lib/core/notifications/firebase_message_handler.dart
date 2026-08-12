import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../../services/common/app_notification_storage.dart';
import '../../services/auth/token_storage.dart';

/// Background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    debugPrint('📨 Background message received!');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  }

  final data = message.data;
  final notifUserId = data['user_id']?.toString();

  if (notifUserId != null && notifUserId.isNotEmpty) {
    final cachedUser = await TokenStorage.instance.getUserProfile();
    final currentUserId = cachedUser?.id;
    if (currentUserId == null || notifUserId != currentUserId) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Ignored background notification: user_id mismatch (notif: $notifUserId, current: $currentUserId)',
        );
      }
      return;
    }
  }

  final type = data['type'] ?? '';

  String getTitle() {
    if (message.notification?.title != null) {
      return message.notification!.title!;
    }
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

  String getBody() {
    if (message.notification?.body != null) {
      return message.notification!.body!;
    }
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

  final title = getTitle();
  final body = getBody();

  await AppNotificationStorage.instance.saveNotification(
    title,
    body,
    type,
    data,
  );
}

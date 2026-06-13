import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  String _lastMessage = 'No message received yet';

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _getToken();
    _setupForegroundMessageHandler();
  }

  // Request notification permission (required for iOS and Android 13+)
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('✅ User granted notification permission');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        debugPrint('⚠️ User granted provisional notification permission');
      }
    } else {
      if (kDebugMode) {
        debugPrint('❌ User declined or has not accepted notification permission');
      }
    }
  }

  // Get FCM token
  Future<void> _getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      setState(() {
        _fcmToken = token;
      });
      if (kDebugMode) {
        debugPrint('📱 FCM Token: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting FCM token: $e');
      }
    }
  }

  // Setup foreground message handler
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📨 Foreground message received!');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
      }

      setState(() {
        _lastMessage = 
            'Title: ${message.notification?.title ?? 'No title'}\n'
            'Body: ${message.notification?.body ?? 'No body'}\n'
            'Data: ${message.data}';
      });

      // Show a dialog or snackbar when message arrives
      if (message.notification != null) {
        _showNotificationDialog(
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? 'No content',
        );
      }
    });
  }

  void _showNotificationDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Notifications'),
        backgroundColor: const Color(0xFF4A9EDF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCM Token:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _fcmToken ?? 'Loading token...',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Last Message:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                _lastMessage,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9EDF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh Token'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:geocode_cache/geocode_cache.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/notifications/firebase_message_handler.dart';
import 'services/common/geojson_manager.dart';
import 'services/common/notification_service.dart';
import 'services/auth/token_storage.dart';
import 'services/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize geocode_cache to save Geocoding API calls with Haversine distance caching
  try {
    GeocodingService.instance.configure(
      options: const GeocodeCacheOptions(
        cacheRadiusMeters: 20.0,
        maxAge: Duration(days: 7),
        maxCacheSize: 500,
        userAgent: 'LSPDigitalMobile/1.2 (asesor@lsp-digital.id)',
      ),
    );
    await GeocodingService.instance.init();
    if (kDebugMode) debugPrint('✅ GeocodingService cache initialized');
  } catch (e) {
    debugPrint('⚠️ GeocodingService init warning: $e');
  }

  // Initialize date formatting locale data
  try {
    await initializeDateFormatting('id_ID', null);
    if (kDebugMode) {
      debugPrint('✅ Locale date formatting (id_ID) initialized successfully');
    }
  } catch (e) {
    debugPrint('❌ ERROR initializing date formatting: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized successfully');
    }

    // Initialize FCM Notification Service
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('❌ ERROR initializing Firebase/Notifications: $e');
  }

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Load environment variables securely from .env
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      debugPrint('✅ .env loaded successfully');
      debugPrint('📍 BASE_URL: ${dotenv.env['BASE_URL']}');
    }

    // Check if BASE_URL is empty or null
    if (dotenv.env['BASE_URL'] == null || dotenv.env['BASE_URL']!.isEmpty) {
      debugPrint('⚠️ WARNING: BASE_URL is null or empty!');
    }
  } catch (e) {
    debugPrint('❌ ERROR loading .env: $e');
    debugPrint('⚠️ Using fallback configuration');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Pre-warm TokenStorage cache ONCE during splash. EncryptedSharedPreferences'
  // first read does heavy KeyStore + AES work on Android's main thread and can
  // block the Choreographer for 1-2s. Doing it here BEFORE any screen builds
  // ensures that when MainNavigator's 5 screens fire their initState API
  // calls, getAccessToken() hits the in-memory cache (instant) instead of
  // queuing 7-10 platform-channel reads.
  try {
    await TokenStorage.instance.getAccessToken();
    if (kDebugMode) debugPrint('✅ TokenStorage cache pre-warmed');
  } catch (e) {
    debugPrint('⚠️ Token pre-warm failed (non-fatal): $e');
  }

  // Pre-warm GeoJSON parsing di background (fire-and-forget). Saat user buka
  // layar Statistik, peta sudah siap render -> mengurangi jeda "abu-abu dulu
  // baru biru". Tidak di-await agar tidak menunda runApp.
  GeoJsonManager.instance.initialize().catchError(
    (e) => debugPrint('⚠️ GeoJSON pre-warm failed: $e'),
  );

  // Register the app-level token-expiry listener. This covers the window
  // before MainNavigatorState mounts (splash/onboarding/login) so an expired
  // session during cold start never leaves the user stuck.
  SessionManager.init();

  runApp(const MainApp());
}

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

class TokenStorage {
  TokenStorage._privateConstructor();

  static final TokenStorage instance = TokenStorage._privateConstructor();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userProfileKey = 'user_profile';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  // In-memory cache so the interceptor doesn't hit EncryptedSharedPreferences
  // (which runs on Android's main thread and can block the Choreographer
  // for 1-2s on first read) for every single request.
  static String? _cachedAccessToken;

  // Deduplicate concurrent first reads so only ONE platform-channel read
  // happens; subsequent callers await the same in-flight future.
  static Future<String?>? _pendingAccessTokenRead;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    _cachedAccessToken = accessToken;
  }

  Future<void> saveUserProfile(AuthUser user) async {
    try {
      final rawJson = jsonEncode(user.toJson());
      await _storage.write(key: _userProfileKey, value: rawJson);
    } catch (e) {
      // Ignore
    }
  }

  Future<AuthUser?> getUserProfile() async {
    try {
      final rawJson = await _storage.read(key: _userProfileKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        return AuthUser.fromJson(decoded);
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  /// Reads the access token from in-memory cache (instant). On cache miss,
  /// performs exactly ONE EncryptedSharedPreferences read via platform channel —
  /// subsequent concurrent calls share the same in-flight future to avoid
  /// blocking Android's main thread with a chain of platform-channel reads.
  Future<String?> getAccessToken() async {
    final cached = _cachedAccessToken;
    if (cached != null) return cached;
    _pendingAccessTokenRead ??= _storage.read(key: _accessTokenKey).then((t) {
      _cachedAccessToken = t;
      _pendingAccessTokenRead = null;
      return t;
    });
    return _pendingAccessTokenRead;
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _hasSeenOnboardingKey);
    return value == 'true';
  }

  Future<void> setHasSeenOnboarding(bool seen) async {
    await _storage.write(
      key: _hasSeenOnboardingKey,
      value: seen ? 'true' : 'false',
    );
  }

  /// Clears auth session only. Onboarding flag is kept so returning users
  /// do not see onboarding again after logout.
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userProfileKey);
    _cachedAccessToken = null;
    _pendingAccessTokenRead = null;
  }
}

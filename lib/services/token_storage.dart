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

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
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

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userProfileKey);
  }
}

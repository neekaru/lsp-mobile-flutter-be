import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import 'token_storage.dart';

class AuthRepository {
  AuthRepository({
    required Dio dio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage _tokenStorage;

  static AuthUser? currentUserInstance;

  static final List<Future<void> Function()> preLogoutHooks = [];

  static final List<void Function()> onTokenExpiredCallbacks = [];

  Future<LoginResult> login({
    required String account,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {
        'account': account,
        'password': password,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    final result = LoginResult.fromJson(data);

    await _tokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await _tokenStorage.saveUserProfile(result.user);

    currentUserInstance = result.user;

    return result;
  }

  Future<AuthUser> currentUser() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == 'fake-asesi-token' || token == 'fake-user-token' || token == 'fake-asesor-token') {
      final cached = await _tokenStorage.getUserProfile();
      if (cached != null) {
        currentUserInstance = cached;
        return cached;
      }
      final isAsesi = token == 'fake-asesi-token';
      final isAsesor = token == 'fake-asesor-token';
      final fallbackUser = AuthUser(
        id: isAsesi ? 'fake-asesi-id' : (isAsesor ? 'fake-asesor-id' : 'fake-user-id'),
        account: isAsesi ? 'asesi' : (isAsesor ? 'asesor' : 'user'),
        name: isAsesi ? 'Asesi Demo' : (isAsesor ? 'Muhammad Hanafi' : 'User Demo'),
        role: isAsesi ? 'asesi' : (isAsesor ? 'asesor' : 'admin'),
        roles: [isAsesi ? 'asesi' : (isAsesor ? 'asesor' : 'admin')],
      );
      await _tokenStorage.saveUserProfile(fallbackUser);
      currentUserInstance = fallbackUser;
      return fallbackUser;
    }

    final response = await _dio.get<Map<String, dynamic>>('/api/auth/current');
    final data = response.data?['data'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(data);
    
    await _tokenStorage.saveUserProfile(user);
    currentUserInstance = user;
    return user;
  }

  Future<void> logout({String? deviceToken}) async {
    try {
      await _dio.post(
        '/api/auth/logout',
        data: deviceToken != null ? {
          'device_token': deviceToken,
        } : {},
      );
      if (kDebugMode) {
        debugPrint('✅ Logout API called successfully with deviceToken: $deviceToken');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error calling logout API: $e');
      }
    }

    for (final hook in preLogoutHooks) {
      try {
        await hook();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error executing pre-logout hook: $e');
        }
      }
    }
    await _tokenStorage.clear();
    currentUserInstance = null;
  }

  static void notifyTokenExpired() {
    if (kDebugMode) {
      debugPrint('🔴 Token expired - notifying ${onTokenExpiredCallbacks.length} callbacks');
    }
    for (final callback in onTokenExpiredCallbacks) {
      try {
        callback();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error executing token expired callback: $e');
        }
      }
    }
  }

  static void registerTokenExpiredCallback(void Function() callback) {
    onTokenExpiredCallbacks.add(callback);
  }

  static void unregisterTokenExpiredCallback(void Function() callback) {
    onTokenExpiredCallbacks.remove(callback);
  }
}

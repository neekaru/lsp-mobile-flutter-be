import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../helpers/api_routes.dart';
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
    String? platform,
    String? deviceToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiRoutes.authLogin,
      data: {
        'account': account,
        'password': password,
        'platform': ?platform,
        'device_token': ?deviceToken,
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

  /// Auto-create asesi (default password 123456) if missing, then save session.
  /// [account] = NIM or NIK (max 18 chars).
  Future<LoginResult> ensureAsesi({
    required String account,
    String password = '123456',
    String? namaLengkap,
    String? email,
    String? hp,
    String? platform,
    String? deviceToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiRoutes.authEnsureAsesi,
      data: {
        'account': account.trim(),
        'password': password,
        if (namaLengkap != null && namaLengkap.isNotEmpty)
          'nama_lengkap': namaLengkap,
        if (email != null && email.isNotEmpty) 'email': email,
        if (hp != null && hp.isNotEmpty) 'hp': hp,
        'platform': ?platform,
        'device_token': ?deviceToken,
      },
    );

    final body = response.data;
    final data = body?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body?['message']?.toString() ?? 'ensure-asesi gagal',
      );
    }
    final result = LoginResult.fromJson(data);

    await _tokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await _tokenStorage.saveUserProfile(result.user);
    currentUserInstance = result.user;

    if (kDebugMode) {
      debugPrint(
        '✅ ensure-asesi account=$account created=${body?['created']} role=${result.user.role}',
      );
    }
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

    final response = await _dio.get<Map<String, dynamic>>(ApiRoutes.authCurrent);
    final data = response.data?['data'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(data);
    
    await _tokenStorage.saveUserProfile(user);
    currentUserInstance = user;
    return user;
  }

  Future<void> logout({String? deviceToken}) async {
    try {
      await _dio.post(
        ApiRoutes.authLogout,
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

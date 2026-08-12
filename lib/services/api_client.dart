import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/api_routes.dart';
import 'auth/token_storage.dart';
import 'auth/auth_repository.dart';

// ============================================================================
// API Client — Shared Dio singleton with interceptors
// ============================================================================

class ApiClient {
  ApiClient._();

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Expose publicly for any repo that still needs raw Dio access
  static Dio get dio => _dio;

  static Dio? _dioInstance;
  static bool _isRefreshing = false;

  static Dio get _dio {
    return _dioInstance ??=
        Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
              receiveDataWhenStatusError: false,
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                if (kDebugMode) {
                  debugPrint(
                    '🔵 API Request: ${options.method} ${options.uri}',
                  );
                }
                final token = await TokenStorage.instance.getAccessToken();
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                options.headers['Accept-Encoding'] = 'gzip, deflate';
                return handler.next(options);
              },
              onResponse: (response, handler) {
                if (kDebugMode) {
                  debugPrint(
                    '🟢 API Response: ${response.statusCode} ${response.requestOptions.uri}',
                  );
                }
                return handler.next(response);
              },
              onError: (error, handler) async {
                if (kDebugMode) {
                  debugPrint('🔴 API Error: ${error.message}');
                  debugPrint('🔴 URL: ${error.requestOptions.uri}');
                }

                final isAuthPath = error.requestOptions.path.contains(ApiRoutes.authLogin) ||
                    error.requestOptions.path.contains(ApiRoutes.authRefresh);

                if (error.response?.statusCode == 401 && !isAuthPath) {
                  if (_isRefreshing) {
                    return handler.next(error);
                  }
                  _isRefreshing = true;
                  try {
                    final refreshToken = await TokenStorage.instance.getRefreshToken();
                    if (refreshToken != null && refreshToken.isNotEmpty) {
                      final refreshResponse =
                          await Dio(BaseOptions(baseUrl: baseUrl)).post(
                            ApiRoutes.authRefresh,
                            data: {'refresh_token': refreshToken},
                          );

                      if (refreshResponse.statusCode == 200) {
                        final newAccessToken =
                            refreshResponse.data['data']['access_token'];
                        await TokenStorage.instance.saveTokens(
                          accessToken: newAccessToken,
                          refreshToken: refreshToken,
                        );

                        error.requestOptions.headers['Authorization'] =
                            'Bearer $newAccessToken';
                        _isRefreshing = false;

                        if (kDebugMode) {
                          debugPrint(
                            '🔄 Token refreshed successfully, retrying request',
                          );
                        }
                        return handler.resolve(
                          await _dioInstance!.fetch(error.requestOptions),
                        );
                      } else {
                        throw DioException(
                          requestOptions: refreshResponse.requestOptions,
                          response: refreshResponse,
                          message: 'Token refresh returned non-200 status code: ${refreshResponse.statusCode}',
                        );
                      }
                    } else {
                      throw DioException(
                        requestOptions: error.requestOptions,
                        message: 'No refresh token available',
                      );
                    }
                  } catch (e) {
                    if (kDebugMode) debugPrint('🔴 Token refresh failed: $e');
                    await TokenStorage.instance.clear();
                    AuthRepository.notifyTokenExpired();
                  } finally {
                    _isRefreshing = false;
                  }
                }

                return handler.next(error);
              },
            ),
          );
  }
}

import 'package:dio/dio.dart';
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

  // Keep a global static reference of the logged-in user for app-wide UI/role usage
  static AuthUser? currentUserInstance;

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

    currentUserInstance = result.user;

    return result;
  }

  Future<AuthUser> currentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/auth/current');
    final data = response.data?['data'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(data);
    
    currentUserInstance = user;
    return user;
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    currentUserInstance = null;
  }
}

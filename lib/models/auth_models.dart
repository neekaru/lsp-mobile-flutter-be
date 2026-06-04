class AuthUser {
  AuthUser({
    required this.id,
    required this.account,
    required this.name,
    required this.role,
    required this.roles,
    this.email,
  });

  final String id;
  final String account;
  final String name;
  final String role;
  final List<String> roles;
  final String? email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      account: json['account'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'name': name,
      'role': role,
      'roles': roles,
      'email': email,
    };
  }
}

class LoginResult {
  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../core/navigation/main_navigator.dart';
import '../screens/auth/login_screen.dart';
import 'auth/auth_repository.dart';

/// Fills the token-expiry gap during the phases where [MainNavigatorState]
/// has NOT mounted yet (splash screen, onboarding, login).
///
/// When the main shell IS alive, `MainNavigatorState._handleTokenExpired`
/// already shows a "Sesi Berakhir" dialog and redirects — this manager must
/// NOT double-handle in that case. It only acts when the shell is absent.
class SessionManager {
  SessionManager._();

  static bool _initialized = false;

  /// True once a token-expiry forced logout has been signalled. The splash
  /// screen consumes this to route straight to [LoginScreen] instead of
  /// silently entering the guest shell.
  static bool forcedLogoutPending = false;

  static void resetForcedLogout() => forcedLogoutPending = false;

  /// Call once from main() before runApp.
  static void init() {
    if (_initialized) return;
    _initialized = true;

    AuthRepository.registerTokenExpiredCallback(_onTokenExpired);
    if (kDebugMode) {
      debugPrint('✅ SessionManager initialized - global token expiry listener');
    }
  }

  static void _onTokenExpired() {
    // Main shell is mounted -> it already handles the dialog + redirect.
    if (mainNavigatorKey.currentState?.mounted ?? false) {
      return;
    }

    forcedLogoutPending = true;
    if (kDebugMode) {
      debugPrint('🚨 Token expired before main shell - flagging forced re-login');
    }

    // If the root navigator is already attached, redirect now.
    final root = navigatorKey.currentState;
    if (root != null && root.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (root.mounted) {
          root.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      });
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

/// Helper to resolve image, document, and PDF URLs across the app,
/// and open external app links like Play Store review.
class UrlHelper {
  /// Base URL for legacy Web LSP assets repository
  static const String webLspBaseUrl = 'https://sertifikasi.lspdigital.id';

  /// Package ID for Play Store
  static const String appId = 'id.lspdigital.mobile';

  /// Play Store web URL
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$appId';

  /// Play Store market URI
  static const String marketUrl = 'market://details?id=$appId';

  /// Opens the Google Play Store (app if installed, or web browser)
  /// for users to rate and review the app.
  static Future<bool> openAppReview() async {
    final marketUri = Uri.parse(marketUrl);
    final webUri = Uri.parse(playStoreUrl);
    try {
      if (await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not launch market URI: $e');
      }
    }
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not launch web Play Store URL: $e');
      }
      return false;
    }
  }

  /// Resolves any raw URL/path into a fully-qualified URL string.
  ///
  /// Priority / Rules:
  /// 1. Already complete URL (starts with http:// or https://) -> return as-is
  /// 2. Web LSP repository path (starts with /repo/) -> prefix with [webLspBaseUrl]
  /// 3. Mobile backend upload path (starts with /upload/ or relative) -> prefix with [ApiService.baseUrl]
  static String resolveUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    if (path.startsWith('/repo/')) {
      return '$webLspBaseUrl$path';
    }
    final baseUrl = ApiService.baseUrl.replaceAll(RegExp(r'/+$'), '');
    return '$baseUrl$path';
  }
}

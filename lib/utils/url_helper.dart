import '../services/api_service.dart';

/// Helper to resolve image, document, and PDF URLs across the app.
class UrlHelper {
  /// Base URL for legacy Web LSP assets repository
  static const String webLspBaseUrl = 'https://sertifikasi.lspdigital.id';

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

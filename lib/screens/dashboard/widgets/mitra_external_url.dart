import 'package:url_launcher/url_launcher.dart';
import '../../../utils/url_helper.dart';

Future<void> openMitraExternalUrl(String rawUrl) async {
  final resolved = UrlHelper.resolveUrl(rawUrl);
  final uri = Uri.tryParse(resolved);
  if (uri != null) {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
  }
}

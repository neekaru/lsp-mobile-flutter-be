import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

/// Layanan in-app update Google Play (Android).
///
/// Sumber kebenaran versi = Play Store (versionCode), jadi tidak ada
/// hardcode versi di sini. Aman dipanggil di build sideloaded / emulator:
/// semua error dari Play Core ditelan sebagai "tidak ada update".
class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  final InAppUpdateFlutter _plugin = InAppUpdateFlutter();
  StreamSubscription<InstallStateAndroid>? _installSub;
  bool _downloadedDialogShown = false;

  /// Cek update & jalankan flow-nya.
  ///
  /// - [onProgress] dipanggil berulang saat download flexible berjalan.
  /// - [onDownloaded] dipanggil sekali saat update siap di-install.
  Future<void> checkForUpdate({
    ValueChanged<double>? onProgress,
    VoidCallback? onDownloaded,
  }) async {
    if (!Platform.isAndroid) return;

    AppUpdateInfoAndroid? info;
    try {
      info = await _plugin.checkUpdateAndroid();
    } catch (e) {
      // Bukan install dari Play Store (sideload/emulator) atau Play services
      // bermasalah -> anggap tidak ada update. Jangan crash aplikasi.
      debugPrint('AppUpdate: check skipped ($e)');
      return;
    }

    if (info.installStatus == InstallStatusAndroid.downloaded) {
      // Update sudah ter-download dari sesi sebelumnya -> langsung install.
      await _completeUpdate();
      return;
    }

    final availability = info.updateAvailability;
    if (availability == UpdateAvailabilityAndroid.developerTriggeredUpdateInProgress) {
      // Update sebelumnya masih setengah jalan; paksa lanjut.
      await _startImmediate();
      return;
    }
    if (availability != UpdateAvailabilityAndroid.updateAvailable) return;

    if (info.isImmediateUpdateAllowed) {
      await _startImmediate();
      return;
    }

    if (info.isFlexibleUpdateAllowed) {
      await _startFlexible(
        onProgress: onProgress,
        onDownloaded: onDownloaded,
      );
    }
  }

  Future<void> _startImmediate() async {
    try {
      await _plugin.startImmediateUpdateAndroid();
    } catch (e) {
      debugPrint('AppUpdate: immediate update failed ($e)');
    }
  }

  Future<void> _startFlexible({
    ValueChanged<double>? onProgress,
    VoidCallback? onDownloaded,
  }) async {
    _installSub?.cancel();
    _downloadedDialogShown = false;
    _installSub = _plugin.installStateStreamAndroid.listen((state) async {
      if (state.totalBytesToDownload > 0) {
        onProgress?.call(state.bytesDownloaded / state.totalBytesToDownload);
      }
      if (state.status == InstallStatusAndroid.downloaded && !_downloadedDialogShown) {
        _downloadedDialogShown = true;
        onDownloaded?.call();
        await _completeUpdate();
      }
    });

    await _plugin.startFlexibleUpdateAndroid();
  }

  /// Install update yang sudah ter-download lalu restart aplikasi.
  Future<void> _completeUpdate() async {
    try {
      await _plugin.completeUpdateAndroid();
    } catch (e) {
      debugPrint('AppUpdate: complete failed ($e)');
    }
  }

  void dispose() {
    _installSub?.cancel();
    _installSub = null;
  }
}

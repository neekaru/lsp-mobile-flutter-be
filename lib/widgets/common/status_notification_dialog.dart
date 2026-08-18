import 'package:material_ui/material_ui.dart';

class StatusNotificationDialog {
  /// Show Success Dialog (NO back arrow, NO X close button)
  static Future<void> showSuccess({
    required BuildContext context,
    String title = 'Perubahan Telah Tersimpan',
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SuccessDialogWidget(
        title: title,
        buttonText: buttonText,
        onOk: () {
          Navigator.of(dialogContext).pop();
          if (onOk != null) onOk();
        },
      ),
    );
  }

  /// Show Error/Warning Dialog (WITH back arrow and X close button)
  static Future<void> showError({
    required BuildContext context,
    String title = 'Cek Kembali Dokumen Permohonan',
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _ErrorDialogWidget(
        title: title,
        buttonText: buttonText,
        onOk: () {
          Navigator.of(dialogContext).pop();
          if (onOk != null) onOk();
        },
      ),
    );
  }
}

// ============================================================================
// 1. Success Dialog Widget (No Back Arrow, No X Close Button)
// ============================================================================
class _SuccessDialogWidget extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onOk;

  const _SuccessDialogWidget({
    required this.title,
    required this.buttonText,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spacer to keep vertical balance (NO back button, NO X button)
            const SizedBox(height: 8),

            // Animated / Particle Green Success Illustration
            SizedBox(
              width: 150,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Floating Green Particles
                  Positioned(top: 10, left: 35, child: _dot(8, const Color(0xFFBBF7D0))),
                  Positioned(top: 25, left: 20, child: _dot(6, const Color(0xFF86EFAC))),
                  Positioned(top: 12, right: 30, child: _dot(9, const Color(0xFFBBF7D0))),
                  Positioned(top: 40, right: 22, child: _dot(7, const Color(0xFF86EFAC))),
                  Positioned(bottom: 20, left: 25, child: _dot(8, const Color(0xFFBBF7D0))),
                  Positioned(bottom: 30, left: 40, child: _dot(5, const Color(0xFF86EFAC))),
                  Positioned(bottom: 15, right: 35, child: _dot(10, const Color(0xFFBBF7D0))),
                  Positioned(bottom: 40, right: 18, child: _dot(6, const Color(0xFF86EFAC))),

                  // Outer Soft Green Circle
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title Text
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),

            // Blue OK Button
            SizedBox(
              width: 160,
              height: 42,
              child: ElevatedButton(
                onPressed: onOk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ============================================================================
// 2. Error/Warning Dialog Widget (WITH Back Arrow and X Close Button)
// ============================================================================
class _ErrorDialogWidget extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onOk;

  const _ErrorDialogWidget({
    required this.title,
    required this.buttonText,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Back Arrow on Left & X Close Button on Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF334155),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF334155),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Animated / Particle Red Warning Illustration
            SizedBox(
              width: 150,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Floating Red/Pink Particles
                  Positioned(top: 10, left: 35, child: _dot(8, const Color(0xFFFECDD3))),
                  Positioned(top: 25, left: 20, child: _dot(6, const Color(0xFFFDA4AF))),
                  Positioned(top: 12, right: 30, child: _dot(9, const Color(0xFFFECDD3))),
                  Positioned(top: 40, right: 22, child: _dot(7, const Color(0xFFFDA4AF))),
                  Positioned(bottom: 20, left: 25, child: _dot(8, const Color(0xFFFECDD3))),
                  Positioned(bottom: 30, left: 40, child: _dot(5, const Color(0xFFFDA4AF))),
                  Positioned(bottom: 15, right: 35, child: _dot(10, const Color(0xFFFECDD3))),
                  Positioned(bottom: 40, right: 18, child: _dot(6, const Color(0xFFFDA4AF))),

                  // Soft Red Circle Container
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444),
                        size: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title Text
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),

            // Light Peach / Soft Orange OK Button
            SizedBox(
              width: 160,
              height: 42,
              child: ElevatedButton(
                onPressed: onOk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEDD5),
                  foregroundColor: const Color(0xFFEA580C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

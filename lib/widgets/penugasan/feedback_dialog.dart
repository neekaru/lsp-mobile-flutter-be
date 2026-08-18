import 'package:material_ui/material_ui.dart';

import '../pengajuan/animated_status_badges.dart';

/// Dialog feedback sukses/gagal dengan badge animasi dan dekorasi bubble.
Future<void> showFeedbackDialog(
  BuildContext context, {
  required bool isSuccess,
  required String message,
  VoidCallback? onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              isSuccess
                  ? const SizedBox(
                      height: 140,
                      width: 140,
                      child: AnimatedSuccessBadge(),
                    )
                  : SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._buildDecorCircles(isSuccess),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF0E6),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFF97316),
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'i',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF97316),
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onConfirm != null) {
                      onConfirm();
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
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
    },
  );
}

List<Widget> _buildDecorCircles(bool isSuccess) {
  final color = isSuccess ? const Color(0xFFE2FBE9) : const Color(0xFFFFF0E6);
  return [
    Positioned(top: 15, left: 20, child: _decorBubble(color, 8)),
    Positioned(top: 25, left: 35, child: _decorBubble(color, 6)),
    Positioned(top: 35, left: 15, child: _decorBubble(color, 10)),
    Positioned(bottom: 25, left: 20, child: _decorBubble(color, 8)),
    Positioned(bottom: 15, left: 30, child: _decorBubble(color, 6)),
    Positioned(top: 20, right: 20, child: _decorBubble(color, 10)),
    Positioned(top: 40, right: 10, child: _decorBubble(color, 6)),
    Positioned(bottom: 30, right: 25, child: _decorBubble(color, 8)),
    Positioned(bottom: 15, right: 15, child: _decorBubble(color, 12)),
  ];
}

Widget _decorBubble(Color color, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

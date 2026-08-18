import 'package:material_ui/material_ui.dart';

/// Badge animasi status sukses (hijau) — konfirmasi berhasil.
class AnimatedSuccessBadge extends StatefulWidget {
  const AnimatedSuccessBadge({super.key});

  @override
  State<AnimatedSuccessBadge> createState() => _AnimatedSuccessBadgeState();
}

class _AnimatedSuccessBadgeState extends State<AnimatedSuccessBadge>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _badgeController.forward().then((_) {
      _checkController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _badgeScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F4E9),
              shape: BoxShape.circle,
            ),
          ),
          // Inner circle
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
            child: ScaleTransition(
              scale: _checkScale,
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Decorative floating dots to match screenshot bubbles
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFC2EAD0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFC2EAD0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 5,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFC2EAD0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFC2EAD0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFC2EAD0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge animasi status peringatan (oranye).
class AnimatedWarningBadge extends StatefulWidget {
  const AnimatedWarningBadge({super.key});

  @override
  State<AnimatedWarningBadge> createState() => _AnimatedWarningBadgeState();
}

class _AnimatedWarningBadgeState extends State<AnimatedWarningBadge>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _iconScale = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );

    _badgeController.forward().then((_) {
      _iconController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _badgeScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3E2), // Light orange
              shape: BoxShape.circle,
            ),
          ),
          // Inner circle
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B), // Orange
              shape: BoxShape.circle,
            ),
            child: ScaleTransition(
              scale: _iconScale,
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Decorative floating dots
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE4C0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE4C0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 5,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE4C0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE4C0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE4C0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge animasi status error (merah).
class AnimatedErrorBadge extends StatefulWidget {
  const AnimatedErrorBadge({super.key});

  @override
  State<AnimatedErrorBadge> createState() => _AnimatedErrorBadgeState();
}

class _AnimatedErrorBadgeState extends State<AnimatedErrorBadge>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _iconScale = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );

    _badgeController.forward().then((_) {
      _iconController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _badgeScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2), // Light red
              shape: BoxShape.circle,
            ),
          ),
          // Inner circle
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F), // Red
              shape: BoxShape.circle,
            ),
            child: ScaleTransition(
              scale: _iconScale,
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Decorative floating dots
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFECDCD),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFFECDCD),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 5,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFECDCD),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFECDCD),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFECDCD),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

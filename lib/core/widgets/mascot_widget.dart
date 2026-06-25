import 'package:flutter/material.dart';
import 'package:nawasena/core/constants/app_constants.dart';

enum MascotPose {
  waving,       // Selamat Datang — di splash & welcome
  thinking,     // Ada Ide? — di loading / tip
  celebrating,  // Selesai! — setelah selesai lesson
  searching,    // Ditemukan! — empty state / search
  reading,      // Mari Membaca — di halaman lesson
  pointing,     // Ikuti Aku! — onboarding
}

extension MascotPoseExt on MascotPose {
  String get assetPath => switch (this) {
    MascotPose.waving       => AppConstants.mascotWaving,
    MascotPose.thinking     => AppConstants.mascotThinking,
    MascotPose.celebrating  => AppConstants.mascotCelebrating,
    MascotPose.searching    => AppConstants.mascotSearching,
    MascotPose.reading      => AppConstants.mascotReading,
    MascotPose.pointing     => AppConstants.mascotPointing,
  };
}

/// Widget maskot harimau Nawasena.
///
/// Mendukung optional speech bubble dengan teks kustom.
/// Asset PNG harus ditempatkan di folder assets/mascots/ sesuai path di AppConstants.
class MascotWidget extends StatelessWidget {
  final MascotPose pose;
  final double size;
  final String? speechText;
  final bool animate;

  const MascotWidget({
    super.key,
    required this.pose,
    this.size = 160,
    this.speechText,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final mascot = Image.asset(
      pose.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _FallbackMascot(size: size),
    );

    final body = animate
        ? _BouncingMascot(child: mascot)
        : mascot;

    if (speechText == null) return body;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpeechBubble(text: speechText!),
        const SizedBox(height: 4),
        body,
      ],
    );
  }
}

class _BouncingMascot extends StatefulWidget {
  final Widget child;
  const _BouncingMascot({required this.child});

  @override
  State<_BouncingMascot> createState() => _BouncingMascotState();
}

class _BouncingMascotState extends State<_BouncingMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, child) => Transform.translate(
      offset: Offset(0, _anim.value),
      child: child,
    ),
    child: widget.child,
  );
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft:     Radius.circular(18),
          topRight:    Radius.circular(18),
          bottomLeft:  Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Color(0xFF3C3C3C),
        ),
      ),
    );
  }
}

/// Fallback jika aset belum tersedia
class _FallbackMascot extends StatelessWidget {
  final double size;
  const _FallbackMascot({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFFF7F0E).withOpacity(0.1),
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text('🐯', style: TextStyle(fontSize: size * 0.45)),
  );
}

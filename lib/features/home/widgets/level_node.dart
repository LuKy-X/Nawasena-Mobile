import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/bouncy_tap.dart';
import 'package:nawasena/features/home/models/course_model.dart';

/// Node bulat 3D-style di Learning Path, terinspirasi Duolingo.
/// Tiga state: completed (hijau+bintang), active (putih+border oranye), locked (abu-abu).
class LevelNode extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback? onTap;
  final bool isCurrentActive; // Animasi pulse untuk node yang sedang aktif

  const LevelNode({
    super.key,
    required this.lesson,
    this.onTap,
    this.isCurrentActive = false,
  });

  static const double size = 88.0;

  @override
  Widget build(BuildContext context) {
    final status = lesson.status;

    final Color baseColor;
    final Color shadowColor;
    final Color iconColor;
    final bool  showLock;
    final bool  showStar;

    switch (status) {
      case LessonStatus.completed:
        baseColor   = AppColors.successGreen;
        shadowColor = AppColors.successDark;
        iconColor   = Colors.white;
        showLock    = false;
        showStar    = true;
      case LessonStatus.unlocked:
        baseColor   = Colors.white;
        shadowColor = AppColors.borderGrey;
        iconColor   = AppColors.primaryOrange;
        showLock    = false;
        showStar    = false;
      case LessonStatus.locked:
        baseColor   = const Color(0xFFE0E0E0);
        shadowColor = const Color(0xFFBBBBBB);
        iconColor   = const Color(0xFFB0B0B0);
        showLock    = true;
        showStar    = false;
    }

    Widget node = _NodeBody(
      size:        size,
      baseColor:   baseColor,
      shadowColor: shadowColor,
      iconColor:   iconColor,
      lesson:      lesson,
      showLock:    showLock,
      showStar:    showStar,
      status:      status,
    );

    // Pulse ring untuk active node
    if (isCurrentActive && status == LessonStatus.unlocked) {
      node = _PulsingRing(child: node);
    }

    if (status == LessonStatus.locked) return node;

    return BouncyTap(onTap: onTap, child: node);
  }
}

class _NodeBody extends StatelessWidget {
  final double size;
  final Color  baseColor;
  final Color  shadowColor;
  final Color  iconColor;
  final LessonModel lesson;
  final bool   showLock;
  final bool   showStar;
  final LessonStatus status;

  const _NodeBody({
    required this.size,
    required this.baseColor,
    required this.shadowColor,
    required this.iconColor,
    required this.lesson,
    required this.showLock,
    required this.showStar,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor,
              border: status == LessonStatus.unlocked
                  ? Border.all(color: AppColors.primaryOrange, width: 3)
                  : status == LessonStatus.locked
                      ? Border.all(color: const Color(0xFFCCCCCC), width: 2)
                      : null,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 0,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showLock)
                  Icon(Icons.lock_rounded, color: iconColor, size: 30)
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_lessonIcon(lesson.order), color: iconColor, size: 28),
                      const SizedBox(height: 2),
                      if (status == LessonStatus.completed && lesson.score != null)
                        Text(
                          '${lesson.score}%',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: iconColor,
                          ),
                        ),
                    ],
                  ),
                if (showStar)
                  Positioned(
                    top: 4, right: 4,
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status == LessonStatus.locked
                  ? AppColors.lockedGrey
                  : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  IconData _lessonIcon(int order) {
    const icons = [
      Icons.font_download_outlined,
      Icons.people_outline,
      Icons.account_balance_outlined,
      Icons.music_note_outlined,
      Icons.theater_comedy_outlined,
      Icons.library_music_outlined,
      Icons.favorite_border,
      Icons.palette_outlined,
      Icons.temple_buddhist_outlined,
      Icons.emoji_objects_outlined,
    ];
    return icons[(order - 1) % icons.length];
  }
}

class _PulsingRing extends StatefulWidget {
  final Widget child;
  const _PulsingRing({required this.child});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.85, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.scale(scale: _anim.value, child: child),
      child: widget.child,
    );
  }
}

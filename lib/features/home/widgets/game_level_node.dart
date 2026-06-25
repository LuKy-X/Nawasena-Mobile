// lib/features/home/widgets/game_level_node.dart
import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/home/models/course_model.dart';

/// Node bulat game-style ala Duolingo dark mode.
/// Tiga state: completed (hijau + bintang), active (hijau + ring pulse), locked (abu gelap)
class GameLevelNode extends StatelessWidget {
  final LessonModel  lesson;
  final bool         isCurrentActive;
  final VoidCallback? onTap;

  static const double nodeSize = 72.0;

  const GameLevelNode({
    super.key,
    required this.lesson,
    this.isCurrentActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (lesson.status) {
      LessonStatus.completed => _CompletedNode(lesson: lesson, onTap: onTap),
      LessonStatus.unlocked  => isCurrentActive
          ? _ActiveNode(lesson: lesson, onTap: onTap)
          : _UnlockedNode(lesson: lesson, onTap: onTap),
      LessonStatus.locked    => const _LockedNode(),
    };
  }
}

// ── Completed — hijau penuh, bintang putih ────────────────────────────────────
class _CompletedNode extends StatelessWidget {
  final LessonModel   lesson;
  final VoidCallback? onTap;
  const _CompletedNode({required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    const size = GameLevelNode.nodeSize;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size, height: size,
        child: Stack(alignment: Alignment.center, children: [
          // Bayangan hijau bawah (efek 3D)
          Positioned(
            bottom: 0,
            child: Container(
              width: size, height: size * 0.88,
              decoration: BoxDecoration(
                color: const Color(0xFF45A800),
                borderRadius: BorderRadius.circular(size / 2),
              ),
            ),
          ),
          // Lingkaran utama
          Container(
            width: size, height: size * 0.88,
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.successGreen.withOpacity(0.4),
                  blurRadius: 10, spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 38),
          ),
        ]),
      ),
    );
  }
}

// ── Active (current) — hijau + ring animasi pulse ─────────────────────────────
class _ActiveNode extends StatefulWidget {
  final LessonModel   lesson;
  final VoidCallback? onTap;
  const _ActiveNode({required this.lesson, this.onTap});
  @override
  State<_ActiveNode> createState() => _ActiveNodeState();
}

class _ActiveNodeState extends State<_ActiveNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const size = GameLevelNode.nodeSize;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
        child: SizedBox(
          width: size + 16, height: size + 16,
          child: Stack(alignment: Alignment.center, children: [
            // Ring luar berdenyut
            Container(
              width: size + 14, height: size + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.45), width: 4),
              ),
            ),
            // Bayangan
            Positioned(
              bottom: 2,
              child: Container(
                width: size, height: size * 0.88,
                decoration: BoxDecoration(
                  color: const Color(0xFF45A800),
                  borderRadius: BorderRadius.circular(size / 2),
                ),
              ),
            ),
            // Lingkaran utama
            Container(
              width: size, height: size * 0.88,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.circular(size / 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.successGreen.withOpacity(0.5),
                    blurRadius: 14, spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 38),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Unlocked (bisa diklik tapi bukan current) ─────────────────────────────────
class _UnlockedNode extends StatelessWidget {
  final LessonModel   lesson;
  final VoidCallback? onTap;
  const _UnlockedNode({required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    const size = GameLevelNode.nodeSize;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size, height: size,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(bottom: 0,
            child: Container(
              width: size, height: size * 0.88,
              decoration: BoxDecoration(
                color: const Color(0xFF45A800),
                borderRadius: BorderRadius.circular(size / 2),
              ),
            ),
          ),
          Container(
            width: size, height: size * 0.88,
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(size / 2),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.star_border_rounded, color: Colors.white, size: 38),
          ),
        ]),
      ),
    );
  }
}

// ── Locked — abu gelap, tidak bisa diklik ─────────────────────────────────────
class _LockedNode extends StatelessWidget {
  const _LockedNode();

  @override
  Widget build(BuildContext context) {
    const size = GameLevelNode.nodeSize;
    return SizedBox(
      width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        Positioned(bottom: 0,
          child: Container(
            width: size, height: size * 0.88,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 126, 126, 126),
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
        ),
        Container(
          width: size, height: size * 0.88,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 176, 176, 176),
            borderRadius: BorderRadius.circular(size / 2),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.star_rounded, color: Color(0xFF555555), size: 38),
        ),
      ]),
    );
  }
}

// ── Dekoratif: Peti Harta ─────────────────────────────────────────────────────
class GameChestNode extends StatelessWidget {
  final bool isLocked;
  const GameChestNode({super.key, this.isLocked = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68, height: 68,
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFF2A2A3A) : const Color(0xFF3A2A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? const Color(0xFF444466) : const Color(0xFFAA7700),
          width: 2,
        ),
        boxShadow: isLocked ? [] : [
          BoxShadow(color: Colors.amber.withOpacity(0.3),
              blurRadius: 12, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        isLocked ? '🔒' : '📦',
        style: TextStyle(
          fontSize: isLocked ? 28 : 32,
          color: isLocked ? const Color(0xFF555577) : Colors.white,
        ),
      ),
    );
  }
}

// ── Dekoratif: Karakter Musuh/Maskot ─────────────────────────────────────────
class GameCharacterNode extends StatelessWidget {
  final bool isLocked;
  const GameCharacterNode({super.key, this.isLocked = true});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.35 : 1.0,
      child: Container(
        width: 64, height: 72,
        alignment: Alignment.center,
        child: Text(
          '🐯',
          style: TextStyle(fontSize: isLocked ? 44 : 48),
        ),
      ),
    );
  }
}

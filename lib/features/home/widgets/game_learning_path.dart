// lib/features/home/widgets/game_learning_path.dart
import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/home/models/course_model.dart';
import 'package:nawasena/features/home/widgets/game_level_node.dart';

// Warna AKSEN per level (berulang jika lebih dari 6 level).
// Sekarang hanya dipakai sebagai aksen (ikon, teks, progress pill, garis),
// BUKAN lagi warna solid background banner — banner kini berwarna putih
// agar serasi dengan style kartu putih di halaman lain (Toko, Profil, dll).
const _kAccentColors = [
  Color(0xFF2A9D3E), // hijau
  Color(0xFF8E44AD), // ungu
  Color(0xFF1E88C7), // biru
  Color(0xFFD9822B), // oranye/coklat
  Color(0xFFD64550), // merah
  Color(0xFF169C9C), // teal
];

/// Peta belajar game-style ala Duolingo.
///
/// Setiap Level ditampilkan sebagai:
///   1. Banner PUTIH dengan aksen warna per level (judul level)
///   2. Zigzag nodes lesson
///   3. Elemen dekoratif (peti, karakter) di antara kelompok node
class GameLearningPath extends StatelessWidget {
  final List<CourseModel> courses;
  final void Function(LessonModel) onLessonTap;

  const GameLearningPath({
    super.key,
    required this.courses,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        for (int ci = 0; ci < courses.length; ci++)
          for (int li = 0; li < courses[ci].levels.length; li++)
            _LevelSection(
              level:       courses[ci].levels[li],
              colorIdx:    (ci * 3 + li) % _kAccentColors.length,
              onLessonTap: onLessonTap,
            ),
      ],
    );
  }
}

// ── Satu Level (banner + nodes) ───────────────────────────────────────────────
class _LevelSection extends StatelessWidget {
  final LevelModel level;
  final int        colorIdx;
  final void Function(LessonModel) onLessonTap;

  const _LevelSection({
    required this.level,
    required this.colorIdx,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Banner section (putih, dengan aksen warna) ─────────────────────
        _SectionBanner(level: level, accent: _kAccentColors[colorIdx]),

        // Jarak antara banner & path DIPERBESAR (8 → 56) agar bubble
        // "MULAI DI SINI!" yang melayang di atas node aktif punya ruang
        // sendiri dan TIDAK menutupi judul level di banner.
        const SizedBox(height: 56),

        // ── Nodes zigzag ────────────────────────────────────────────────────
        _ZigzagNodes(
          lessons:     level.lessons,
          accentColor: _kAccentColors[colorIdx],
          onLessonTap: onLessonTap,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Banner Section — PUTIH dengan aksen warna per level ───────────────────────
class _SectionBanner extends StatelessWidget {
  final LevelModel level;
  final Color      accent;
  const _SectionBanner({required this.level, required this.accent});

  @override
  Widget build(BuildContext context) {
    final completed = level.lessons.where((l) => l.status == LessonStatus.completed).length;
    final total     = level.lessons.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon dengan latar tint warna aksen
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.menu_book_rounded, color: accent, size: 24),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LEVEL ${level.order}',
                    style: TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                      fontSize: 10.5, color: accent,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  level.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                    fontSize: 16, color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Progress badge (tint aksen)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Text(
              '$completed/$total',
              style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                fontSize: 13, color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nodes Zigzag ──────────────────────────────────────────────────────────────
class _ZigzagNodes extends StatelessWidget {
  final List<LessonModel>         lessons;
  final Color                     accentColor;
  final void Function(LessonModel) onLessonTap;

  const _ZigzagNodes({
    required this.lessons,
    required this.accentColor,
    required this.onLessonTap,
  });

  // Posisi X zigzag (0.0 = kiri, 1.0 = kanan)
  static const _xPos = [0.45, 0.25, 0.65, 0.50, 0.30, 0.70, 0.45, 0.20, 0.60];

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) return const SizedBox.shrink();

    // Cari index lesson yang sedang aktif (pertama unlocked)
    final activeIdx = lessons.indexWhere((l) => l.status == LessonStatus.unlocked);

    const nodeSize   = GameLevelNode.nodeSize;
    const vSpacing   = 100.0;
    final count      = lessons.length;
    final totalH     = count * vSpacing + 40.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Hitung posisi center setiap node
        final centers = List.generate(count, (i) {
          final x = _xPos[i % _xPos.length] * w;
          final y = i * vSpacing + vSpacing / 2;
          return Offset(x, y);
        });

        return SizedBox(
          height: totalH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Garis penghubung ─────────────────────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _PathPainter(
                    centers:    centers,
                    statuses:   lessons.map((l) => l.status).toList(),
                    accentColor: accentColor,
                    nodeRadius:  nodeSize / 2,
                  ),
                ),
              ),

              // ── Nodes ────────────────────────────────────────────────────
              for (int i = 0; i < count; i++) ...[
                // Bubble "Mulai di sini!" untuk node aktif.
                // Posisi -46 (relatif terhadap node) kini AMAN dari banner
                // karena gap antara banner & Stack ini sudah diperbesar
                // menjadi 56px di _LevelSection — lihat komentar di atas.
                if (i == activeIdx)
                  Positioned(
                    left: centers[i].dx - 64,
                    top:  centers[i].dy - nodeSize / 2 - 46,
                    child: _JumpBubble(accentColor: accentColor),
                  ),

                // Node lesson
                Positioned(
                  left: centers[i].dx - nodeSize / 2,
                  top:  centers[i].dy - nodeSize / 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GameLevelNode(
                        lesson:          lessons[i],
                        isCurrentActive: i == activeIdx,
                        onTap: lessons[i].status != LessonStatus.locked
                            ? () => onLessonTap(lessons[i])
                            : null,
                      ),
                    ],
                  ),
                ),
              ],

              // ── Dekoratif: peti & karakter ───────────────────────────────
              // Muncul setelah setiap 3 lesson
              for (int i = 2; i < count; i += 3) ...[
                _decorativeElement(centers, i, count, w),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _decorativeElement(
      List<Offset> centers, int afterIdx, int count, double w) {
    if (afterIdx >= count) return const SizedBox.shrink();

    final c1 = centers[afterIdx];
    final c2 = afterIdx + 1 < count ? centers[afterIdx + 1] : null;
    if (c2 == null) return const SizedBox.shrink();

    final midX = (c1.dx + c2.dx) / 2;
    final midY = (c1.dy + c2.dy) / 2;

    final isChest = (afterIdx ~/ 3) % 2 == 0;
    final allCompleted = lessons.take(afterIdx + 1)
        .every((l) => l.status == LessonStatus.completed);

    return Positioned(
      left: midX < w / 2 ? midX + 40 : midX - 110,
      top:  midY - 34,
      child: isChest
          ? GameChestNode(isLocked: !allCompleted)
          : GameCharacterNode(isLocked: !allCompleted),
    );
  }
}

// ── Bubble "Mulai di sini!" ───────────────────────────────────────────────────
class _JumpBubble extends StatelessWidget {
  final Color accentColor;
  const _JumpBubble({required this.accentColor});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 215, 215, 222),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 8),
          ],
        ),
        child: Text(
          'MULAI DI SINI!',
          style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w900,
            fontSize: 12, color: accentColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Panah ke bawah
      CustomPaint(
        painter: _ArrowPainter(color: accentColor),
        size: const Size(14, 8),
      ),
    ],
  );
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  const _ArrowPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Path Painter (garis penghubung) ──────────────────────────────────────────
class _PathPainter extends CustomPainter {
  final List<Offset>       centers;
  final List<LessonStatus> statuses;
  final Color              accentColor;
  final double             nodeRadius;

  const _PathPainter({
    required this.centers,
    required this.statuses,
    required this.accentColor,
    required this.nodeRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < centers.length - 1; i++) {
      final completed = statuses[i] == LessonStatus.completed;

      final start = Offset(centers[i].dx, centers[i].dy + nodeRadius);
      final end   = Offset(centers[i + 1].dx, centers[i + 1].dy - nodeRadius);

      if (completed) {
        final p = Paint()
          ..color      = AppColors.successGreen
          ..strokeWidth = 4
          ..style      = PaintingStyle.stroke
          ..strokeCap  = StrokeCap.round;
        _drawCurve(canvas, start, end, p);
      } else {
        final p = Paint()
          ..color      = const Color.fromARGB(255, 186, 186, 191)
          ..strokeWidth = 4
          ..style      = PaintingStyle.stroke
          ..strokeCap  = StrokeCap.round;
        _drawDashedCurve(canvas, start, end, p);
      }
    }
  }

  void _drawCurve(Canvas canvas, Offset s, Offset e, Paint p) {
    final mid  = Offset((s.dx + e.dx) / 2, (s.dy + e.dy) / 2);
    final path = Path()
      ..moveTo(s.dx, s.dy)
      ..quadraticBezierTo(mid.dx, s.dy, mid.dx, mid.dy)
      ..quadraticBezierTo(mid.dx, e.dy, e.dx, e.dy);
    canvas.drawPath(path, p);
  }

  void _drawDashedCurve(Canvas canvas, Offset s, Offset e, Paint p) {
    final mid  = Offset((s.dx + e.dx) / 2, (s.dy + e.dy) / 2);
    final path = Path()
      ..moveTo(s.dx, s.dy)
      ..quadraticBezierTo(mid.dx, s.dy, mid.dx, mid.dy)
      ..quadraticBezierTo(mid.dx, e.dy, e.dx, e.dy);

    double dist = 0;
    bool   draw = true;
    for (final metric in path.computeMetrics()) {
      while (dist < metric.length) {
        final len = draw ? 6.0 : 5.0;
        if (draw) {
          canvas.drawPath(metric.extractPath(dist, dist + len), p);
        }
        dist += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.statuses != statuses;
}

import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/home/models/course_model.dart';
import 'package:nawasena/features/home/widgets/level_node.dart';

/// Menampilkan daftar lesson dalam zigzag path ala Duolingo.
/// Garis penghubung berwarna hijau jika lesson sebelumnya completed.
class LearningPath extends StatelessWidget {
  final CourseModel course;
  final void Function(LessonModel lesson)? onLessonTap;

  const LearningPath({
    super.key,
    required this.course,
    this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    // Flatten semua lesson dari semua level ke satu list
    final lessons = course.levels
        .expand((level) => level.lessons)
        .toList();

    if (lessons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: course.levels.map((level) => _LevelSection(
        level:        level,
        onLessonTap:  onLessonTap,
        isFirst:      level == course.levels.first,
      )).toList(),
    );
  }
}

class _LevelSection extends StatelessWidget {
  final LevelModel level;
  final void Function(LessonModel)? onLessonTap;
  final bool isFirst;

  const _LevelSection({
    required this.level,
    this.onLessonTap,
    this.isFirst = false,
  });

  // Posisi X zigzag (0.0 – 1.0, relatif terhadap lebar canvas)
  static const _xPositions = [0.20, 0.58, 0.80, 0.58, 0.20, 0.38, 0.70, 0.40];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width   = constraints.maxWidth;
        const nodeSize = LevelNode.size + 12; // node + label bawah
        const nodeRadius = LevelNode.size / 2;
        const vSpacing = 110.0;

        final lessons = level.lessons;
        final count   = lessons.length;
        final totalH  = count * vSpacing + 40.0;

        // Hitung centers
        final centers = <Offset>[];
        for (int i = 0; i < count; i++) {
          final x = _xPositions[i % _xPositions.length] * width;
          final y = i * vSpacing + vSpacing / 2;
          centers.add(Offset(x, y));
        }

        // Cari index lesson yang sedang active (untuk pulse)
        final activeIdx = lessons.indexWhere(
          (l) => l.status == LessonStatus.unlocked,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header per level ─────────────────────────────────
            _LevelHeader(level: level),

            // ── Canvas path + nodes ──────────────────────────────────────
            SizedBox(
              height: totalH,
              child: Stack(
                children: [
                  // Garis penghubung
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PathPainter(
                        centers:  centers,
                        statuses: lessons.map((l) => l.status).toList(),
                      ),
                    ),
                  ),
                  // Node-node
                  for (int i = 0; i < count; i++)
                    Positioned(
                      left: centers[i].dx - nodeSize / 2,
                      top:  centers[i].dy - (LevelNode.size / 2 + 10),
                      child: LevelNode(
                        lesson:          lessons[i],
                        isCurrentActive: i == activeIdx,
                        onTap: lessons[i].status != LessonStatus.locked
                            ? () => onLessonTap?.call(lessons[i])
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final LevelModel level;
  const _LevelHeader({required this.level});

  @override
  Widget build(BuildContext context) {
    final completed = level.lessons
        .where((l) => l.status == LessonStatus.completed)
        .length;
    final total = level.lessons.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${level.order}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.6),
                    valueColor: const AlwaysStoppedAnimation(AppColors.successGreen),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$completed/$total',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.primaryBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final List<Offset>       centers;
  final List<LessonStatus> statuses;

  const _PathPainter({required this.centers, required this.statuses});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < centers.length - 1; i++) {
      final isCompleted = statuses[i] == LessonStatus.completed;
      final paint = Paint()
        ..color = isCompleted
            ? AppColors.successGreen
            : const Color(0xFFDDDDDD)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final start = Offset(centers[i].dx,     centers[i].dy     + LevelNode.size / 2);
      final end   = Offset(centers[i + 1].dx, centers[i + 1].dy - LevelNode.size / 2);
      final mid   = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(mid.dx, start.dy, mid.dx, mid.dy)
        ..quadraticBezierTo(mid.dx, end.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);

      // Dash overlay jika belum completed
      if (!isCompleted) {
        final dashPaint = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        _drawDashedPath(canvas, path, dashPaint, 6, 6);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      double dashLength, double gapLength) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, distance + len),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.statuses != statuses || old.centers != centers;
}

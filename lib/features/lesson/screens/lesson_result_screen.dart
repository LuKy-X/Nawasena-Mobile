import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/core/widgets/nawasena_button.dart';
import 'package:nawasena/features/home/models/course_model.dart';
import 'package:nawasena/features/home/providers/home_provider.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';
import 'package:nawasena/core/widgets/heart_stamina_bar.dart';

/// Screen hasil sesi lesson.
/// - Skor naik dari 0 dengan animasi counting
/// - XP banner dengan spring effect
/// - Refresh peta belajar di background (agar status node terupdate)
class LessonResultScreen extends StatefulWidget {
  final LessonModel        lesson;
  final LessonSubmitResult result;

  const LessonResultScreen({
    super.key,
    required this.lesson,
    required this.result,
  });

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();

    // Refresh peta belajar di background agar node lesson berubah ke completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeProvider>().loadCourses(forceRefresh: true);
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ── Helpers ────────────────────────────────────────────────────────────────
  bool   get _isPerfect => widget.result.score == 100;
  bool   get _isPassing => widget.result.score >= 60;

  Color  get _scoreColor => _isPerfect
      ? AppColors.warningYellow
      : _isPassing
          ? AppColors.successGreen
          : AppColors.primaryRed;

  String get _scoreLabel => switch (widget.result.score) {
    100   => '🏆 Sempurna!',
    >= 80 => '🎉 Luar Biasa!',
    >= 60 => '👍 Bagus!',
    _     => '💪 Perlu Latihan Lagi',
  };

  String get _speechText => _isPerfect
      ? 'Sempurna! Kamu luar biasa! 🌟'
      : _isPassing
          ? 'Bagus sekali! Terus semangat!'
          : 'Hampir berhasil! Coba lagi ya!';

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const SizedBox(height: 28),

              // ── Maskot merayakan ───────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: MascotWidget(
                  pose: _isPassing
                      ? MascotPose.celebrating
                      : MascotPose.thinking,
                  size: 160,
                  animate: true,
                  speechText: _speechText,
                ),
              ),
              const SizedBox(height: 28),

              // ── Lingkaran skor animasi ─────────────────────────────
              _AnimatedScoreCircle(
                score: widget.result.score,
                color: _scoreColor,
              ),
              const SizedBox(height: 12),
              Text(_scoreLabel, style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                fontSize: 22, color: _scoreColor,
              )),
              const SizedBox(height: 4),
              Text(widget.lesson.title, style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                fontSize: 14, color: AppColors.mediumText,
              )),
              const SizedBox(height: 28),

              // ── Statistik ──────────────────────────────────────────
              _StatsRow(result: widget.result),
              const SizedBox(height: 20),

              // ── XP banner ─────────────────────────────────────────
              if (widget.result.xpEarned > 0) ...[
                _XpBanner(xp: widget.result.xpEarned),
                const SizedBox(height: 12),
              ],

              // ── Bonus Combo Stamina (jika ada) ─────────────────────
              if (widget.result.staminaBonusEvents > 0) ...[
                _ComboBonusBanner(events: widget.result.staminaBonusEvents),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 4),

              // ── Tombol aksi ────────────────────────────────────────
              if (_isPassing) ...[
                NawasenaButton(
                  label: 'Lanjut Belajar! 🚀',
                  color: AppColors.successGreen,
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
                const SizedBox(height: 12),
                NawasenaButton.outlined(
                  label: 'Kerjakan Ulang',
                  onPressed: () {
                    Navigator.of(context).pop(); // pop result
                    Navigator.of(context).pop(); // pop session → detail
                  },
                ),
              ] else ...[
                NawasenaButton(
                  label: 'Coba Lagi! 💪',
                  color: AppColors.primaryOrange,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),
                NawasenaButton.outlined(
                  label: 'Kembali ke Beranda',
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ],
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Score Circle
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedScoreCircle extends StatefulWidget {
  final int   score;
  final Color color;
  const _AnimatedScoreCircle({required this.score, required this.color});

  @override
  State<_AnimatedScoreCircle> createState() => _AnimatedScoreCircleState();
}

class _AnimatedScoreCircleState extends State<_AnimatedScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int>    _count;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _count = IntTween(begin: 0, end: widget.score)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _progress = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => SizedBox(
      width: 150, height: 150,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 150, height: 150,
          child: CircularProgressIndicator(
            value: _progress.value,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation(widget.color),
            strokeWidth: 12,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${_count.value}', style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w900,
            fontSize: 46, color: widget.color,
          )),
          Text('SKOR', style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w800,
            fontSize: 11, color: widget.color.withOpacity(0.65),
            letterSpacing: 1.5,
          )),
        ]),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final LessonSubmitResult result;
  const _StatsRow({required this.result});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: AppTheme.cardShadow,
    ),
    child: Column(children: [
      Row(children: [
        _StatItem(
          emoji: '✅',
          value: '${result.correctAnswers}/${result.totalQuestions}',
          label: 'Benar',
          color: AppColors.successGreen,
        ),
        _VerticalDivider(),
        _StatItem(
          emoji: '📝',
          value: '${result.totalQuestions}',
          label: 'Soal',
          color: AppColors.xpBlue,
        ),
        _VerticalDivider(),
        Expanded(
          child: Column(children: [
            const Text('❤️', style: TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            HeartStaminaBar(
              heartPoints: result.heartPointsRemaining,
              hasInfiniteHearts: result.hasInfiniteHearts,
              compact: true,
            ),
            const SizedBox(height: 4),
            Text(
              result.hasInfiniteHearts ? '∞' : '${result.heartPointsRemaining}/100',
              style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                fontSize: 11, color: AppColors.mediumText,
              ),
            ),
          ]),
        ),
      ]),
    ]),
  );
}

class _StatItem extends StatelessWidget {
  final String emoji, value, label;
  final Color  color;
  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 26)),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w900,
        fontSize: 18, color: color,
      )),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w600,
        fontSize: 11, color: AppColors.mediumText,
      )),
    ]),
  );
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 56,
    color: AppColors.borderGrey,
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// XP Banner dengan spring animation
// ─────────────────────────────────────────────────────────────────────────────

class _XpBanner extends StatefulWidget {
  final int xp;
  const _XpBanner({required this.xp});

  @override
  State<_XpBanner> createState() => _XpBannerState();
}

class _XpBannerState extends State<_XpBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    // Delay agar muncul setelah animasi skor selesai
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF176), Color(0xFFFFD600)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.warningYellow.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('⚡', style: TextStyle(fontSize: 30)),
        const SizedBox(width: 10),
        Text(
          '+${widget.xp} XP',
          style: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w900,
            fontSize: 28, color: Color(0xFF7B5800),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'didapat!',
          style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w700,
            fontSize: 17, color: Color(0xFF7B5800),
          ),
        ),
      ]),
    ),
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// Combo Bonus Banner — muncul jika ada bonus stamina dari combo jawaban benar
// ─────────────────────────────────────────────────────────────────────────────

class _ComboBonusBanner extends StatefulWidget {
  final int events;
  const _ComboBonusBanner({required this.events});

  @override
  State<_ComboBonusBanner> createState() => _ComboBonusBannerState();
}

class _ComboBonusBannerState extends State<_ComboBonusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A8A), Color(0xFFFF4B6E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔥', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Text(
          widget.events > 1
              ? 'Bonus Combo Stamina x${widget.events}!'
              : 'Bonus Combo Stamina!',
          style: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w800,
            fontSize: 14, color: Colors.white,
          ),
        ),
      ]),
    ),
  );
}

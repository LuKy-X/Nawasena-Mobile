import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/home/models/course_model.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';
import 'package:nawasena/features/lesson/providers/lesson_session_provider.dart';
import 'package:nawasena/features/lesson/screens/lesson_result_screen.dart';
import 'package:nawasena/features/lesson/widgets/feedback_panel.dart';
import 'package:nawasena/features/lesson/widgets/question_widget_router.dart';
import 'package:nawasena/core/widgets/heart_stamina_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────────────────────────────────────

/// Screen utama sesi pengerjaan lesson.
/// Menggunakan ChangeNotifierProvider LOKAL agar provider langsung
/// di-dispose saat user keluar (tidak mencemari widget tree global).
class LessonSessionScreen extends StatelessWidget {
  final LessonModel lesson;
  final int         initialHeartPoints;
  final bool        hasInfiniteHearts;

  const LessonSessionScreen({
    super.key,
    required this.lesson,
    required this.initialHeartPoints,
    this.hasInfiniteHearts = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LessonSessionProvider(
        lessonId:           lesson.id,
        initialHeartPoints: initialHeartPoints,
        hasInfiniteHearts:  hasInfiniteHearts,
      )..loadQuestions(),
      child: _SessionBody(lesson: lesson),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _SessionBody extends StatelessWidget {
  final LessonModel lesson;
  const _SessionBody({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonSessionProvider>(
      builder: (context, sp, _) {

        // ── 1. Loading ─────────────────────────────────────────────────
        if (sp.phase == SessionPhase.loading) {
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                MascotWidget(pose: MascotPose.reading, size: 130, animate: true),
                SizedBox(height: 20),
                Text(
                  'Menyiapkan soal...',
                  style: TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                    fontSize: 16, color: AppColors.mediumText,
                  ),
                ),
              ]),
            ),
          );
        }

        // ── 2. Error ───────────────────────────────────────────────────
        if (sp.phase == SessionPhase.error) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const MascotWidget(pose: MascotPose.thinking, size: 120),
                    const SizedBox(height: 20),
                    Text(
                      sp.error ?? 'Terjadi kesalahan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                        fontSize: 15, color: AppColors.mediumText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: sp.loadQuestions,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                          color: AppColors.mediumText,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          );
        }

        // ── 3. Completed → navigasi ke Result Screen ──────────────────
        if (sp.phase == SessionPhase.completed && sp.result != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Sync hearts ke AuthProvider agar UI beranda ikut terupdate
            final auth = context.read<AuthProvider>();
            if (auth.user != null) {
              auth.updateUser(
                auth.user!.copyWith(heartPoints: sp.result!.heartPointsRemaining),
              );
            }
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => LessonResultScreen(
                  lesson: lesson,
                  result: sp.result!,
                ),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                  child: child,
                ),
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          });
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primaryOrange),
              ),
            ),
          );
        }

        // ── 4. Sesi aktif ──────────────────────────────────────────────
        final q = sp.currentQuestion;
        if (q == null) return const SizedBox.shrink();

        final showFeedback = sp.phase == SessionPhase.correct ||
                             sp.phase == SessionPhase.wrong;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) _showExitDialog(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: SafeArea(
              child: Column(
                children: [
                  // ── Header progress + hearts ───────────────────────
                  _ProgressHeader(sp: sp),

                  // ── Konten soal scrollable ─────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _QuestionContent(
                          key: ValueKey('q_${q.id}'),
                          question: q,
                          sp: sp,
                        ),
                      ),
                    ),
                  ),

                  // ── Tombol Periksa / FeedbackPanel ─────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: showFeedback
                        ? FeedbackPanel(
                            key: ValueKey('fb_${sp.currentIdx}'),
                            type: sp.phase == SessionPhase.correct
                                ? FeedbackType.correct
                                : FeedbackType.wrong,
                            explanation: sp.lastExplanation,
                            onContinue:  sp.nextQuestion,
                          )
                        : _CheckButton(
                            key: const ValueKey('check'),
                            sp: sp,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final exit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari Lesson?',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Progres lesson ini belum tersimpan.\nYakin ingin keluar?',
          style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Lanjutkan Belajar',
                style: TextStyle(
                  fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                  color: AppColors.mediumText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if ((exit ?? false) && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Header
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final LessonSessionProvider sp;
  const _ProgressHeader({required this.sp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol keluar — trigger dialog konfirmasi
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.mediumText,
              size: 22,
            ),
            onPressed: () => showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Keluar?',
                    style: TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w900)),
                content: const Text('Progres belum tersimpan.',
                    style: TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Lanjutkan',
                        style: TextStyle(
                            fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                            color: AppColors.primaryOrange)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Keluar',
                        style: TextStyle(
                            fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed)),
                  ),
                ],
              ),
            ),
          ),

          // Progress bar + label soal ke-N dari total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: sp.progressValue),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 12,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Soal ${sp.currentIdx + 1} dari ${sp.totalQuestions}',
                  style: const TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                    fontSize: 11, color: AppColors.mediumText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Heart Stamina bar (compact) — 5 hati dengan isi proporsional
          HeartStaminaBar(
            heartPoints: sp.heartPoints,
            hasInfiniteHearts: sp.hasInfiniteHearts,
            compact: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question Content (soal + badge + instruksi + widget + hint)
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionContent extends StatelessWidget {
  final QuestionModel        question;
  final LessonSessionProvider sp;

  const _QuestionContent({
    super.key,
    required this.question,
    required this.sp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Badge template ─────────────────────────────────────────────
        _TemplateBadge(slug: question.templateSlug),
        const SizedBox(height: 14),

        // ── Instruksi ──────────────────────────────────────────────────
        if (question.template.instructionId.isNotEmpty) ...[
          _InstructionBar(text: question.template.instructionId),
          const SizedBox(height: 14),
        ],

        // ── Teks soal ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Text(
            question.promptText,
            style: const TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w800,
              fontSize: 17, color: AppColors.darkText, height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 22),

        // ── Widget soal sesuai template ────────────────────────────────
        QuestionWidgetRouter(
          question:        question,
          onAnswerChanged: sp.setAnswer,
        ),

        // ── Hint ───────────────────────────────────────────────────────
        if (question.hint != null) ...[
          const SizedBox(height: 20),
          _HintSection(
            hint:    question.hint!,
            visible: sp.hintVisible,
            onShow:  sp.showHint,
          ),
        ],

        // Ruang kosong di bawah agar konten tidak tertutup tombol
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TemplateBadge extends StatelessWidget {
  final String slug;
  const _TemplateBadge({required this.slug});

  static const _meta = {
    'multiple_choice':             ('🎯', 'Pilihan Ganda',      Color(0xFF1CB0F6)),
    'scrambled_blocks':            ('🔤', 'Susun Kalimat',      Color(0xFF9B59B6)),
    'pair_matching':               ('🔗', 'Pasang-Pasangkan',   Color(0xFF27AE60)),
    'aksara_tracing':              ('✍️', 'Tulis Aksara',       Color(0xFFE67E22)),
    'dialog_simulation':           ('💬', 'Simulasi Dialog',    Color(0xFF2980B9)),
    'visual_audio_identification': ('👁️', 'Identifikasi',       Color(0xFFE91E63)),
  };

  @override
  Widget build(BuildContext context) {
    final info  = _meta[slug];
    final emoji = info?.$1 ?? '❓';
    final label = info?.$2 ?? slug;
    final color = info?.$3 ?? AppColors.primaryOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(
          fontFamily: 'Nunito', fontWeight: FontWeight.w800,
          fontSize: 13, color: color,
        )),
      ]),
    );
  }
}

class _InstructionBar extends StatelessWidget {
  final String text;
  const _InstructionBar({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.primaryBrown.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primaryBrown.withOpacity(0.15)),
    ),
    child: Row(children: [
      const Text('📜', style: TextStyle(fontSize: 15)),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w600,
        fontSize: 13, color: AppColors.primaryBrown,
      ))),
    ]),
  );
}

class _HintSection extends StatelessWidget {
  final String       hint;
  final bool         visible;
  final VoidCallback onShow;

  const _HintSection({
    required this.hint,
    required this.visible,
    required this.onShow,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onShow,
          icon: const Icon(
            Icons.lightbulb_outline_rounded,
            size: 18, color: AppColors.warningYellow,
          ),
          label: const Text(
            'Tampilkan Petunjuk',
            style: TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w700,
              fontSize: 14, color: AppColors.warningYellow,
            ),
          ),
        ),
      );
    }
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningYellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warningYellow.withOpacity(0.4)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(hint, style: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w600,
            fontSize: 13, color: AppColors.darkText, height: 1.5,
          ))),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Check Button (Tombol "Periksa Jawaban" / "Kumpulkan Jawaban")
// ─────────────────────────────────────────────────────────────────────────────

class _CheckButton extends StatelessWidget {
  final LessonSessionProvider sp;
  const _CheckButton({super.key, required this.sp});

  @override
  Widget build(BuildContext context) {
    final canCheck  = sp.canCheck;
    final isLoading = sp.phase == SessionPhase.checking;
    final isLast    = sp.isLastQuestion;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: (canCheck && !isLoading) ? sp.checkAnswer : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 56,
            decoration: BoxDecoration(
              color: canCheck ? AppColors.primaryOrange : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(18),
              boxShadow: canCheck
                  ? const [BoxShadow(
                      color: Color(0xFFC45E00),
                      blurRadius: 0,
                      offset: Offset(0, 5),
                    )]
                  : [],
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    isLast ? 'Kumpulkan Jawaban 🚀' : 'Lanjutkan',
                    style: TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: canCheck ? Colors.white : AppColors.lockedGrey,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

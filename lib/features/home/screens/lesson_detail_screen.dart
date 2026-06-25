import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/extensions/context_ext.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/core/widgets/nawasena_button.dart';
import 'package:nawasena/core/widgets/heart_stamina_bar.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/home/models/course_model.dart';
import 'package:nawasena/features/lesson/screens/lesson_session_screen.dart';

/// Screen pratinjau lesson sebelum mulai.
/// Menampilkan judul, XP reward, status (sudah selesai / belum), lalu CTA masuk sesi.
class LessonDetailScreen extends StatelessWidget {
  final LessonModel lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.status == LessonStatus.completed;
    final user        = context.read<AuthProvider>().user;

    // ── Heart Stamina System ──────────────────────────────────────────────
    final heartPoints       = user?.heartPoints ?? 100;
    final hasInfiniteHearts = user?.hasInfiniteHearts ?? false;
    final noStamina         = !hasInfiniteHearts && heartPoints <= 0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow,
            ),
            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.darkText),
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w800,
            fontSize: 17, color: AppColors.darkText,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // ── Maskot ─────────────────────────────────────────────────
              MascotWidget(
                pose: isCompleted ? MascotPose.celebrating : MascotPose.reading,
                size: 160,
                animate: true,
                speechText: isCompleted
                    ? 'Sudah kamu selesaikan! Mau latihan lagi?'
                    : noStamina
                        ? 'Staminamu habis... Tunggu atau isi ulang!'
                        : 'Siap mulai belajar? Ayo!',
              ),
              const SizedBox(height: 32),

              // ── Info card ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      lesson.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                        fontSize: 22, color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stat chips (XP + status skor)
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _InfoChip(emoji: '⚡', label: '${lesson.xpReward} XP',
                            color: AppColors.warningYellow),
                        _InfoChip(
                          emoji: isCompleted ? '🏆' : '📝',
                          label: isCompleted
                              ? 'Skor: ${lesson.score ?? "-"}%'
                              : 'Belum dikerjakan',
                          color: isCompleted ? AppColors.successGreen : AppColors.mediumText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── Heart Stamina Bar ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryRed.withOpacity(0.18)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            hasInfiniteHearts ? 'Stamina Hati' : 'Stamina Hati',
                            style: const TextStyle(
                              fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                              fontSize: 12, color: AppColors.mediumText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          HeartStaminaBar(
                            heartPoints: heartPoints,
                            hasInfiniteHearts: hasInfiniteHearts,
                            showLabel: !hasInfiniteHearts,
                          ),
                        ],
                      ),
                    ),

                    // Warning stamina habis
                    if (noStamina) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryRed.withOpacity(0.25)),
                        ),
                        child: const Row(
                          children: [
                            Text('💔', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Staminamu habis! Tunggu beberapa jam agar pulih, '
                                'atau beli Heart Refill di Toko.',
                                style: TextStyle(
                                  fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                                  fontSize: 13, color: AppColors.primaryRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // ── Tombol CTA ─────────────────────────────────────────────
              if (!noStamina) ...[
                NawasenaButton(
                  label: isCompleted ? 'Kerjakan Lagi 🔄' : 'Mulai Belajar! 🚀',
                  color: isCompleted ? AppColors.primaryBrown : AppColors.successGreen,
                  onPressed: () => _startSession(context, heartPoints, hasInfiniteHearts),
                ),
                const SizedBox(height: 12),
              ],
              NawasenaButton.outlined(
                label: 'Kembali',
                onPressed: context.pop,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _startSession(BuildContext context, int heartPoints, bool hasInfiniteHearts) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LessonSessionScreen(
          lesson: lesson,
          initialHeartPoints: heartPoints,
          hasInfiniteHearts: hasInfiniteHearts,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String emoji; final String label; final Color color;
  const _InfoChip({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w800,
        fontSize: 13, color: color,
      )),
    ]),
  );
}

import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';
import 'package:nawasena/features/lesson/widgets/question_templates/multiple_choice_widget.dart';

/// Identifikasi Visual/Audio — tampilkan gambar/konteks lalu pilih jawaban.
/// Untuk sekarang (gambar belum ada) menampilkan konteks teks dengan
/// style card khusus, lalu pilihan di bawahnya menggunakan MultipleChoiceWidget.
class VisualAudioWidget extends StatelessWidget {
  final QuestionModel question;
  final void Function(AnswerPayload) onAnswerChanged;

  const VisualAudioWidget({
    super.key, required this.question, required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Visual / Konteks Situasi ──────────────────────────────────
        if (question.mediaUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              question.mediaUrl!,
              height: 180, width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ContextCard(question: question),
            ),
          ),
        ] else
          _ContextCard(question: question),

        const SizedBox(height: 20),

        // ── Pilihan Jawaban (reuse MultipleChoice) ────────────────────
        MultipleChoiceWidget(
          question: question,
          onAnswerChanged: onAnswerChanged,
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  final QuestionModel question;
  const _ContextCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withOpacity(0.08),
            AppColors.primaryBrown.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('🎭', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Perhatikan situasi berikut:',
              style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                fontSize: 14, color: AppColors.primaryBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

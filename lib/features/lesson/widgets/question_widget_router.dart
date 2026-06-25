import 'package:flutter/material.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';
import 'package:nawasena/features/lesson/widgets/question_templates/aksara_tracing_widget.dart';
import 'package:nawasena/features/lesson/widgets/question_templates/dialog_simulation_widget.dart';
import 'package:nawasena/features/lesson/widgets/question_templates/multiple_choice_widget.dart';
import 'package:nawasena/features/lesson/widgets/question_templates/pair_matching_widget.dart';
import 'package:nawasena/features/lesson/widgets/question_templates/scrambled_blocks_widget.dart';
import 'package:nawasena/features/lesson/widgets/question_templates/visual_audio_widget.dart';

/// Router yang memilih widget template yang tepat berdasarkan slug.
/// Tambahkan case baru di sini jika ada template soal baru di masa depan.
class QuestionWidgetRouter extends StatelessWidget {
  final QuestionModel question;
  final void Function(AnswerPayload) onAnswerChanged;

  const QuestionWidgetRouter({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return switch (question.templateSlug) {
      'multiple_choice'            => MultipleChoiceWidget(
          question: question, onAnswerChanged: onAnswerChanged),
      'scrambled_blocks'           => ScrambledBlocksWidget(
          question: question, onAnswerChanged: onAnswerChanged),
      'pair_matching'              => PairMatchingWidget(
          question: question, onAnswerChanged: onAnswerChanged),
      'aksara_tracing'             => AksaraTracingWidget(
          question: question, onAnswerChanged: onAnswerChanged),
      'dialog_simulation'          => DialogSimulationWidget(
          question: question, onAnswerChanged: onAnswerChanged),
      'visual_audio_identification' => VisualAudioWidget(
          question: question, onAnswerChanged: onAnswerChanged),
      _ => _UnknownTemplateWidget(slug: question.templateSlug),
    };
  }
}

class _UnknownTemplateWidget extends StatelessWidget {
  final String slug;
  const _UnknownTemplateWidget({required this.slug});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3CD),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      '⚠️ Template "$slug" belum didukung di versi ini.',
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
    ),
  );
}

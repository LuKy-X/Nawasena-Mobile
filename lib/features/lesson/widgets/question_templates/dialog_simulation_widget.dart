import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';

/// Simulasi Dialog — percakapan ditampilkan sebagai gelembung chat,
/// user memilih respons yang paling tepat.
class DialogSimulationWidget extends StatefulWidget {
  final QuestionModel question;
  final void Function(AnswerPayload) onAnswerChanged;

  const DialogSimulationWidget({
    super.key, required this.question, required this.onAnswerChanged,
  });

  @override
  State<DialogSimulationWidget> createState() => _DialogSimulationWidgetState();
}

class _DialogSimulationWidgetState extends State<DialogSimulationWidget> {
  int? _selectedId;
  late final List<OptionModel> _shuffled;

  @override
  void initState() {
    super.initState();
    _shuffled = List<OptionModel>.from(widget.question.options)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    // Pisahkan prompt menjadi "dialog orang lain" (teks sebelum baris terakhir)
    // dan pertanyaan pilihan
    final lines = widget.question.promptText.split('\n\n');
    final dialogLines = lines.where((l) => l.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Bubble dialog ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dialogLines.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar orang yang berbicara
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.brownGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('👤', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Text(
                        line.trim(),
                        style: const TextStyle(
                          fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                          fontSize: 14, color: AppColors.darkText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // ── Label "Kamu menjawab:" ─────────────────────────────────────
        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('😊', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pilih respons yang tepat:',
              style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                fontSize: 14, color: AppColors.mediumText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Pilihan Respons ───────────────────────────────────────────
        ..._shuffled.map((opt) {
          final sel = _selectedId == opt.id;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedId = opt.id);
              widget.onAnswerChanged(AnswerPayload(
                questionId: widget.question.id,
                selectedOptionId: opt.id,
              ));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: sel ? AppColors.primaryOrange.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel ? AppColors.primaryOrange : AppColors.borderGrey,
                  width: sel ? 2.5 : 1.5,
                ),
                boxShadow: sel ? [] : AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sel
                          ? AppColors.primaryOrange
                          : AppColors.lightGrey,
                    ),
                    alignment: Alignment.center,
                    child: sel
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt.value,
                      style: TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: sel ? AppColors.primaryOrange : AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

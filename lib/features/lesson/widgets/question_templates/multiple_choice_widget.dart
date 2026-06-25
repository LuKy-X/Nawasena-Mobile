import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';

/// Pilihan Ganda — 2 kolom, tap untuk pilih.
/// Digunakan juga oleh: visual_audio_identification, dialog_simulation
class MultipleChoiceWidget extends StatefulWidget {
  final QuestionModel question;
  final void Function(AnswerPayload) onAnswerChanged;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  int? _selectedId;
  late final List<OptionModel> _shuffled;

  @override
  void initState() {
    super.initState();
    _shuffled = List<OptionModel>.from(widget.question.options)..shuffle();
  }

  void _select(OptionModel opt) {
    setState(() => _selectedId = opt.id);
    widget.onAnswerChanged(AnswerPayload(
      questionId:      widget.question.id,
      selectedOptionId: opt.id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _shuffled.length,
      itemBuilder: (_, i) {
        final opt      = _shuffled[i];
        final selected = _selectedId == opt.id;
        return _OptionCard(
          option:   opt,
          selected: selected,
          onTap:    () => _select(opt),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  final OptionModel option;
  final bool        selected;
  final VoidCallback onTap;

  const _OptionCard({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryOrange.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primaryOrange : AppColors.borderGrey,
          width: selected ? 2.5 : 1.5,
        ),
        boxShadow: selected
            ? [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.25),
                blurRadius: 8, offset: const Offset(0, 3))]
            : AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                option.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: selected ? AppColors.primaryOrange : AppColors.darkText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';

/// Susun Kalimat — blok kata di bagian bawah, area susun di atas.
/// User mengetuk blok untuk memindahkannya ke area susun (dan sebaliknya).
/// Terinspirasi dari desain Duolingo "tap the words".
class ScrambledBlocksWidget extends StatefulWidget {
  final QuestionModel question;
  final void Function(AnswerPayload) onAnswerChanged;

  const ScrambledBlocksWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  State<ScrambledBlocksWidget> createState() => _ScrambledBlocksWidgetState();
}

class _ScrambledBlocksWidgetState extends State<ScrambledBlocksWidget> {
  late List<OptionModel> _bankOptions;   // Kata-kata belum dipilih (bank bawah)
  final List<OptionModel> _arranged = []; // Kata-kata sudah disusun (area atas)

  @override
  void initState() {
    super.initState();
    // Shuffle bank agar urutan benar tidak langsung terlihat
    _bankOptions = List<OptionModel>.from(widget.question.options)..shuffle();
  }

  void _addWord(OptionModel opt) {
    setState(() {
      _bankOptions.remove(opt);
      _arranged.add(opt);
    });
    _notify();
  }

  void _removeWord(OptionModel opt) {
    setState(() {
      _arranged.remove(opt);
      _bankOptions.add(opt);
    });
    _notify();
  }

  void _notify() {
    if (_arranged.isEmpty) return;
    widget.onAnswerChanged(AnswerPayload(
      questionId:        widget.question.id,
      arrangedOptionIds: _arranged.map((o) => o.id).toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Area susun ────────────────────────────────────────────────
        const Text(
          'Susunanmu:',
          style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w700,
            fontSize: 13, color: AppColors.mediumText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _arranged.isNotEmpty
                  ? AppColors.primaryOrange.withOpacity(0.4)
                  : AppColors.borderGrey,
              width: 2,
            ),
          ),
          child: _arranged.isEmpty
              ? Center(
                  child: Text(
                    'Ketuk kata di bawah untuk menyusun kalimat',
                    style: TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                      fontSize: 13, color: Colors.grey.shade400,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _arranged.map((opt) => _WordChip(
                    word: opt.value,
                    isArranged: true,
                    onTap: () => _removeWord(opt),
                  )).toList(),
                ),
        ),
        const SizedBox(height: 20),

        // ── Bank kata ─────────────────────────────────────────────────
        const Text(
          'Pilihan kata:',
          style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w700,
            fontSize: 13, color: AppColors.mediumText,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _bankOptions.map((opt) => _WordChip(
            word: opt.value,
            isArranged: false,
            onTap: () => _addWord(opt),
          )).toList(),
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool   isArranged;
  final VoidCallback onTap;

  const _WordChip({required this.word, required this.isArranged, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isArranged ? AppColors.primaryOrange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isArranged ? AppColors.primaryOrange : AppColors.borderGrey,
            width: isArranged ? 2 : 1.5,
          ),
          boxShadow: isArranged ? [] : AppTheme.cardShadow,
        ),
        child: Text(
          word,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: isArranged ? AppColors.primaryOrange : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}

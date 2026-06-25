import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';

/// Pasang-Pasangkan — dua kolom (Ngoko | Krama), tap kiri lalu tap kanan untuk berpasangan.
/// Pasangan yang benar dihighlight hijau, salah merah — validasi dilakukan di backend.
class PairMatchingWidget extends StatefulWidget {
  final QuestionModel question;
  final void Function(AnswerPayload) onAnswerChanged;

  const PairMatchingWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  State<PairMatchingWidget> createState() => _PairMatchingWidgetState();
}

class _PairMatchingWidgetState extends State<PairMatchingWidget> {
  // Separasi opsi berdasarkan urutan: separuh awal = kiri, separuh akhir = kanan
  late final List<OptionModel> _leftOptions;
  late final List<OptionModel> _rightOptions;

  int? _selectedLeftId;
  // Map<leftId, rightId> — pasangan yang sudah dibuat
  final Map<int, int> _pairs = {};
  // Set ID yang sudah berpasangan
  final Set<int> _pairedIds = {};

  @override
  void initState() {
    super.initState();
    final opts = widget.question.options;
    final half  = opts.length ~/ 2;
    _leftOptions  = List<OptionModel>.from(opts.take(half))..shuffle();
    _rightOptions = List<OptionModel>.from(opts.skip(half))..shuffle();
  }

  void _tapLeft(OptionModel opt) {
    if (_pairedIds.contains(opt.id)) return; // Sudah berpasangan, tidak bisa diubah
    setState(() => _selectedLeftId = opt.id == _selectedLeftId ? null : opt.id);
  }

  void _tapRight(OptionModel opt) {
    if (_pairedIds.contains(opt.id)) return;
    if (_selectedLeftId == null) return;

    setState(() {
      _pairs[_selectedLeftId!] = opt.id;
      _pairedIds.add(_selectedLeftId!);
      _pairedIds.add(opt.id);
      _selectedLeftId = null;
    });

    _notify();
  }

  void _notify() {
    if (_pairs.isEmpty) return;
    widget.onAnswerChanged(AnswerPayload(
      questionId: widget.question.id,
      pairs: _pairs.entries.map((e) => [e.key, e.value]).toList(),
    ));
  }

  Color _leftColor(OptionModel opt) {
    if (_pairs.containsKey(opt.id)) return AppColors.successGreen;
    if (_selectedLeftId == opt.id)  return AppColors.primaryOrange;
    if (_pairedIds.contains(opt.id)) return AppColors.successGreen;
    return Colors.white;
  }

  Color _rightColor(OptionModel opt) {
    final isPaired = _pairs.values.contains(opt.id);
    if (isPaired) return AppColors.successGreen;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Instruksi singkat
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryBrown.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 14)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ketuk kata di kiri, lalu pasangkan dengan kata di kanan.',
                  style: TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                    fontSize: 12, color: AppColors.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dua kolom
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom kiri
            Expanded(
              child: Column(
                children: [
                  const _ColumnHeader(label: 'Ngoko'),
                  const SizedBox(height: 8),
                  ..._leftOptions.map((opt) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PairCard(
                      label:      opt.value,
                      color:      _leftColor(opt),
                      isSelected: _selectedLeftId == opt.id,
                      onTap:      () => _tapLeft(opt),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Kolom kanan
            Expanded(
              child: Column(
                children: [
                  const _ColumnHeader(label: 'Krama'),
                  const SizedBox(height: 8),
                  ..._rightOptions.map((opt) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PairCard(
                      label:      opt.value,
                      color:      _rightColor(opt),
                      isSelected: false,
                      onTap:      () => _tapRight(opt),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),

        // Progress pasangan
        const SizedBox(height: 12),
        Text(
          '${_pairs.length} / ${_leftOptions.length} pasang tersambung',
          style: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w700,
            fontSize: 13, color: AppColors.mediumText,
          ),
        ),
      ],
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final String label;
  const _ColumnHeader({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primaryBrown.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w800,
        fontSize: 13, color: AppColors.primaryBrown,
      ),
    ),
  );
}

class _PairCard extends StatelessWidget {
  final String label;
  final Color  color;
  final bool   isSelected;
  final VoidCallback onTap;

  const _PairCard({required this.label, required this.color,
      required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPaired = color == AppColors.successGreen;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(isPaired || isSelected ? 0.1 : 0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPaired ? AppColors.successGreen
                : isSelected ? AppColors.primaryOrange
                : AppColors.borderGrey,
            width: isPaired || isSelected ? 2.5 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13,
            color: isPaired ? AppColors.successGreen
                : isSelected ? AppColors.primaryOrange
                : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}

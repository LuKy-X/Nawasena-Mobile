import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';

/// Panel feedback bawah ala Duolingo — muncul setelah user menjawab.
/// - correct   : hijau, teks "Benar! 🎉", tombol "Lanjutkan"
/// - wrong     : merah, teks "Salah 😞", penjelasan, tombol "Oke"
/// - neutral   : abu-abu (soal bukan terakhir, server belum tahu benar/salah)
enum FeedbackType { correct, wrong, neutral }

class FeedbackPanel extends StatefulWidget {
  final FeedbackType type;
  final String? explanation;
  final VoidCallback onContinue;

  const FeedbackPanel({
    super.key,
    required this.type,
    this.explanation,
    required this.onContinue,
  });

  @override
  State<FeedbackPanel> createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends State<FeedbackPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 280),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (widget.type) {
      FeedbackType.correct  => AppColors.successGreen,
      FeedbackType.wrong    => AppColors.primaryRed,
      FeedbackType.neutral  => AppColors.primaryOrange,
    };
    final darkColor = Color.lerp(bgColor, Colors.black, 0.2)!;
    final label = switch (widget.type) {
      FeedbackType.correct  => 'Benar! 🎉',
      FeedbackType.wrong    => 'Hampir! Coba perhatikan lagi.',
      FeedbackType.neutral  => 'Jawaban disimpan!',
    };
    final icon = switch (widget.type) {
      FeedbackType.correct  => Icons.check_circle_rounded,
      FeedbackType.wrong    => Icons.cancel_rounded,
      FeedbackType.neutral  => Icons.arrow_circle_right_rounded,
    };
    final btnLabel = widget.type == FeedbackType.wrong ? 'Oke, Mengerti' : 'Lanjutkan';

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.35),
              blurRadius: 20, offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                        fontSize: 18, color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.explanation != null && widget.explanation!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.explanation!,
                    style: TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                      fontSize: 13, color: Colors.white.withOpacity(0.95),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Tombol Lanjutkan
              GestureDetector(
                onTap: widget.onContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: darkColor,
                        blurRadius: 0, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    btnLabel,
                    style: TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                      fontSize: 16, color: bgColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

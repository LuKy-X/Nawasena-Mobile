// lib/core/widgets/heart_stamina_bar.dart
import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';

/// Widget "Heart Stamina" — Visual Hati, Logika Energi.
///
/// Menampilkan 5 ikon hati di UI, tapi setiap hati punya "isi" (fill)
/// berdasarkan poin stamina (0-100). 1 hati = 20 poin.
///
/// Contoh: heartPoints = 47 →
///   Hati 1 : penuh   (0-20)
///   Hati 2 : penuh   (20-40)
///   Hati 3 : isi 35% (40-60, sisa 7/20 poin)
///   Hati 4 : kosong
///   Hati 5 : kosong
///
/// Jika [hasInfiniteHearts] true (user Premium), bar diganti dengan
/// badge emas "❤️ ∞" — Infinite Hearts, stamina tidak pernah berkurang.
class HeartStaminaBar extends StatelessWidget {
  final int    heartPoints;       // 0-100
  final bool   hasInfiniteHearts;
  final bool   compact;           // true = ukuran kecil (app bar / header sesi)
  final bool   showLabel;         // tampilkan teks "xx/100" di samping
  final int    maxHeartsDisplay;  // jumlah ikon hati (default 5)

  const HeartStaminaBar({
    super.key,
    required this.heartPoints,
    this.hasInfiniteHearts = false,
    this.compact = false,
    this.showLabel = false,
    this.maxHeartsDisplay = 5,
  });

  static const int pointsPerHeart = 20;

  @override
  Widget build(BuildContext context) {
    if (hasInfiniteHearts) {
      return _InfiniteBadge(compact: compact);
    }

    final iconSize = compact ? 18.0 : 28.0;
    final gap      = compact ? 1.0 : 3.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < maxHeartsDisplay; i++) ...[
          if (i > 0) SizedBox(width: gap),
          _SingleHeart(
            fraction: _fractionFor(i),
            size: iconSize,
          ),
        ],
        if (showLabel) ...[
          SizedBox(width: compact ? 6 : 10),
          Text(
            '$heartPoints/100',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: compact ? 11 : 14,
              color: AppColors.primaryRed,
            ),
          ),
        ],
      ],
    );
  }

  /// Hitung fraksi isi (0.0 - 1.0) untuk hati ke-[index] (0-based).
  double _fractionFor(int index) {
    final segmentStart = index * pointsPerHeart;
    final pointsInThisHeart = (heartPoints - segmentStart).clamp(0, pointsPerHeart);
    return pointsInThisHeart / pointsPerHeart;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Satu ikon hati dengan fill horizontal (efek "bar isi" ala RPG)
// ─────────────────────────────────────────────────────────────────────────────
class _SingleHeart extends StatelessWidget {
  final double fraction; // 0.0 - 1.0
  final double size;

  const _SingleHeart({required this.fraction, required this.size});

  @override
  Widget build(BuildContext context) {
    final isEmpty = fraction <= 0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Lapisan dasar: hati kosong (outline abu)
          Icon(
            Icons.favorite,
            size: size,
            color: isEmpty
                ? AppColors.lockedGrey.withOpacity(0.35)
                : AppColors.primaryRed.withOpacity(0.18),
          ),
          // Lapisan isi: hati merah, di-clip sesuai fraction dari KIRI
          if (fraction > 0)
            ClipRect(
              clipper: _LeftFractionClipper(fraction),
              child: Icon(
                Icons.favorite,
                size: size,
                color: AppColors.primaryRed,
              ),
            ),
        ],
      ),
    );
  }
}

class _LeftFractionClipper extends CustomClipper<Rect> {
  final double fraction;
  const _LeftFractionClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(covariant _LeftFractionClipper old) =>
      old.fraction != fraction;
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge "Infinite Hearts" untuk user Premium
// ─────────────────────────────────────────────────────────────────────────────
class _InfiniteBadge extends StatelessWidget {
  final bool compact;
  const _InfiniteBadge({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 14,
        vertical:   compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: Colors.white, size: compact ? 13 : 18),
          SizedBox(width: compact ? 3 : 5),
          Text(
            '∞',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              fontSize: compact ? 13 : 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

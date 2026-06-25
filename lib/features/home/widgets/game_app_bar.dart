// lib/features/home/widgets/game_app_bar.dart
//
// App bar bergaya game — background gelap, stat chips ala Duolingo.
// Heart Stamina ditampilkan via HeartStaminaBar (bar isi, bukan lagi
// angka "X/5" sederhana) agar konsisten dengan sistem stamina baru.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/heart_stamina_bar.dart';
import 'package:nawasena/features/auth/models/user_model.dart';

class GameAppBar extends StatelessWidget {
  final UserModel user;
  const GameAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar kecil
          _Avatar(url: user.avatarUrl, name: user.name),
          const Spacer(),

          // ── Heart Stamina Bar (compact) ───────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryRed.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: HeartStaminaBar(
              heartPoints: user.heartPoints,
              hasInfiniteHearts: user.hasInfiniteHearts,
              compact: true,
            ),
          ),
          const SizedBox(width: 8),

          _Chip(
            emoji: '🔥',
            value: '${user.streakCount}',
            iconColor: const Color(0xFFFF9600),
            borderColor: const Color(0xFFFF9600),
          ),
          const SizedBox(width: 8),
          _Chip(
            emoji: '💎',
            value: '${user.diamonds}',
            iconColor: const Color(0xFF1CB0F6),
            borderColor: const Color(0xFF1CB0F6),
          ),
          const SizedBox(width: 8),
          _Chip(
            emoji: '⚡',
            value: '${user.xpTotal}',
            iconColor: const Color(0xFFFF86D0),
            borderColor: const Color(0xFFFF86D0),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String  name;
  const _Avatar({this.url, required this.name});

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.successGreen, width: 2),
    ),
    child: ClipOval(
      child: url != null
          ? CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _Initials(name: name))
          : _Initials(name: name),
    ),
  );
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.primaryOrange.withOpacity(0.3),
    alignment: Alignment.center,
    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'N',
        style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900,
            fontSize: 16, color: Colors.white)),
  );
}

class _Chip extends StatelessWidget {
  final IconData? icon;
  final String?   emoji;
  final String    value;
  final Color     iconColor;
  final Color     borderColor;

  const _Chip({
    this.icon, this.emoji,
    required this.value,
    required this.iconColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: borderColor.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (emoji != null)
        Text(emoji!, style: const TextStyle(fontSize: 13))
      else if (icon != null)
        Icon(icon, size: 14, color: iconColor),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w800,
        fontSize: 13, color: iconColor,
      )),
    ]),
  );
}

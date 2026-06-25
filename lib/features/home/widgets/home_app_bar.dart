import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/bouncy_tap.dart';
import 'package:nawasena/features/auth/models/user_model.dart';

class HomeAppBar extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onAvatarTap;

  const HomeAppBar({super.key, required this.user, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
          // ── Avatar ────────────────────────────────────────────────────
          BouncyTap(
            onTap: onAvatarTap,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryOrange, width: 2.5),
                boxShadow: AppTheme.softShadow,
              ),
              child: ClipOval(
                child: user.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: user.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.primaryOrange.withOpacity(0.1),
                          alignment: Alignment.center,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'N',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _AvatarFallback(name: user.name),
                      )
                    : _AvatarFallback(name: user.name),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Greeting ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumText,
                  ),
                ),
                Text(
                  user.name.split(' ').first,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Stats Row ─────────────────────────────────────────────────
          _StatChip(
            emoji: '🔥',
            value: '${user.streakCount}',
            color: const Color(0xFFFF5722),
          ),
          const SizedBox(width: 6),
          _StatChip(
            emoji: '❤️',
            value: '${user.heartPoints}',
            color: AppColors.primaryRed,
          ),
          const SizedBox(width: 6),
          _StatChip(
            emoji: '💎',
            value: '${user.diamonds}',
            color: AppColors.primaryBrown,
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11)  return 'Sugeng Enjing ☀️';
    if (hour < 15)  return 'Sugeng Siang 🌤';
    if (hour < 18)  return 'Sugeng Sonten 🌇';
    return 'Sugeng Dalu 🌙';
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final Color  color;

  const _StatChip({required this.emoji, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryOrange.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'N',
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: AppColors.primaryOrange,
        ),
      ),
    );
  }
}

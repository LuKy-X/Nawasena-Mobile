import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/leaderboard/models/leaderboard_model.dart';
import 'package:nawasena/features/leaderboard/providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myId = context.read<AuthProvider>().user?.id;
      context.read<LeaderboardProvider>().load(myUserId: myId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _LeaderboardHeader(),
          Expanded(
            child: Consumer<LeaderboardProvider>(
              builder: (context, lp, _) {
                if (lp.isLoading) {
                  return const Center(
                    child: MascotWidget(
                      pose: MascotPose.thinking,
                      size: 100,
                      animate: true,
                    ),
                  );
                }
                if (lp.state == LeaderboardState.error) {
                  return _ErrorState(onRetry: () {
                    final myId = context.read<AuthProvider>().user?.id;
                    lp.load(myUserId: myId, forceRefresh: true);
                  });
                }
                return RefreshIndicator(
                  color: AppColors.primaryOrange,
                  onRefresh: () {
                    final myId = context.read<AuthProvider>().user?.id;
                    return lp.load(myUserId: myId, forceRefresh: true);
                  },
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // ── Podium top 3 ─────────────────────────────────
                      if (lp.entries.length >= 3)
                        _Podium(top3: lp.entries.take(3).toList()),
                      const SizedBox(height: 20),

                      // ── Peringkat saya ────────────────────────────────
                      if (lp.myRank != null && lp.myRank!.rank != null)
                        _MyRankCard(myRank: lp.myRank!),
                      const SizedBox(height: 12),

                      // ── Daftar lengkap ────────────────────────────────
                      ...lp.entries.skip(3).map((e) => _EntryCard(entry: e)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Text(
            '🏆 Peringkat',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Mingguan',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> top3;
  const _Podium({required this.top3});

  @override
  Widget build(BuildContext context) {
    // Urutan tampil: 2nd, 1st, 3rd
    final displayOrder = [
      top3.length > 1 ? top3[1] : null,
      top3[0],
      top3.length > 2 ? top3[2] : null,
    ];
    final heights = [90.0, 120.0, 70.0];
    final colors  = [
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFFFD700), // Gold
      const Color(0xFFCD7F32), // Bronze
    ];
    final ranks = [2, 1, 3];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final entry = displayOrder[i];
          if (entry == null) return const Spacer();
          return Expanded(
            child: _PodiumSlot(
              entry:   entry,
              height:  heights[i],
              color:   colors[i],
              rank:    ranks[i],
            ),
          );
        }),
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final Color  color;
  final int    rank;
  const _PodiumSlot({required this.entry, required this.height,
      required this.color, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isMe;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank == 1)
          const Text('👑', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        // Avatar
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? AppColors.primaryOrange : color,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: entry.avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: entry.avatarUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _NameAvatar(name: entry.name),
                  )
                : _NameAvatar(name: entry.name),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.name.split(' ').first,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: isMe ? AppColors.primaryOrange : AppColors.darkText,
          ),
        ),
        Text(
          '${entry.weeklyXp} XP',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: AppColors.mediumText,
          ),
        ),
        const SizedBox(height: 6),
        // Podium bar
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _NameAvatar extends StatelessWidget {
  final String name;
  const _NameAvatar({required this.name});
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.primaryOrange.withOpacity(0.1),
    alignment: Alignment.center,
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'N',
      style: const TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w900,
        fontSize: 20, color: AppColors.primaryOrange,
      ),
    ),
  );
}

class _MyRankCard extends StatelessWidget {
  final MyRankInfo myRank;
  const _MyRankCard({required this.myRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Text('🏅', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Peringkatmu minggu ini',
              style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                fontSize: 13, color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Text(
            '#${myRank.rank}',
            style: const TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w900,
              fontSize: 22, color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${myRank.weeklyXp} XP',
            style: TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w700,
              fontSize: 14, color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final LeaderboardEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isMe;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryOrange.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? AppColors.primaryOrange.withOpacity(0.4) : AppColors.borderGrey,
          width: isMe ? 2 : 1,
        ),
        boxShadow: isMe ? AppTheme.softShadow : [],
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGrey,
            ),
            alignment: Alignment.center,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                fontSize: 12,
                color: isMe ? AppColors.primaryOrange : AppColors.mediumText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: entry.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: entry.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _NameAvatar(name: entry.name),
                    )
                  : _NameAvatar(name: entry.name),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                fontSize: 14,
                color: isMe ? AppColors.primaryOrange : AppColors.darkText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (entry.streakCount > 0) ...[
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 3),
            Text('${entry.streakCount}',
                style: const TextStyle(
                  fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                  fontSize: 13, color: Color(0xFFFF5722),
                )),
            const SizedBox(width: 10),
          ],
          Text(
            '${entry.weeklyXp} XP',
            style: TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isMe ? AppColors.primaryOrange : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MascotWidget(pose: MascotPose.thinking, size: 100),
        const SizedBox(height: 16),
        const Text('Gagal memuat peringkat.', style: TextStyle(
          fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: AppColors.mediumText,
        )),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
      ],
    ),
  );
}

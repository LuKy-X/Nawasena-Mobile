class LeaderboardEntry {
  final int    rank;
  final int    userId;
  final String name;
  final String? avatarUrl;
  final int    streakCount;
  final int    weeklyXp;
  final bool   isMe;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.streakCount,
    required this.weeklyXp,
    this.isMe = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json,
      {int? myUserId}) => LeaderboardEntry(
    rank:        (json['rank']         as num).toInt(),
    userId:      (json['user_id']      as num).toInt(),
    name:        json['name']          as String? ?? '',
    avatarUrl:   json['avatar_url']    as String?,
    streakCount: (json['streak_count'] as num?)?.toInt() ?? 0,
    weeklyXp:    (json['weekly_xp']    as num?)?.toInt() ?? 0,
    isMe: myUserId != null &&
        (json['user_id'] as num).toInt() == myUserId,
  );
}

class MyRankInfo {
  final int?   rank;
  final int    weeklyXp;

  const MyRankInfo({this.rank, required this.weeklyXp});

  factory MyRankInfo.fromJson(Map<String, dynamic> json) => MyRankInfo(
    rank:     (json['rank'] as num?)?.toInt(),
    weeklyXp: (json['weekly_xp'] as num?)?.toInt() ?? 0,
  );
}

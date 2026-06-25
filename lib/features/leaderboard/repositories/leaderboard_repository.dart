import 'package:nawasena/core/network/api_client.dart';
import 'package:nawasena/features/leaderboard/models/leaderboard_model.dart';

class LeaderboardRepository {
  LeaderboardRepository._();
  static final LeaderboardRepository instance = LeaderboardRepository._();

  final _api = ApiClient.instance;

  Future<List<LeaderboardEntry>> fetchLeaderboard({int? myUserId}) async {
    return await _api.get<List<LeaderboardEntry>>(
      '/v1/leaderboard',
      parser: (data) {
        final list = (data as Map<String, dynamic>)['data'] as List<dynamic>;
        return list
            .map((e) => LeaderboardEntry.fromJson(
                  e as Map<String, dynamic>,
                  myUserId: myUserId,
                ))
            .toList();
      },
    );
  }

  Future<MyRankInfo> fetchMyRank() async {
    return await _api.get<MyRankInfo>(
      '/v1/leaderboard/me',
      parser: (data) => MyRankInfo.fromJson(
        (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }
}

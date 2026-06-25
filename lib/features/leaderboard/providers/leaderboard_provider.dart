import 'package:flutter/material.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/features/leaderboard/models/leaderboard_model.dart';
import 'package:nawasena/features/leaderboard/repositories/leaderboard_repository.dart';

enum LeaderboardState { initial, loading, loaded, error }

class LeaderboardProvider extends ChangeNotifier {
  final _repo = LeaderboardRepository.instance;

  LeaderboardState       _state   = LeaderboardState.initial;
  List<LeaderboardEntry> _entries = [];
  MyRankInfo?            _myRank;
  String?                _error;

  LeaderboardState       get state   => _state;
  List<LeaderboardEntry> get entries => _entries;
  MyRankInfo?            get myRank  => _myRank;
  String?                get error   => _error;
  bool                   get isLoading => _state == LeaderboardState.loading;

  Future<void> load({int? myUserId, bool forceRefresh = false}) async {
    if (_state == LeaderboardState.loaded && !forceRefresh) return;

    _state = LeaderboardState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.fetchLeaderboard(myUserId: myUserId),
        _repo.fetchMyRank(),
      ]);
      _entries = results[0] as List<LeaderboardEntry>;
      _myRank  = results[1] as MyRankInfo;
      _state   = LeaderboardState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LeaderboardState.error;
    } catch (_) {
      _error = 'Gagal memuat leaderboard.';
      _state = LeaderboardState.error;
    }
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/features/auth/models/user_model.dart';
import 'package:nawasena/features/profile/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final _repo = ProfileRepository.instance;

  bool    _isUpdating = false;
  String? _error;

  bool    get isUpdating => _isUpdating;
  String? get error      => _error;

  Future<UserModel?> updateProfile({
    required UserModel currentUser,
    String? name,
    String? avatarUrl,
  }) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repo.updateProfile(name: name, avatarUrl: avatarUrl);
      _isUpdating = false;
      notifyListeners();
      return updated;
    } on ApiException catch (e) {
      _error = e.firstError ?? e.message;
      _isUpdating = false;
      notifyListeners();
      return null;
    }
  }
}

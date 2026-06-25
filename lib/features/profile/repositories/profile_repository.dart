import 'package:nawasena/core/network/api_client.dart';
import 'package:nawasena/features/auth/models/user_model.dart';

class ProfileRepository {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  final _api = ApiClient.instance;

  Future<UserModel> fetchProfile() async {
    return await _api.get<UserModel>(
      '/v1/profile',
      parser: (data) => UserModel.fromJson(
        (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  Future<UserModel> updateProfile({String? name, String? avatarUrl}) async {
    return await _api.patch<UserModel>(
      '/v1/profile',
      data: {
        if (name      != null) 'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      parser: (data) => UserModel.fromJson(
        (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }
}

import 'package:nawasena/core/network/api_client.dart';
import 'package:nawasena/features/home/models/course_model.dart';

class HomeRepository {
  HomeRepository._();
  static final HomeRepository instance = HomeRepository._();

  final _api = ApiClient.instance;

  /// Ambil semua courses beserta status lesson per-user
  Future<List<CourseModel>> fetchCourses() async {
    return await _api.get<List<CourseModel>>(
      '/v1/courses',
      parser: (data) {
        final list = (data as Map<String, dynamic>)['data'] as List<dynamic>;
        return list
            .map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Ambil detail satu course
  Future<CourseModel> fetchCourseDetail(int courseId) async {
    return await _api.get<CourseModel>(
      '/v1/courses/$courseId',
      parser: (data) => CourseModel.fromJson(
        (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }
}

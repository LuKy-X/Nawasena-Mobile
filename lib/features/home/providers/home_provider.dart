import 'package:flutter/material.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/features/home/models/course_model.dart';
import 'package:nawasena/features/home/repositories/home_repository.dart';

enum HomeLoadState { initial, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final _repo = HomeRepository.instance;

  HomeLoadState _state = HomeLoadState.initial;
  List<CourseModel> _courses = [];
  String? _error;

  HomeLoadState     get state   => _state;
  List<CourseModel> get courses => _courses;
  String?           get error   => _error;
  bool              get isLoading => _state == HomeLoadState.loading;

  /// Semua lesson dari semua course, untuk tampilan flat di learning path
  List<LessonModel> get allLessons =>
      _courses.expand((c) => c.levels.expand((l) => l.lessons)).toList();

  Future<void> loadCourses({bool forceRefresh = false}) async {
    if (_state == HomeLoadState.loaded && !forceRefresh) return;

    _state = HomeLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _courses = await _repo.fetchCourses();
      _state   = HomeLoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = HomeLoadState.error;
    } catch (_) {
      _error = 'Gagal memuat kursus. Periksa koneksi internet.';
      _state = HomeLoadState.error;
    }
    notifyListeners();
  }
}

/// Hierarki: Course → Level → Lesson
/// Sesuai dengan struktur response API /api/v1/courses

class CourseModel {
  final int id;
  final String title;
  final String? iconUrl;
  final String? description;
  final int order;
  final List<LevelModel> levels;

  const CourseModel({
    required this.id,
    required this.title,
    this.iconUrl,
    this.description,
    required this.order,
    required this.levels,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id:          (json['id'] as num).toInt(),
    title:       json['title']       as String? ?? '',
    iconUrl:     json['icon_url']    as String?,
    description: json['description'] as String?,
    order:       (json['order'] as num?)?.toInt() ?? 0,
    levels: (json['levels'] as List<dynamic>? ?? [])
        .map((l) => LevelModel.fromJson(l as Map<String, dynamic>))
        .toList(),
  );

  /// Total lesson selesai di course ini
  int get completedLessons => levels
      .expand((l) => l.lessons)
      .where((l) => l.status == LessonStatus.completed)
      .length;

  int get totalLessons => levels.expand((l) => l.lessons).length;

  double get progressPercent =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
}

class LevelModel {
  final int id;
  final String title;
  final int order;
  final List<LessonModel> lessons;

  const LevelModel({
    required this.id,
    required this.title,
    required this.order,
    required this.lessons,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id:    (json['id'] as num).toInt(),
    title: json['title'] as String? ?? '',
    order: (json['order'] as num?)?.toInt() ?? 1,
    lessons: (json['lessons'] as List<dynamic>? ?? [])
        .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
        .toList(),
  );
}

enum LessonStatus { locked, unlocked, completed }

class LessonModel {
  final int id;
  final String title;
  final int xpReward;
  final int order;
  final LessonStatus status;
  final int? score;

  const LessonModel({
    required this.id,
    required this.title,
    required this.xpReward,
    required this.order,
    required this.status,
    this.score,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'locked';
    return LessonModel(
      id:       (json['id'] as num).toInt(),
      title:    json['title']     as String? ?? '',
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 10,
      order:    (json['order'] as num?)?.toInt() ?? 1,
      score:    (json['score'] as num?)?.toInt(),
      status: switch (statusStr) {
        'completed' => LessonStatus.completed,
        'unlocked'  => LessonStatus.unlocked,
        _           => LessonStatus.locked,
      },
    );
  }
}

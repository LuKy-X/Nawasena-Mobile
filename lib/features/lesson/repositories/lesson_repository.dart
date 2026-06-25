import 'package:nawasena/core/network/api_client.dart';

import 'package:nawasena/features/lesson/models/question_model.dart';

class LessonRepository {
  LessonRepository._();
  static final LessonRepository instance = LessonRepository._();
  final _api = ApiClient.instance;

  /// Ambil detail lesson beserta soal-soalnya
  /// GET /api/v1/lessons/{lessonId}
  Future<List<QuestionModel>> fetchLessonQuestions(int lessonId) async {
    return await _api.get<List<QuestionModel>>(
      '/v1/lessons/$lessonId',
      parser: (data) {
        final lessonData = (data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        final questionsList = lessonData['questions'] as List<dynamic>? ?? [];
        return questionsList
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Kirim semua jawaban sekaligus ke backend
  /// POST /api/v1/lessons/{lessonId}/submit
  Future<LessonSubmitResult> submitLesson({
    required int lessonId,
    required List<AnswerPayload> answers,
  }) async {
    return await _api.post<LessonSubmitResult>(
      '/v1/lessons/$lessonId/submit',
      data: {'answers': answers.map((a) => a.toJson()).toList()},
      parser: (data) => LessonSubmitResult.fromJson(data as Map<String, dynamic>),
    );
  }
}

/// Model soal beserta opsi jawabannya.
/// Sesuai response dari GET /api/v1/lessons/{id}

class QuestionModel {
  final int    id;
  final int    order;
  final String promptText;
  final String? mediaUrl;
  final String  mediaType; // 'image' | 'audio' | 'svg' | 'none'
  final String? hint;
  final String? explanation;
  final TemplateInfo   template;
  final List<OptionModel> options;

  const QuestionModel({
    required this.id,
    required this.order,
    required this.promptText,
    this.mediaUrl,
    required this.mediaType,
    this.hint,
    this.explanation,
    required this.template,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id:          (json['id']    as num).toInt(),
    order:       (json['order'] as num?)?.toInt()    ?? 1,
    promptText:  json['prompt_text'] as String?      ?? '',
    mediaUrl:    json['media_url']   as String?,
    mediaType:   json['media_type']  as String?      ?? 'none',
    hint:        json['hint']        as String?,
    explanation: json['explanation'] as String?,
    template: TemplateInfo.fromJson(
        json['template'] as Map<String, dynamic>? ?? {}),
    options: (json['options'] as List<dynamic>? ?? [])
        .map((o) => OptionModel.fromJson(o as Map<String, dynamic>))
        .toList(),
  );

  String get templateSlug => template.slug;
}

class TemplateInfo {
  final int    id;
  final String slug;
  final String name;
  final String instructionId;

  const TemplateInfo({
    required this.id,
    required this.slug,
    required this.name,
    required this.instructionId,
  });

  factory TemplateInfo.fromJson(Map<String, dynamic> json) => TemplateInfo(
    id:            (json['id'] as num?)?.toInt() ?? 0,
    slug:          json['slug']           as String? ?? '',
    name:          json['name']           as String? ?? '',
    instructionId: json['instruction_id'] as String? ?? '',
  );
}

class OptionModel {
  final int    id;
  final String value;
  final int?   orderIndex; // scrambled_blocks
  final String? matchKey;  // pair_matching

  const OptionModel({
    required this.id,
    required this.value,
    this.orderIndex,
    this.matchKey,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) => OptionModel(
    id:         (json['id'] as num).toInt(),
    value:      json['value']       as String? ?? '',
    orderIndex: (json['order_index'] as num?)?.toInt(),
    matchKey:   json['match_key']   as String?,
  );
}

/// Jawaban yang akan dikirim ke API
class AnswerPayload {
  final int questionId;
  final int?          selectedOptionId;    // multiple_choice / visual_audio / dialog
  final List<int>?    arrangedOptionIds;   // scrambled_blocks
  final List<List<int>>? pairs;           // pair_matching
  final List<List<Map<String, double>>>? strokePoints; 

  const AnswerPayload({
    required this.questionId,
    this.selectedOptionId,
    this.arrangedOptionIds,
    this.pairs,
    this.strokePoints,
  });

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    if (selectedOptionId   != null) 'selected_option_id':   selectedOptionId,
    if (arrangedOptionIds  != null) 'arranged_option_ids':  arrangedOptionIds,
    if (pairs              != null) 'pairs':                pairs,
    if (strokePoints       != null) 'stroke_points':        strokePoints,
  };
}

/// Hasil penilaian satu soal (dari server setelah submit)
class QuestionResult {
  final int    questionId;
  final bool   isCorrect;
  final String? explanation;

  const QuestionResult({
    required this.questionId,
    required this.isCorrect,
    this.explanation,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
    questionId:  (json['question_id'] as num).toInt(),
    isCorrect:   json['is_correct']   as bool? ?? false,
    explanation: json['explanation']  as String?,
  );
}

/// Hasil keseluruhan setelah submit lesson
class LessonSubmitResult {
  final int    score;
  final int    correctAnswers;
  final int    totalQuestions;
  final int    xpEarned;
  final bool   lessonCompleted;
  final List<QuestionResult> questionResults;

  // ── Heart Stamina System ────────────────────────────────────────────────
  /// Poin stamina mentah (0-100) SETELAH lesson ini dikerjakan.
  /// Sumber kebenaran untuk HeartStaminaBar — gunakan ini, bukan [heartsDisplay].
  final int  heartPointsRemaining;

  /// Berapa kali bonus combo (5 jawaban benar berturut-turut) terpicu
  /// selama sesi ini. Dipakai untuk menampilkan banner "Bonus Combo!"
  /// di LessonResultScreen.
  final int  staminaBonusEvents;

  /// True jika user Premium (Infinite Hearts) — stamina tidak berkurang.
  final bool hasInfiniteHearts;

  const LessonSubmitResult({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpEarned,
    required this.lessonCompleted,
    required this.questionResults,
    required this.heartPointsRemaining,
    required this.staminaBonusEvents,
    required this.hasInfiniteHearts,
  });

  factory LessonSubmitResult.fromJson(Map<String, dynamic> json) {
    // Tangani dua kemungkinan format: wrapped dalam 'data' atau langsung
    final d = (json['data'] as Map<String, dynamic>?) ?? json;
    return LessonSubmitResult(
      score:                (d['score']                  as num?)?.toInt() ?? 0,
      correctAnswers:       (d['correct_answers']        as num?)?.toInt() ?? 0,
      totalQuestions:       (d['total_questions']        as num?)?.toInt() ?? 0,
      xpEarned:             (d['xp_earned']               as num?)?.toInt() ?? 0,
      lessonCompleted:      d['lesson_completed']         as bool?          ?? true,
      heartPointsRemaining: (d['heart_points_remaining']  as num?)?.toInt() ?? 100,
      staminaBonusEvents:   (d['stamina_bonus_events']    as num?)?.toInt() ?? 0,
      hasInfiniteHearts:    d['has_infinite_hearts']      as bool?          ?? false,
      questionResults: (d['question_results'] as List<dynamic>? ?? [])
          .map((r) => QuestionResult.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Jumlah ikon hati (0-5) untuk teks ringkas — bar isi sesungguhnya
  /// pakai [heartPointsRemaining] via HeartStaminaBar.
  int get heartsDisplay => hasInfiniteHearts
      ? 5
      : (heartPointsRemaining / 20).ceil().clamp(0, 5);
}

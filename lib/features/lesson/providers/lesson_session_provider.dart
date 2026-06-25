import 'package:flutter/material.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';
import 'package:nawasena/features/lesson/repositories/lesson_repository.dart';
import 'dart:convert';

/// Phase sesi pengerjaan lesson — state machine.
enum SessionPhase {
  loading,    // Mengambil soal dari API
  answering,  // User sedang menjawab
  checking,   // Loading ke server (submit batch)
  correct,    // Panel "Lanjutkan" (soal non-terakhir atau benar)
  wrong,      // Panel "Salah!" (dari hasil server — belum dipakai di batch mode)
  completed,  // Semua soal selesai, hasil dari server tersedia
  error,      // Gagal load atau submit
}

/// State management untuk satu sesi lesson.
///
/// STRATEGI BATCH SUBMIT:
/// Jawaban dikumpulkan lokal (_allAnswers) soal per soal.
/// Pada soal terakhir, semua jawaban dikirim sekaligus ke server.
///
/// ── Heart Stamina System ──────────────────────────────────────────────────
/// Header sesi menampilkan [heartPoints] (0-100) — bukan lagi hitungan
/// nyawa 0-5 — via widget HeartStaminaBar. Nilai ini hanya bersifat
/// TAMPILAN AWAL (snapshot saat lesson dimulai); konsumsi/bonus stamina
/// sesungguhnya dihitung di server PER SOAL saat submit akhir, dan nilai
/// final-nya diambil dari [LessonSubmitResult.heartPointsRemaining].
class LessonSessionProvider extends ChangeNotifier {
  final int lessonId;
  final bool hasInfiniteHearts;
  final _repo = LessonRepository.instance;

  LessonSessionProvider({
    required this.lessonId,
    required int initialHeartPoints,
    this.hasInfiniteHearts = false,
  }) : _heartPoints = initialHeartPoints;

  // ── State ──────────────────────────────────────────────────────────────────
  SessionPhase          _phase         = SessionPhase.loading;
  List<QuestionModel>   _questions     = [];
  int                   _currentIdx    = 0;
  AnswerPayload?        _currentAnswer;
  int                   _heartPoints;
  final List<AnswerPayload> _allAnswers = [];
  LessonSubmitResult?   _result;
  String?               _error;
  bool                  _hintVisible   = false;
  String?               _lastExplanation;

  // ── Getters ────────────────────────────────────────────────────────────────
  SessionPhase        get phase          => _phase;
  List<QuestionModel> get questions      => _questions;
  int                 get currentIdx     => _currentIdx;
  int                 get totalQuestions => _questions.length;
  int                 get heartPoints    => _heartPoints;
  LessonSubmitResult? get result         => _result;
  String?             get error          => _error;
  bool                get hintVisible    => _hintVisible;
  String?             get lastExplanation => _lastExplanation;
  bool                get canCheck       => _currentAnswer != null;
  bool                get isLastQuestion => _currentIdx == _questions.length - 1;

  double get progressValue =>
      _questions.isEmpty ? 0 : _currentIdx / _questions.length;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _currentIdx < _questions.length
          ? _questions[_currentIdx]
          : null;

  // ── Load Soal ─────────────────────────────────────────────────────────────
  Future<void> loadQuestions() async {
    _phase = SessionPhase.loading;
    _questions = [];
    _currentIdx = 0;
    _allAnswers.clear();
    _error = null;
    notifyListeners();

    try {
      _questions = await _repo.fetchLessonQuestions(lessonId);
      if (_questions.isEmpty) {
        _error = 'Lesson ini belum memiliki soal.';
        _phase = SessionPhase.error;
      } else {
        _phase = SessionPhase.answering;
      }
    } on ApiException catch (e) {
      _error = e.message;
      _phase = SessionPhase.error;
    } catch (_) {
      _error = 'Gagal memuat soal. Periksa koneksi internet.';
      _phase = SessionPhase.error;
    }
    notifyListeners();
  }

  // ── Jawaban ───────────────────────────────────────────────────────────────
  void setAnswer(AnswerPayload answer) {
    _currentAnswer = answer;

    // ── 🛑 DEBUG: CEK DATA MASUK KE PROVIDER ──────────────────
    // debugPrint('\n📥 [DEBUG PROVIDER] setAnswer Terpanggil!');
    // debugPrint('- ID Soal: ${answer.questionId}');
    // try {
    //   // Kita intip apakah data koordinat terbaca di sini
    //   final preview = jsonEncode(answer.toJson());
    //   debugPrint('- Payload Masuk: ${preview.substring(0, preview.length > 120 ? 120 : preview.length)}...');
    // } catch (e) {
    //   debugPrint('- ❌ Gagal mengintip payload: $e');
    // }
    // debugPrint('────────────────────────────────────────────\n');
    // ──────────────────────────────────────────────────────────

    notifyListeners();
  }

  void clearAnswer() {
    _currentAnswer = null;
    notifyListeners();
  }

  // ── Periksa / Submit ──────────────────────────────────────────────────────
  Future<void> checkAnswer() async {
    if (_currentAnswer == null) return;

    _phase = SessionPhase.checking;
    notifyListeners();

    // Simpan jawaban ke list batch
    _allAnswers.add(_currentAnswer!);

    // ── 🛑 DEBUG: CEK TIMBUNAN BATCH ──────────────────────────
    // debugPrint('\n📦 [DEBUG PROVIDER] checkAnswer Terpanggil!');
    // debugPrint('- Jawaban berhasil ditimbun ke dalam Batch Antrean.');
    // debugPrint('- Jumlah total jawaban di Batch saat ini: ${_allAnswers.length}');
    // debugPrint('────────────────────────────────────────────\n');
    // ──────────────────────────────────────────────────────────

    if (isLastQuestion) {
      // Soal terakhir → submit semua ke server
      await _submitAll();
    } else {
      // Soal non-terakhir → tampilkan panel "Lanjutkan" netral
      _lastExplanation = null;
      _phase = SessionPhase.correct;
      notifyListeners();
    }
  }

  Future<void> _submitAll() async {
    // ── 🛑 DEBUG: INTIP PAKET FINAL SEBELUM KIRIM KE REPO ────
    // debugPrint('\n🚀🚀🚀 [DEBUG PROVIDER] _submitAll DIJALANKAN! 🚀🚀🚀');
    // debugPrint('- Mengirim total ${_allAnswers.length} jawaban untuk Lesson ID: $lessonId');
    
    for (int i = 0; i < _allAnswers.length; i++) {
      try {
        final jsonString = jsonEncode(_allAnswers[i].toJson());
        // debugPrint('  📍 [Soal Ke-${i + 1}] JSON: $jsonString');
      } catch (e) {
        // debugPrint('  📍 [Soal Ke-${i + 1}] ❌ Gagal convert ke JSON: $e');
      }
    }
    // debugPrint('========================================================================\n');
    // ──────────────────────────────────────────────────────────

    try {
      _result = await _repo.submitLesson(
        lessonId: lessonId,
        answers:  _allAnswers,
      );
      // Stamina final dari server
      _heartPoints = _result!.heartPointsRemaining;
      _phase  = SessionPhase.completed;
    } on ApiException catch (e) {
      _error = e.message;
      _phase = SessionPhase.error;
    } catch (_) {
      _error = 'Gagal mengirim jawaban. Coba lagi.';
      _phase = SessionPhase.error;
    }
    notifyListeners();
  }

  // ── Navigasi Soal ─────────────────────────────────────────────────────────
  void nextQuestion() {
    _currentIdx++;
    _currentAnswer   = null;
    _lastExplanation = null;
    _hintVisible     = false;
    _phase           = SessionPhase.answering;
    notifyListeners();
  }

  // ── Hint ──────────────────────────────────────────────────────────────────
  void showHint() {
    _hintVisible = true;
    notifyListeners();
  }
}

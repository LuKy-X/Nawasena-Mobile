// lib/features/lesson/widgets/question_templates/aksara_tracing_widget.dart
import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/lesson/models/question_model.dart';
import 'dart:convert';

// ─── Canvas Model (sama seperti sebelumnya, ditambahkan getter untuk stroke raw) ───
class _CanvasModel extends ChangeNotifier {
  final List<List<Offset>> strokes = [];
  final List<Offset> current = [];

  bool get hasStrokes => strokes.isNotEmpty || current.isNotEmpty;

  void addPoint(Offset p) {
    current.add(p);
    notifyListeners();
  }

  void endStroke() {
    if (current.length > 1) strokes.add(List.of(current));
    current.clear();
    notifyListeners();
  }

  void cancelStroke() {
    current.clear();
    notifyListeners();
  }

  void clear() {
    strokes.clear();
    current.clear();
    notifyListeners();
  }

  // Untuk mengambil semua stroke dalam bentuk list of Offset
  List<List<Offset>> getAllStrokes() {
    return strokes.map((s) => List.of(s)).toList();
  }
}

// ─── Widget Utama ──────────────────────────────────────────────────────────
class AksaraTracingWidget extends StatefulWidget {
  final QuestionModel question;
  final void Function(AnswerPayload) onAnswerChanged;

  const AksaraTracingWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  State<AksaraTracingWidget> createState() => _AksaraTracingWidgetState();
}

class _AksaraTracingWidgetState extends State<AksaraTracingWidget> {
  final _model = _CanvasModel();
  bool _completed = false;

  late final String _char;
  late final String _name;

  // Ukuran canvas aktual (untuk normalisasi)
  double _canvasWidth = 0;
  double _canvasHeight = 0;

  // Hasil validasi instan (opsional)
  int _instantScore = 0;
  bool _instantPassed = false;

  bool _debugMode = true; // set ke false untuk production
  List<Map<String, double>> _checkpoints = [];  

  @override
  void initState() {
    super.initState();
    _char = _extractChar(widget.question.promptText);
    _name = _extractName(widget.question.promptText);
    _loadCheckpoints(_char);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }


  void _loadCheckpoints(String char) {
    // Hardcode dari seeder (sama dengan yang di database)
    // Sebaiknya nanti dipanggil dari API
    final Map<String, List<Map<String, double>>> checkpointMap = {
      'ꦲ': [
        {'x' : 0.34, 'y' : 0.53}, 
        {'x' : 0.34, 'y' : 0.30}, 
        {'x' : 0.42, 'y' : 0.30}, 
        {'x' : 0.47, 'y' : 0.53}, 
        {'x' : 0.52, 'y' : 0.30}, 
        {'x' : 0.60, 'y' : 0.53}, 
        {'x' : 0.59, 'y' : 0.30},
        {'x' : 0.68, 'y' : 0.30},
        {'x' : 0.68, 'y' : 0.53},
      ],
      'ꦤ': [
        {'x': 0.25, 'y': 0.40},
        {'x': 0.40, 'y': 0.20},
        {'x': 0.60, 'y': 0.25},
        {'x': 0.80, 'y': 0.45},
        {'x': 0.70, 'y': 0.65},
        {'x': 0.45, 'y': 0.75},
        {'x': 0.25, 'y': 0.60},
      ],
      'ꦕ': [
        {'x': 0.25, 'y': 0.30},
        {'x': 0.45, 'y': 0.20},
        {'x': 0.70, 'y': 0.25},
        {'x': 0.85, 'y': 0.50},
        {'x': 0.70, 'y': 0.70},
        {'x': 0.40, 'y': 0.75},
        {'x': 0.20, 'y': 0.55},
      ],
      'ꦫ': [
        {'x': 0.25, 'y': 0.35},
        {'x': 0.45, 'y': 0.20},
        {'x': 0.70, 'y': 0.30},
        {'x': 0.80, 'y': 0.55},
        {'x': 0.55, 'y': 0.70},
        {'x': 0.30, 'y': 0.60},
        {'x': 0.15, 'y': 0.45},
      ],
      'ꦏ': [
        {'x': 0.20, 'y': 0.30},
        {'x': 0.40, 'y': 0.18},
        {'x': 0.65, 'y': 0.25},
        {'x': 0.80, 'y': 0.45},
        {'x': 0.60, 'y': 0.65},
        {'x': 0.35, 'y': 0.72},
        {'x': 0.20, 'y': 0.55},
      ],
    };
    _checkpoints = checkpointMap[char] ?? [];
  }

  // ─── Aksi ──────────────────────────────────────────────────────────────────
  void _clear() {
    _model.clear();
    if (_completed) setState(() => _completed = false);
    _instantScore = 0;
    _instantPassed = false;
  }

  void _done() {
    // Ambil semua stroke raw
    final rawStrokes = _model.getAllStrokes();

    // --- MULAI DEBUGGING ---
    // debugPrint('\n=== 🛑 DEBUG AKSARA TRACING 🛑 ===');
    // debugPrint('1. Jumlah Goresan (Strokes) terekam: ${rawStrokes.length}');
    // if (rawStrokes.isNotEmpty) {
    //   debugPrint('   Titik koordinat pada goresan pertama: ${rawStrokes.first.length}');
    // }
    // debugPrint('2. Ukuran Canvas Terdeteksi: Width = $_canvasWidth, Height = $_canvasHeight');
    // --- AKHIR DEBUGGING ---

    // Normalisasi ke 0..1
    final normalizedStrokes = rawStrokes.map((stroke) {
      return stroke.map((point) {
        return {
          'x': _canvasWidth > 0 ? point.dx / _canvasWidth : 0.0,
          'y': _canvasHeight > 0 ? point.dy / _canvasHeight : 0.0,
        };
      }).toList();
    }).toList();

    // --- MULAI DEBUGGING ---
    // debugPrint('3. Hasil Normalisasi:');
    // try {
    //   // Kita coba encode ke string untuk memastikan struktur JSON-nya valid
    //   final jsonTest = jsonEncode(normalizedStrokes);
    //   debugPrint('   ✅ Berhasil di-encode ke JSON!');
    //   debugPrint('   Preview data: ${jsonTest.substring(0, jsonTest.length > 100 ? 100 : jsonTest.length)}...'); 
    // } catch (e) {
    //   debugPrint('   ❌ ERROR SAAT ENCODE JSON: $e');
    // }
    // debugPrint('====================================\n');
    // --- AKHIR DEBUGGING ---

    // Kirim payload ke parent
    widget.onAnswerChanged(AnswerPayload(
      questionId: widget.question.id,
      strokePoints: normalizedStrokes,
    ));

    setState(() => _completed = true);
  }

  // Validasi instan (client-side) – optional, untuk feedback
  void _validateInstantly() {
    // Implementasi sederhana: cek checkpoint dengan logika yang sama seperti server
    // Namun untuk MVP kita bisa lewati, atau tampilkan progress bar.
    // Di sini saya contohkan hanya dengan update status.
    // Untuk benar-benar validasi, kita butuh data checkpoint dari server,
    // bisa di-load via API atau disimpan lokal.
    // Karena ini opsional, kita abaikan atau tampilkan dummy.
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _GuideCard(char: _char, name: _name)),
            const SizedBox(width: 12),
            const Expanded(child: _TipsCard()),
          ],
        ),
        const SizedBox(height: 14),
        _buildCanvas(),
        const SizedBox(height: 12),
        _buildActions(),
      ],
    );
  }

  Widget _buildCanvas() {
    return ListenableBuilder(
      listenable: _model,
      builder: (_, __) {
        return Container(
          // Bungkus dengan AspectRatio agar proporsi kotak (lebar vs tinggi) selalu sama di semua layar HP
          child: AspectRatio(
            aspectRatio: 1.6, // Rasio ideal mendekati ukuran 367.4 x 216.0 Anda (~1.7)
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _completed
                      ? AppColors.successGreen
                      : _model.hasStrokes
                          ? AppColors.primaryOrange.withOpacity(0.5)
                          : AppColors.borderGrey,
                  width: 2,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Ambil ukuran canvas yang sudah dikunci aspek rasionya
                    _canvasWidth = constraints.maxWidth;
                    _canvasHeight = constraints.maxHeight;

                    return Stack(
                      children: [
                        // 1. Grid panduan
                        Positioned.fill(child: CustomPaint(painter: _GridPainter())),

                        // 2. Aksara panduan (Disarankan dibungkus FittedBox agar skalanya terkunci)
                        Center(
                          child: SizedBox(
                            width: _canvasWidth * 0.7, // Batasi area teks hanya memakan 70% lebar kotak
                            height: _canvasHeight * 0.8, // Batasi area teks memakan 80% tinggi kotak
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                _char,
                                style: TextStyle(
                                  color: AppColors.primaryOrange.withOpacity(0.07),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 3. Area gambar & Detektor Sentuhan
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: (d) => _model.addPoint(d.localPosition),
                          onPanUpdate: (d) => _model.addPoint(d.localPosition),
                          onPanEnd: (_) => _model.endStroke(),
                          onPanCancel: () => _model.cancelStroke(),
                          child: RepaintBoundary(
                            child: Stack(
                              children: [
                                // Stroke painter hasil coretan user
                                CustomPaint(
                                  painter: _StrokePainter(model: _model),
                                  size: Size(_canvasWidth, _canvasHeight),
                                ),
                                
                                // Checkpoint overlay (debug mode)
                                if (_debugMode && _checkpoints.isNotEmpty)
                                  CustomPaint(
                                    painter: _CheckpointPainter(
                                      checkpoints: _checkpoints,
                                      canvasWidth: _canvasWidth,
                                      canvasHeight: _canvasHeight,
                                    ),
                                    size: Size(_canvasWidth, _canvasHeight),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // 4. Placeholder teks bantuan info
                        if (!_model.hasStrokes && !_completed)
                          IgnorePointer(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 100), // Dorong ke bawah agar tidak menabrak huruf
                                  Icon(Icons.edit_outlined, size: 28, color: Colors.grey.shade300),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gambar aksara di sini',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // 5. Badge selesai
                        if (_completed)
                          Positioned(
                            top: 10, right: 10,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                    SizedBox(width: 5),
                                    Text('Selesai!', style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  

  Widget _buildActions() {
    return ListenableBuilder(
      listenable: _model,
      builder: (_, __) => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _model.hasStrokes ? _clear : null,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Hapus'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _model.hasStrokes && !_completed ? _done : null,
              icon: Icon(
                _completed ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                size: 18,
              ),
              label: Text(_completed ? 'Sudah Selesai ✓' : 'Selesai Menulis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _completed ? AppColors.successGreen : AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers (ekstrak karakter) ──────────────────────────────────────────
  String _extractChar(String prompt) {
    // 1. Cari aksara Jawa langsung (Unicode range U+AA80–U+AA5F)
    final aksaraRegex = RegExp(r'[\uA980-\uA9DF]+'); // Hanacaraka range
    final match = aksaraRegex.firstMatch(prompt);
    if (match != null) return match.group(0)!;

    // 2. Cari teks dalam tanda kutip setelah kata "aksara" atau "(aksara)"
    final quoteRegex = RegExp(r'aksara\s+"([^"]+)"', caseSensitive: false);
    final quoteMatch = quoteRegex.firstMatch(prompt);
    if (quoteMatch != null) return quoteMatch.group(1)!;

    // 3. Cari teks dalam kurung (misal "(Ha)" atau "(ꦲ)")
    final parenRegex = RegExp(r'\(([^)]+)\)');
    final parenMatch = parenRegex.firstMatch(prompt);
    if (parenMatch != null) {
      // Jika di dalam kurung ada aksara, ambil itu
      final inside = parenMatch.group(1)!;
      final aksaraInside = aksaraRegex.firstMatch(inside);
      if (aksaraInside != null) return aksaraInside.group(0)!;
      return inside; // fallback: ambil teks dalam kurung
    }

    // 4. Cari kata setelah "aksara" (tanpa tanda kutip)
    final kataRegex = RegExp(r'aksara\s+(\w+)', caseSensitive: false);
    final kataMatch = kataRegex.firstMatch(prompt);
    if (kataMatch != null) return kataMatch.group(1)!;

    // 5. Default
    return 'ꦲ';
  }

  String _extractName(String prompt) {
    final m = RegExp(r'"([A-Za-z]{1,10})"').firstMatch(prompt);
    return m?.group(1) ?? 'Aksara';
  }
}

// ─── Painter (sama) ────────────────────────────────────────────────────────
class _StrokePainter extends CustomPainter {
  final _CanvasModel model;
  _StrokePainter({required this.model}) : super(repaint: model);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryOrange
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void drawStrokes(List<Offset> pts) {
      if (pts.isEmpty) return;
      if (pts.length == 1) {
        canvas.drawCircle(pts[0], 3.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        return;
      }
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        if (i < pts.length - 1) {
          final cx = (pts[i].dx + pts[i + 1].dx) / 2;
          final cy = (pts[i].dy + pts[i + 1].dy) / 2;
          path.quadraticBezierTo(pts[i].dx, pts[i].dy, cx, cy);
        } else {
          path.lineTo(pts[i].dx, pts[i].dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    for (final s in model.strokes) drawStrokes(s);
    drawStrokes(model.current);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) => true;
}

class _CheckpointPainter extends CustomPainter {
  final List<Map<String, double>> checkpoints;
  final double canvasWidth;
  final double canvasHeight;

  _CheckpointPainter({
    required this.checkpoints,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final labelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < checkpoints.length; i++) {
      final cp = checkpoints[i];
      final x = cp['x']! * canvasWidth;
      final y = cp['y']! * canvasHeight;

      // Lingkaran checkpoint
      canvas.drawCircle(Offset(x, y), 8, paint);

      // Lingkaran dalam putih
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.white);

      // Nomor urut
      final textSpan = TextSpan(
        text: '${i+1}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width/2, y - textPainter.height/2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CheckpointPainter old) => false;
}

// ─── Grid (sama) ──────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.borderGrey.withOpacity(0.6)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), line);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), line);
    final dot = Paint()..color = AppColors.borderGrey.withOpacity(0.5);
    for (double x = 26; x < size.width; x += 26) {
      for (double y = 26; y < size.height; y += 26) {
        canvas.drawCircle(Offset(x, y), 1.2, dot);
      }
    }
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Guide & Tips (sama) ──────────────────────────────────────────────────
class _GuideCard extends StatelessWidget {
  final String char;
  final String name;
  const _GuideCard({required this.char, required this.name});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(char, style: const TextStyle(fontSize: 52, height: 1.1)),
        const SizedBox(height: 4),
        Text('Aksara "$name"', style: const TextStyle(
          fontFamily: 'Nunito', fontWeight: FontWeight.w700,
          fontSize: 12, color: AppColors.primaryBrown,
        )),
        Text('← Ikuti bentuk ini',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600,
              fontSize: 10, color: Colors.grey.shade500)),
      ],
    ),
  );
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.xpBlue.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.xpBlue.withOpacity(0.2), width: 1.5),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Tips:', style: TextStyle(
          fontFamily: 'Nunito', fontWeight: FontWeight.w800,
          fontSize: 12, color: AppColors.xpBlueDark,
        )),
        SizedBox(height: 6),
        _Tip('✏️', 'Sentuh & geser di kotak'),
        _Tip('⬆️', 'Mulai dari atas'),
        _Tip('📱', 'Gunakan ujung jari'),
        _Tip('🔄', 'Salah? Tap Hapus'),
        _Tip('↕️', 'Scroll di luar kotak'),
      ],
    ),
  );
}

class _Tip extends StatelessWidget {
  final String emoji;
  final String text;
  const _Tip(this.emoji, this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 11)),
      const SizedBox(width: 4),
      Expanded(child: Text(text, style: const TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w600,
        fontSize: 11, color: AppColors.xpBlueDark,
      ))),
    ]),
  );
}
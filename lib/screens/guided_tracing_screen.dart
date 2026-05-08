import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/ink_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import '../widgets/mission_progress_bar.dart';

class GuidedTracingScreen extends StatefulWidget {
  final String letter;

  const GuidedTracingScreen({
    required this.letter,
    super.key,
  });

  @override
  State<GuidedTracingScreen> createState() => _GuidedTracingScreenState();
}

class _GuidedTracingScreenState extends State<GuidedTracingScreen> {
  final GlobalKey _paintKey = GlobalKey();

  final InkService _inkService = InkService();
  final TtsService _ttsService = TtsService();

  final List<List<Offset>> _strokes = [];
  final ValueNotifier<int> _repaintNotifier = ValueNotifier<int>(0);

  bool _hasDrawn = false;
  bool _isChecking = false;
  String _feedback = '';

  void _startStroke(DragStartDetails details) {
    final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(details.globalPosition);

    _strokes.add([localPosition]);

    if (!_hasDrawn) {
      setState(() {
        _hasDrawn = true;
      });
    }

    _repaintNotifier.value++;
  }

  void _updateStroke(DragUpdateDetails details) {
    final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || _strokes.isEmpty) return;

    final localPosition = box.globalToLocal(details.globalPosition);

    _strokes.last.add(localPosition);

    // Pas de setState ici pour garder le dessin rapide.
    _repaintNotifier.value++;
  }

  void _clearCanvas() {
    _strokes.clear();

    setState(() {
      _hasDrawn = false;
      _feedback = '';
    });

    _repaintNotifier.value++;
  }

  Future<void> _checkGuidedDrawing() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suis d’abord la lettre avec ton doigt ! ✏️'),
        ),
      );
      return;
    }

    setState(() {
      _isChecking = true;
      _feedback = '';
    });

    try {
      await Future.delayed(Duration.zero);

      final recognized = await _inkService.recognizeLetter(_strokes);

      final isCorrect = recognized.isNotEmpty &&
          recognized.toUpperCase() == widget.letter.toUpperCase();

      if (!mounted) return;

      setState(() {
        _feedback = isCorrect
            ? '🎉 Super ! Tu as bien suivi la lettre ${widget.letter}'
            : "😊 Réessaie ! c'est la lettre $recognized";
        _isChecking = false;
      });

      if (isCorrect) {
        await _ttsService.speakHappy(
          'Bravo !. Maintenant, essaie tout seul.',
        );

        Future.delayed(
          const Duration(milliseconds: 900),
          () {
            if (mounted) {
              context.push('/tracing/${widget.letter}');
            }
          },
        );
      } else {
        await _ttsService.speakSlow(
          'Réessaie ! Suis bien la forme de la lettre ',
        );
      }
    } catch (e) {
      debugPrint('Guided tracing error: $e');

      if (!mounted) return;

      setState(() {
        _isChecking = false;
        _feedback = 'Erreur de vérification. Réessaie.';
      });
    }
  }

  void _continueWithoutChecking() {
    context.push('/tracing/${widget.letter}');
  }

  @override
  void dispose() {
    _ttsService.stop();
    _repaintNotifier.dispose();

    // Attention : InkService est singleton dans ton code.
    // Si tu fais dispose ici, il peut fermer le recognizer utilisé ailleurs.
    // Donc on ne fait pas _inkService.dispose() ici.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guide lettre ${widget.letter}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const MissionProgressBar(currentStep: 0),
            const SizedBox(height: 16),
            Text(
              'Suis la lettre avec ton doigt',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RepaintBoundary(
                child: Container(
                  key: _paintKey,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorders.radius),
                    border: Border.all(
                      color: AppColors.magicPurple,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: _startStroke,
                    onPanUpdate: _updateStroke,
                    child: CustomPaint(
                      painter: FastGuidedLetterPainter(
                        letter: widget.letter,
                        strokes: _strokes,
                        repaint: _repaintNotifier,

                        // false = grande lettre légère
                        // true = pointillés pour A, B, C
                        useDottedGuide: false,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AnimatedOpacity(
              opacity: _feedback.isEmpty ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: Text(
                _feedback,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _feedback.startsWith('🎉')
                          ? AppColors.successGreen
                          : AppColors.softRed,
                    ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isChecking ? null : _clearCanvas,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Effacer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        !_hasDrawn || _isChecking ? null : _checkGuidedDrawing,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isChecking ? 'Vérifie...' : 'Vérifier'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _isChecking ? null : _continueWithoutChecking,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Passer et essayer seul'),
            ),
          ],
        ),
      ),
    );
  }
}

class FastGuidedLetterPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final bool useDottedGuide;

  FastGuidedLetterPainter({
    required this.letter,
    required this.strokes,
    required this.useDottedGuide,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (useDottedGuide) {
      _drawDottedGuide(canvas, size);
    } else {
      _drawSoftLetterGuide(canvas, size);
    }

    _drawUserStrokes(canvas);
  }

  void _drawSoftLetterGuide(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter.toUpperCase(),
        style: TextStyle(
          fontSize: size.height * 0.62,
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.08),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  void _drawUserStrokes(Canvas canvas) {
    final drawPaint = Paint()
      ..color = AppColors.successGreen
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, drawPaint);
    }
  }

  void _drawDottedGuide(Canvas canvas, Size size) {
    final dottedPaint = Paint()
      ..color = AppColors.magicPurple.withOpacity(0.55)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final top = size.height * 0.18;
    final bottom = size.height * 0.82;
    final left = size.width * 0.32;
    final right = size.width * 0.68;
    final middle = size.height * 0.52;

    switch (letter.toUpperCase()) {
      case 'A':
        _drawDottedLine(
          canvas,
          Offset(centerX, top),
          Offset(left, bottom),
          dottedPaint,
        );
        _drawDottedLine(
          canvas,
          Offset(centerX, top),
          Offset(right, bottom),
          dottedPaint,
        );
        _drawDottedLine(
          canvas,
          Offset(left + 35, middle),
          Offset(right - 35, middle),
          dottedPaint,
        );
        break;

      case 'B':
        _drawDottedLine(
          canvas,
          Offset(left, top),
          Offset(left, bottom),
          dottedPaint,
        );

        _drawDottedArc(
          canvas,
          Rect.fromLTWH(
            left - 5,
            top,
            size.width * 0.40,
            size.height * 0.32,
          ),
          -1.57,
          3.14,
          dottedPaint,
        );

        _drawDottedArc(
          canvas,
          Rect.fromLTWH(
            left - 5,
            middle - 10,
            size.width * 0.42,
            size.height * 0.34,
          ),
          -1.57,
          3.14,
          dottedPaint,
        );
        break;

      case 'C':
        _drawDottedArc(
          canvas,
          Rect.fromCenter(
            center: Offset(centerX, size.height / 2),
            width: size.width * 0.48,
            height: size.height * 0.62,
          ),
          0.7,
          4.9,
          dottedPaint,
        );
        break;

      default:
        _drawSoftLetterGuide(canvas, size);
    }
  }

  void _drawDottedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashLength = 8;
    const double gapLength = 12;

    final distance = (end - start).distance;
    if (distance == 0) return;

    final direction = (end - start) / distance;

    double currentDistance = 0;

    while (currentDistance < distance) {
      final dashStart = start + direction * currentDistance;

      final dashEndDistance =
          (currentDistance + dashLength).clamp(0, distance).toDouble();

      final dashEnd = start + direction * dashEndDistance;

      canvas.drawLine(dashStart, dashEnd, paint);

      currentDistance += dashLength + gapLength;
    }
  }

  void _drawDottedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweepAngle,
    Paint paint,
  ) {
    const int segments = 32;

    for (int i = 0; i < segments; i += 2) {
      final segmentStart = startAngle + sweepAngle * (i / segments);
      final segmentSweep = sweepAngle / segments;

      canvas.drawArc(
        rect,
        segmentStart,
        segmentSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FastGuidedLetterPainter oldDelegate) {
    return oldDelegate.letter != letter ||
        oldDelegate.useDottedGuide != useDottedGuide;
  }
}

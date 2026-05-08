// Écran tracé lettre : dessiner avec le doigt
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/ink_service.dart';
import '../services/tts_service.dart';
import '../providers/mission_provider.dart';
import '../widgets/ink_canvas.dart';
import '../widgets/mission_progress_bar.dart';

class TracingScreen extends StatefulWidget {
  final String letter;

  const TracingScreen({required this.letter, super.key});

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  final _inkService = InkService();
  final _ttsService = TtsService();
  final _canvasKey = GlobalKey();
  String _feedback = '';
  bool _isChecking = false;

// Dans _TracingScreenState, remplacer _checkDrawing par :
  Future<void> _checkDrawing() async {
    final state = _canvasKey.currentState as dynamic;
    if (state == null) return;

    final strokes = state.strokes as List;
    if (strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dessine d\'abord la lettre ! ✏️')),
      );
      return;
    }

    setState(() => _isChecking = true);

    try {
      // Attendre init si pas encore prêt
      await Future.delayed(Duration.zero);

      final recognized = await _inkService.recognizeLetter(strokes);
      final isCorrect = recognized.isNotEmpty &&
          recognized.toUpperCase() == widget.letter.toUpperCase();

      if (!mounted) return;
      setState(() {
        _feedback = isCorrect ? '🎉 Bravo !' : '😊 Réessaie ! ($recognized)';
        _isChecking = false;
      });

      if (isCorrect) {
        await _ttsService.speakHappy('Bravo !');
        context.read<MissionProvider>().nextStep();
        Future.delayed(
          const Duration(milliseconds: 800),
          () {
            if (mounted) context.push('/scanner/${widget.letter}');
          },
        );
      } else {
        await _ttsService.speakSlow('Réessaie ! ');
      }
    } catch (e) {
      if (mounted) setState(() => _isChecking = false);
      debugPrint('Tracing error: $e');
    }
  }

  @override
  void dispose() {
    _inkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trace la lettre ${widget.letter}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const MissionProgressBar(currentStep: 0),
            const SizedBox(height: 16),
            Hero(
              tag: 'letter-today',
              child: Text(
                widget.letter,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Trace sur la zone blanche',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: InkCanvas(
                key: _canvasKey,
                onStrokesChanged: (_) {},
                letterLabel: widget.letter,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _feedback.isEmpty ? 0 : 1,
              duration: const Duration(milliseconds: 400),
              child: Text(
                _feedback,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      (_canvasKey.currentState as dynamic).clearCanvas(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Effacer'),
                ),
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkDrawing,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Vérifier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

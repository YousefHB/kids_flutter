import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/mission_progress_bar.dart';

class ScannerScreen extends StatefulWidget {
  final String letter;
  const ScannerScreen({required this.letter, super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _camera;
  final _recognizer = TextRecognizer();
  bool _isScanning = false;
  List<String> _foundWords = [];
  String? _selectedWord;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _camera = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _camera!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureAndScan() async {
    if (_camera == null || _isScanning) return;
    setState(() => _isScanning = true);

    try {
      final file = await _camera!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final result = await _recognizer.processImage(inputImage);

      // 1. Extraire TOUS les mots du texte pour créer un petit jeu
      final allWords = result.text
          .replaceAll(RegExp(r'[.,!?;:()]'), ' ')
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2) // Mots d'au moins 3 lettres
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-ZàâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ]'), ''))
          .where((w) => w.isNotEmpty)
          .toSet()
          .toList();

      // 2. Préparer les mots pour la page suivante
      // On garde tous les mots d'au moins 3 lettres
      final validWords = allWords.where((w) => w.length >= 3).toList();

      setState(() {
        _isScanning = false;
      });

      if (validWords.isNotEmpty) {
        // Navigation directe vers la page de sélection de mots
        context.push(
          '/words/${widget.letter}',
          extra: validWords,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.softRed,
            content: Text(
              'Oh non ! Je n\'ai pas trouvé de texte lisible. Réessaie ! 📚',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isScanning = false);
      debugPrint('Scan error: $e');
    }
  }

  // L'ancienne méthode _showWordGameSheet est supprimée car on utilise une page dédiée


  @override
  void dispose() {
    _camera?.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📷 Cherche la lettre ${widget.letter}')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: MissionProgressBar(currentStep: 1),
          ),
          Expanded(
            child: _camera == null || !_camera!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_camera!),
                      // Overlay guidant l'enfant
                      Positioned(
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Pointe vers un texte contenant ${widget.letter}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _captureAndScan,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2))
                      : const Icon(Icons.camera_alt),
                  label: Text(_isScanning ? 'Scan...' : 'Scanner'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/object-hunt/${widget.letter}'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Passer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

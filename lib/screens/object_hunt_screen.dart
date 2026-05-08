import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../services/object_detection_service.dart';
import '../services/progression_service.dart';
import '../theme.dart';
import '../widgets/mission_progress_bar.dart';
import '../widgets/mascot_message.dart';
import '../widgets/child_button.dart';

class ObjectHuntScreen extends StatefulWidget {
  final String letter;
  final String? selectedWord;

  const ObjectHuntScreen({
    required this.letter,
    this.selectedWord,
    super.key,
  });

  @override
  State<ObjectHuntScreen> createState() => _ObjectHuntScreenState();
}

class _ObjectHuntScreenState extends State<ObjectHuntScreen> {
  CameraController? _cameraController;
  final ObjectDetectionService _detectionService = ObjectDetectionService();

  bool _isLoadingCamera = true;
  bool _isDetecting = false;
  bool _objectFound = false;

  String _message = '';
  String? _foundEnglishLabel;
  String? _foundFrenchLabel;

  List<String> _detectedFrenchLabels = [];

  List<String> get _targetLabels {
    final letter = widget.letter.toUpperCase();
    return OBJECT_LABELS_BY_LETTER[letter] ?? <String>[];
  }

  @override
  void initState() {
    super.initState();
    _message = 'Cherche un objet qui commence par ${widget.letter}';
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _isLoadingCamera = false;
          _message = 'Aucune caméra trouvée.';
        });
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high, // Résolution plus haute pour mieux voir les détails
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isLoadingCamera = false;
      });
    } catch (e) {
      debugPrint('Camera error: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingCamera = false;
        _message = 'Erreur caméra. Vérifie les permissions.';
      });
    }
  }

  Future<void> _detectObjects() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isDetecting) {
      return;
    }

    setState(() {
      _isDetecting = true;
      _objectFound = false;
      _foundEnglishLabel = null;
      _foundFrenchLabel = null;
      _detectedFrenchLabels = [];
      _message = 'Je regarde ce que c’est... 🧐';
    });

    try {
      final image = await _cameraController!.takePicture();

      // Utilisation du nouveau service basé sur ImageLabeler
      final labels = await _detectionService.detectObjects(image.path);
      
      final frenchLabels = labels.map((l) {
        final lower = l.label.toLowerCase();
        return OBJECT_LABELS_FR[lower] ?? lower;
      }).toList();

      String? matchedEnglish;
      String? matchedFrench;

      // Logique de validation PLUS LARGE sur la lettre initiale en FRANÇAIS
      // On vérifie tous les labels trouvés, pas seulement le premier
      for (final label in labels) {
        final english = label.label.toLowerCase();
        
        // On vérifie si ce label anglais a une traduction en français
        final french = OBJECT_LABELS_FR[english];
        
        if (french != null && french.toLowerCase().startsWith(widget.letter.toLowerCase())) {
          matchedEnglish = english;
          matchedFrench = french;
          break; // Trouvé !
        }
        
        // Si pas de traduction, on vérifie le label lui-même au cas où il est déjà en français ou universel
        if (english.startsWith(widget.letter.toLowerCase())) {
          matchedEnglish = english;
          matchedFrench = english;
          break;
        }
      }

      setState(() {
        _detectedFrenchLabels = frenchLabels;

        if (matchedFrench != null) {
          _objectFound = true;
          _foundEnglishLabel = matchedEnglish;
          _foundFrenchLabel = matchedFrench;
          _message =
              'Bravo ! J’ai reconnu : $matchedFrench.\nÇa commence bien par "${widget.letter.toUpperCase()}" ! 🎉';
        } else if (frenchLabels.isNotEmpty) {
          // On liste les 3 premiers objets vus pour aider l'enfant
          final saw = frenchLabels.take(3).toSet().join(', ');
          _message =
              'J’ai vu : $saw.\nMais aucun ne commence par "${widget.letter.toUpperCase()}". Réessaie ! 🔎';
        } else {
          _message = 'Je n’ai pas bien reconnu d’objet. Rapproche-toi un peu !';
        }

        _isDetecting = false;
      });

      if (_objectFound) {
        // Ajouter à la collection d'autocollants
        ProgressionService.collectSticker(matchedFrench!);
        
        // On ne redirige plus automatiquement pour laisser l'enfant apprécier sa découverte
      }
    } catch (e) {
      debugPrint('Object detection error: $e');
      if (!mounted) return;
      setState(() {
        _isDetecting = false;
        _message = 'Oups ! Une erreur est survenue. Réessaie.';
      });
    }
  }

  void _skip() {
    context.push('/reward/${widget.letter}');
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔎 Objet lettre ${widget.letter}'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: MissionProgressBar(currentStep: 3),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MascotMessage(
              message: _message,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorders.radius),
                child: Container(
                  color: Colors.black12,
                  child: _buildCameraPreview(),
                ),
              ),
            ),
          ),
          if (_detectedFrenchLabels.isNotEmpty && !_objectFound)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _detectedFrenchLabels.take(5).map((label) {
                  return Chip(
                    label: Text(label),
                    backgroundColor: AppColors.brightYellow.withOpacity(0.7),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _objectFound 
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/reward/${widget.letter}'),
                    icon: const Icon(Icons.card_giftcard_rounded, size: 28),
                    label: const Text('C\'EST GAGNÉ ! 🎁'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDetecting ? null : _skip,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Passer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDetecting ? null : _detectObjects,
                        icon: _isDetecting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Icon(Icons.camera_alt_rounded),
                        label: Text(_isDetecting ? 'IA...' : 'Détecter'),
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isLoadingCamera) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Caméra indisponible.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Place l’objet au centre de l’écran',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(
                color: _objectFound
                    ? AppColors.successGreen
                    : AppColors.brightYellow,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        if (_foundFrenchLabel != null)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '🎉 C’est ${_foundFrenchLabel!} !',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

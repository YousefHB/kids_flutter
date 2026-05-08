import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../services/souvenir_service.dart';
import '../services/progression_service.dart';
import '../theme.dart';

class SouvenirCameraScreen extends StatefulWidget {
  final String letter;

  const SouvenirCameraScreen({
    required this.letter,
    super.key,
  });

  @override
  State<SouvenirCameraScreen> createState() => _SouvenirCameraScreenState();
}

enum SouvenirFilterType {
  royalty,
  explorer,
  magic,
  animals,
  party,
  butterfly,
}

class _SouvenirCameraScreenState extends State<SouvenirCameraScreen> {
  final GlobalKey _captureKey = GlobalKey();

  CameraController? _cameraController;
  late final FaceDetector _faceDetector;

  bool _isLoadingCamera = true;
  bool _isProcessing = false;
  bool _isSaving = false;

  File? _capturedImage;
  ui.Image? _decodedImage;
  List<Face> _faces = [];
  
  SouvenirFilterType _selectedFilter = SouvenirFilterType.royalty;

  String _message = 'Choisis ton filtre et souris ! 😊';

  @override
  void initState() {
    super.initState();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    _initSelfieCamera();
  }

  Future<void> _initSelfieCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _isLoadingCamera = false;
          _message = 'Aucune caméra trouvée.';
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isLoadingCamera = false;
      });
    } catch (e) {
      debugPrint('Selfie camera error: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingCamera = false;
        _message = 'Erreur caméra. Vérifie les permissions.';
      });
    }
  }

  Future<void> _takeSelfieAndDetectFace() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _message = 'Préparation du souvenir...';
    });

    try {
      final picture = await _cameraController!.takePicture();
      final imageFile = File(picture.path);

      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      final bytes = await imageFile.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);

      if (!mounted) return;

      setState(() {
        _capturedImage = imageFile;
        _decodedImage = decodedImage;
        _faces = faces;
        _isProcessing = false;

        if (faces.isEmpty) {
          _message = 'Je ne vois pas bien le visage. Tu peux réessayer.';
        } else {
          _message = 'Super ! Voici ton souvenir lettre ${widget.letter} 🎉';
        }
      });
    } catch (e) {
      debugPrint('Take selfie error: $e');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _message = 'Erreur pendant la photo. Réessaie.';
      });
    }
  }

  Future<void> _saveFilteredSouvenir() async {
    if (_capturedImage == null || _isSaving) return;

    setState(() {
      _isSaving = true;
      _message = 'Sauvegarde du souvenir...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 250));

      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      await SouvenirService.saveSouvenir(
        letter: widget.letter,
        imageBytes: pngBytes,
      );

      // Débloquer le niveau suivant (A -> B, etc.)
      await ProgressionService.unlockNextLevel(widget.letter);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _message = 'Souvenir sauvegardé ✅';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo souvenir sauvegardée ✅'),
        ),
      );

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          context.go('/home');
        }
      });
    } catch (e) {
      debugPrint('Save souvenir error: $e');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _message = 'Erreur de sauvegarde.';
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _decodedImage = null;
      _faces = [];
      _message = 'Place ton visage dans le cadre 😊';
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _capturedImage != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('📸 Souvenir lettre ${widget.letter}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorders.radius),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorders.radius),
                child: Container(
                  color: Colors.black12,
                  child: hasPhoto ? _buildResultPhoto() : _buildCameraPreview(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: hasPhoto ? _buildResultButtons() : _buildCameraButtons(),
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
        child: Text(
          'Caméra indisponible.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        // Guide de visage
        Center(
          child: Container(
            width: 240,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.brightYellow.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(120),
            ),
          ),
        ),
        // Filtre prévisualisé (statique)
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              _getFilterMainEmoji(_selectedFilter),
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
        // Sélecteur de filtres
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _buildFilterSelector(),
        ),
      ],
    );
  }

  Widget _buildFilterSelector() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: SouvenirFilterType.values.length,
        itemBuilder: (context, index) {
          final type = SouvenirFilterType.values[index];
          final isSelected = _selectedFilter == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brightYellow : Colors.white70,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.magicPurple : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.magicPurple.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  _getFilterMainEmoji(type),
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFilterMainEmoji(SouvenirFilterType type) {
    switch (type) {
      case SouvenirFilterType.royalty: return '👑';
      case SouvenirFilterType.explorer: return '🎩';
      case SouvenirFilterType.magic: return '🧙';
      case SouvenirFilterType.animals: return '🐱';
      case SouvenirFilterType.party: return '🥳';
      case SouvenirFilterType.butterfly: return '🦋';
    }
  }

  Widget _buildResultPhoto() {
    if (_capturedImage == null || _decodedImage == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    return RepaintBoundary(
      key: _captureKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _capturedImage!,
            fit: BoxFit.contain,
          ),
          CustomPaint(
            painter: SouvenirFilterPainter(
              letter: widget.letter,
              faces: _faces,
              filterType: _selectedFilter,
              imageSize: Size(
                _decodedImage!.width.toDouble(),
                _decodedImage!.height.toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : () => context.go('/home'),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Plus tard'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _takeSelfieAndDetectFace,
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.camera_alt_rounded),
            label: Text(_isProcessing ? 'Photo...' : 'Sourire !'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : _retakePhoto,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refaire'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveFilteredSouvenir,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_isSaving ? 'Sauvegarde...' : 'Sauver'),
          ),
        ),
      ],
    );
  }
}

class SouvenirFilterPainter extends CustomPainter {
  final String letter;
  final List<Face> faces;
  final SouvenirFilterType filterType;
  final Size imageSize;

  SouvenirFilterPainter({
    required this.letter,
    required this.faces,
    required this.filterType,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawDecorations(canvas, size);
    _drawLetterBadge(canvas, size);

    if (faces.isEmpty) {
      _drawCenteredFilter(canvas, size);
      return;
    }

    for (final face in faces) {
      _drawFaceFilter(canvas, size, face);
    }
  }

  void _drawDecorations(Canvas canvas, Size size) {
    final emojis = _getFilterDecorations(filterType);
    _drawText(canvas, text: emojis[0], center: const Offset(45, 60), fontSize: 35);
    _drawText(canvas, text: emojis[1], center: Offset(size.width - 45, 90), fontSize: 40);
    _drawText(canvas, text: emojis[2], center: Offset(size.width - 80, size.height - 150), fontSize: 35);
    _drawText(canvas, text: emojis[3], center: Offset(60, size.height - 180), fontSize: 30);
  }

  List<String> _getFilterDecorations(SouvenirFilterType type) {
    switch (type) {
      case SouvenirFilterType.royalty: return ['⭐', '💎', '🏰', '✨'];
      case SouvenirFilterType.explorer: return ['🔍', '🗺️', '🧭', '🌳'];
      case SouvenirFilterType.magic: return ['✨', '🪄', '🌙', '🔮'];
      case SouvenirFilterType.animals: return ['🐾', '🦴', '🥕', '🎈'];
      case SouvenirFilterType.party: return ['🎈', '🎉', '🎁', '🍰'];
      case SouvenirFilterType.butterfly: return ['🌸', '✨', '🌷', '🌈'];
    }
  }

  void _drawFaceFilter(Canvas canvas, Size canvasSize, Face face) {
    final mappedFace = _mapRectToCanvas(face.boundingBox, imageSize, canvasSize);
    
    // Émoji principal sur la tête
    final mainEmojiCenter = Offset(
      mappedFace.center.dx,
      mappedFace.top - mappedFace.height * 0.2,
    );

    _drawText(
      canvas,
      text: _getFilterMainEmoji(filterType),
      center: mainEmojiCenter,
      fontSize: mappedFace.width * 0.45,
    );

    // Émojis secondaires (joues ou côtés)
    final secondary = _getFilterSecondaryEmojis(filterType);
    _drawText(
      canvas,
      text: secondary[0],
      center: Offset(mappedFace.left - 20, mappedFace.top + 30),
      fontSize: 32,
    );
    _drawText(
      canvas,
      text: secondary[1],
      center: Offset(mappedFace.right + 20, mappedFace.top + 50),
      fontSize: 30,
    );
  }

  String _getFilterMainEmoji(SouvenirFilterType type) {
    switch (type) {
      case SouvenirFilterType.royalty: return '👑';
      case SouvenirFilterType.explorer: return '🎩';
      case SouvenirFilterType.magic: return '🧙';
      case SouvenirFilterType.animals: return '🐱';
      case SouvenirFilterType.party: return '🥳';
      case SouvenirFilterType.butterfly: return '🦋';
    }
  }

  List<String> _getFilterSecondaryEmojis(SouvenirFilterType type) {
    switch (type) {
      case SouvenirFilterType.royalty: return ['💎', '✨'];
      case SouvenirFilterType.explorer: return ['🔍', '🧭'];
      case SouvenirFilterType.magic: return ['🪄', '🌙'];
      case SouvenirFilterType.animals: return ['🐾', '🎈'];
      case SouvenirFilterType.party: return ['🎉', '🎈'];
      case SouvenirFilterType.butterfly: return ['🌸', '✨'];
    }
  }

  void _drawCenteredFilter(Canvas canvas, Size size) {
    _drawText(
      canvas,
      text: _getFilterMainEmoji(filterType),
      center: Offset(size.width / 2, 120),
      fontSize: 70,
    );
  }

  void _drawLetterBadge(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(30, size.height - 100, size.width - 60, 70),
      const Radius.circular(35),
    );

    final paint = Paint()..color = AppColors.brightYellow.withOpacity(0.95);
    canvas.drawRRect(rect, paint);

    _drawText(
      canvas,
      text: 'J’ai appris la lettre $letter !',
      center: Offset(size.width / 2, size.height - 65),
      fontSize: 26,
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    );
  }

  Rect _mapRectToCanvas(Rect imageRect, Size sourceImageSize, Size canvasSize) {
    final scaleX = canvasSize.width / sourceImageSize.width;
    final scaleY = canvasSize.height / sourceImageSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final displayedWidth = sourceImageSize.width * scale;
    final displayedHeight = sourceImageSize.height * scale;
    final dx = (canvasSize.width - displayedWidth) / 2;
    final dy = (canvasSize.height - displayedHeight) / 2;
    return Rect.fromLTRB(
      imageRect.left * scale + dx,
      imageRect.top * scale + dy,
      imageRect.right * scale + dx,
      imageRect.bottom * scale + dy,
    );
  }

  void _drawText(Canvas canvas, {required String text, required Offset center, required double fontSize, Color color = Colors.black, FontWeight fontWeight = FontWeight.normal}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight)),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy - painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant SouvenirFilterPainter oldDelegate) {
    return oldDelegate.letter != letter || oldDelegate.faces != faces || oldDelegate.filterType != filterType || oldDelegate.imageSize != imageSize;
  }
}

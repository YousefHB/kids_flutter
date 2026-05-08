// Widget : zone de dessin pour tracer les lettres
import 'package:flutter/material.dart';
import '../theme.dart';

class InkCanvas extends StatefulWidget {
  final Function(List<dynamic>) onStrokesChanged;
  final String letterLabel;

  const InkCanvas({
    required this.onStrokesChanged,
    this.letterLabel = '',
    super.key,
  });

  @override
  State<InkCanvas> createState() => _InkCanvasState();
}

class _InkCanvasState extends State<InkCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  // Notifier au lieu de setState → seul le CustomPaint se repaint
  final _repaint = ValueNotifier<int>(0);

  List<List<Offset>> get strokes => _strokes;

  void _onPanStart(DragStartDetails details) {
    _currentStroke = [details.localPosition];
    _repaint.value++;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final pos = details.localPosition;
    // Filtre distance : évite les points trop proches
    if (_currentStroke.isEmpty || (_currentStroke.last - pos).distance > 4) {
      _currentStroke.add(pos);
      _repaint.value++; // Pas de setState → pas de rebuild du widget
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke.isNotEmpty) {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
      widget.onStrokesChanged(_strokes);
      _repaint.value++;
    }
  }

  void clearCanvas() {
    _strokes.clear();
    _currentStroke.clear();
    _repaint.value++;
    widget.onStrokesChanged(_strokes);
  }

  @override
  void dispose() {
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ce Container ne rebuild PLUS à chaque point
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorders.radius),
        border: Border.all(
          color: AppColors.magicPurple.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorders.radius - 3),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: RepaintBoundary(
            // Isole le canvas du reste de l'arbre widget
            child: CustomPaint(
              painter: _CanvasPainter(
                strokes: _strokes,
                currentStroke: _currentStroke,
                repaint: _repaint,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _CanvasPainter({
    required this.strokes,
    required this.currentStroke,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.magicPurple
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) {
      // Point isolé → petit cercle
      canvas.drawCircle(points.first, 3, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
      return;
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => false;
  // shouldRepaint inutile : le Listenable gère les repaints directement
}

import 'package:flutter/material.dart';

class ChildButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLarge;

  const ChildButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.isLarge = true,
  });

  @override
  State<ChildButton> createState() => _ChildButtonState();
}

class _ChildButtonState extends State<ChildButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isLarge ? 24 : 16,
            vertical: widget.isLarge ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? const Color(0xFFFFD93D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.1), width: 2),
            boxShadow: [
              BoxShadow(
                color: (widget.backgroundColor ?? const Color(0xFFFFD93D)).withOpacity(0.4),
                blurRadius: 0,
                offset: const Offset(0, 4), // Effet 3D réduit
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: widget.foregroundColor ?? Colors.black87,
              fontSize: widget.isLarge ? 18 : 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

class PageAtmosphere extends StatelessWidget {
  const PageAtmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8F5FF), Color(0xFFEFF4FF), Color(0xFFF8FBFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const _GlowBubble(
          alignment: Alignment(-1.15, -1.1),
          size: 280,
          color: Color(0x66C7B4FF),
        ),
        const _GlowBubble(
          alignment: Alignment(1.2, -0.9),
          size: 220,
          color: Color(0x66A7D7FF),
        ),
        const _GlowBubble(
          alignment: Alignment(1.1, 1.15),
          size: 260,
          color: Color(0x4DD7C9FF),
        ),
        child,
      ],
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

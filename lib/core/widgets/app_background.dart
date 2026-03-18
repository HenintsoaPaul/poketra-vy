import 'dart:ui';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dark deep background
      decoration: const BoxDecoration(
        color: Color(0xFF0B0E14),
      ),
      child: Stack(
        children: [
          // Purple glow circle top right
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7B2CBF).withValues(alpha: 0.4),
              ),
            ),
          ),
          // Deep Blue glow circle bottom left
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0077B6).withValues(alpha: 0.3),
              ),
            ),
          ),
          // Cyan glow circle bottom right
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
              ),
            ),
          ),
          // Backdrop filter to blur the circles smoothly
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Actual content on top
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

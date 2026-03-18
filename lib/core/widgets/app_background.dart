import 'dart:ui';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Light fresh background
      decoration: const BoxDecoration(
        color: Color(0xFFEDF5FF),
      ),
      child: Stack(
        children: [
          // Blue glow circle top right
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF244B73).withValues(alpha: 0.15),
              ),
            ),
          ),
          // Soft Cyan glow circle bottom left
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F5D4).withValues(alpha: 0.1),
              ),
            ),
          ),
          // Another blue glow center right
          Positioned(
            bottom: 200,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF244B73).withValues(alpha: 0.1),
              ),
            ),
          ),
          // Backdrop filter to blur the circles smoothly
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
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

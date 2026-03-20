import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoiceVisualizer extends StatelessWidget {
  final double soundLevel;
  final bool isListening;

  const VoiceVisualizer({
    super.key,
    required this.soundLevel,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(15, (index) {
          return _VisualizerBar(
            index: index,
            soundLevel: soundLevel,
            isListening: isListening,
          );
        }),
      ),
    );
  }
}

class _VisualizerBar extends StatefulWidget {
  final int index;
  final double soundLevel;
  final bool isListening;

  const _VisualizerBar({
    required this.index,
    required this.soundLevel,
    required this.isListening,
  });

  @override
  State<_VisualizerBar> createState() => _VisualizerBarState();
}

class _VisualizerBarState extends State<_VisualizerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150 + _random.nextInt(100)),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Normalizing sound level (0 to 1 range expected, but speech_to_text often gives -2 to 10 or more)
    // We'll clamp and scale it to a reasonable height factor.
    final baseHeight = 12.0;
    final soundFactor = widget.isListening
        ? (widget.soundLevel + 2).clamp(0, 15) * 4
        : 0.0;

    // Add some random variation for each bar to make it look organic
    final variation = math.sin(widget.index * 0.5) * 5 + 5;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double currentHeight = baseHeight + variation + soundFactor;
        if (widget.isListening) {
          currentHeight *= _animation.value;
        } else {
          currentHeight = baseHeight + (variation * 0.5);
        }

        return Container(
          width: 6,
          height: currentHeight.clamp(8, 80),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
                Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      },
    );
  }
}

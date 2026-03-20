import 'package:flutter/material.dart';
import '../../../core/widgets/glass_container.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.1,
      blur: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  const Color(0xFF7B2CBF).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'A.R.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileNameText(),
                SizedBox(height: 4),
                _ProfileSubtitleText(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNameText extends StatelessWidget {
  const _ProfileNameText();
  @override
  Widget build(BuildContext context) {
    return Text(
      'Henintsoa Paul',
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ProfileSubtitleText extends StatelessWidget {
  const _ProfileSubtitleText();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Edit Profile\nAccount Settings',
      style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.3),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/widgets/glass_container.dart';

class AppCredit extends StatelessWidget {
  const AppCredit({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassContainer(
          opacity: 0.05,
          blur: 10,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Made with heart by',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    'Henintsoa Paul',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            'v1.2.0 (3)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

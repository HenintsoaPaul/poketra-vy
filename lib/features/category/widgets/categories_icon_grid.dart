import 'package:flutter/material.dart';

class CategoriesIconGrid extends StatelessWidget {
  final int selectedIconCode;
  final ValueChanged<int> onIconSelected;

  static const List<IconData> _iconPresets = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.home,
    Icons.sports_esports,
    Icons.shopping_cart,
    Icons.category,
    Icons.local_hospital,
    Icons.school,
    Icons.flight,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.phone,
    Icons.work,
    Icons.fitness_center,
    Icons.movie,
    Icons.brush,
    Icons.pets,
    Icons.payments,
  ];

  const CategoriesIconGrid({
    super.key,
    required this.selectedIconCode,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _iconPresets.map((icon) {
        final isSelected = selectedIconCode == icon.codePoint;
        return InkWell(
          onTap: () => onIconSelected(icon.codePoint),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: (MediaQuery.of(context).size.width - 32 - 40) / 6, // Approximate width for 6 columns
            height: (MediaQuery.of(context).size.width - 32 - 40) / 6,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black12,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.black45,
            ),
          ),
        );
      }).toList(),
    );
  }
}

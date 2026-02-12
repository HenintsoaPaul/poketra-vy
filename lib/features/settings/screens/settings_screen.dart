import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categories_provider.dart';
import '../../../core/models/category.dart';
import '../../../core/providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _categoryController = TextEditingController();
  int _selectedIconCode = Icons.category.codePoint;

  final List<IconData> _iconPresets = [
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
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final name = _categoryController.text.trim();
    if (name.isNotEmpty) {
      ref
          .read(categoriesProvider.notifier)
          .addCategory(name, _selectedIconCode);
      _categoryController.clear();
      setState(() {
        _selectedIconCode = Icons.category.codePoint;
      });
      FocusScope.of(context).unfocus();
    }
  }

  List<Widget> _buildAppInfo() {
    return [
      Text(
        'App Information',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Show Onboarding'),
        subtitle: const Text('Revisit the welcome tour'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(onboardingProvider.notifier).resetOnboarding();
          context.go('/onboarding');
        },
      ),
    ];
  }

  List<Widget> _buildCategoriesSection(List<Category> categories) {
    return [
      Text(
        'Manage Categories',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Add or remove categories for your expenses.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      ),
      const SizedBox(height: 24),
      const Text('Choose Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _iconPresets.length,
          itemBuilder: (context, index) {
            final icon = _iconPresets[index];
            final isSelected = _selectedIconCode == icon.codePoint;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedIconCode = icon.codePoint),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                hintText: 'New category name (e.g., Health)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addCategory(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _addCategory,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      const SizedBox(height: 32),
      Expanded(
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(category.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  ref
                      .read(categoriesProvider.notifier)
                      .removeCategory(category.name);
                },
              ),
            );
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildAppInfo(),

            const Divider(height: 48),

            ..._buildCategoriesSection(categories),
          ],
        ),
      ),
    );
  }
}

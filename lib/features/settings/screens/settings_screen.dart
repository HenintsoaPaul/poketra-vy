import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categories_provider.dart';
import '../../../core/models/category.dart';
import '../../../core/providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                /// App Information Section
                const _SettingsSection(
                  title: 'App Information',
                  children: [_OnboardingListTile()],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                /// Category Management Section
                _SettingsSection(
                  title: 'Manage Categories',
                  subtitle: 'Add or remove categories for your expenses.',
                  children: [
                    const _AddCategoryForm(),
                    const SizedBox(height: 32),
                    if (categories.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('No categories added yet.'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) =>
                            _CategoryListItem(category: categories[index]),
                      ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

class _OnboardingListTile extends ConsumerWidget {
  const _OnboardingListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: const Text('Show Onboarding'),
      subtitle: const Text('Revisit the welcome tour'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ref.read(onboardingProvider.notifier).resetOnboarding();
        context.go('/onboarding');
      },
    );
  }
}

class _AddCategoryForm extends ConsumerStatefulWidget {
  const _AddCategoryForm();

  @override
  ConsumerState<_AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends ConsumerState<_AddCategoryForm> {
  final _controller = TextEditingController();
  int _selectedIconCode = Icons.category.codePoint;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      ref
          .read(categoriesProvider.notifier)
          .addCategory(name, _selectedIconCode);
      _controller.clear();
      setState(() {
        _selectedIconCode = Icons.category.codePoint;
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Icon',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _IconGrid(
          selectedIconCode: _selectedIconCode,
          onIconSelected: (code) => setState(() => _selectedIconCode = code),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Category name (e.g., Gym)',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryListItem extends ConsumerWidget {
  final Category category;

  const _CategoryListItem({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => _showEditDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _EditCategoryDialog(category: category),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? '
          'Expenses in this category will remain, but their category will appear as unknown.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).removeCategory(category.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EditCategoryDialog extends ConsumerStatefulWidget {
  final Category category;

  const _EditCategoryDialog({required this.category});

  @override
  ConsumerState<_EditCategoryDialog> createState() =>
      _EditCategoryDialogState();
}

class _EditCategoryDialogState extends ConsumerState<_EditCategoryDialog> {
  late TextEditingController _controller;
  late int _selectedIconCode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category.name);
    _selectedIconCode = widget.category.iconCodePoint;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose Icon:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _IconGrid(
              selectedIconCode: _selectedIconCode,
              onIconSelected: (code) =>
                  setState(() => _selectedIconCode = code),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              ref
                  .read(categoriesProvider.notifier)
                  .updateCategory(
                    widget.category.id,
                    widget.category.copyWith(
                      name: name,
                      iconCodePoint: _selectedIconCode,
                    ),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _IconGrid extends StatelessWidget {
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

  const _IconGrid({
    required this.selectedIconCode,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _iconPresets.length,
      itemBuilder: (context, index) {
        final icon = _iconPresets[index];
        final isSelected = selectedIconCode == icon.codePoint;
        return InkWell(
          onTap: () => onIconSelected(icon.codePoint),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

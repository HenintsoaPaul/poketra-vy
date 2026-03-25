import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categories_provider.dart';
import '../../../../core/models/category.dart';
import '../../../core/providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:poketra_vy/features/settings/widgets/reminders_tile.dart';
import '../widgets/export_excel_dialog.dart';

/// Widgets
import '../widgets/profile_card.dart';
import '../../../core/widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              /// Profile Card
              const ProfileCard(),

              const SizedBox(height: 32),

              /// SETTINGS
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'SETTINGS',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const _SettingsSection(),

              const SizedBox(height: 32),

              /// DAILY REMINDER SECTION
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'DAILY REMINDER',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: const GlassContainer(
                  opacity: 0.6,
                  blur: 25,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 1.5),
                  ),
                  child: RemindersTile(),
                ),
              ),

              const SizedBox(height: 32),

              /// CATEGORIES SECTION
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'EXPENSE CATEGORIES',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GlassContainer(
                opacity: 0.4,
                blur: 20,
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AddCategoryForm(),
                    const SizedBox(height: 24),
                    if (categories.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No categories added yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          height: 1,
                          indent: 56,
                        ),
                        itemBuilder: (context, index) =>
                            _CategoryListItem(category: categories[index]),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.4,
      blur: 20,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          /// Onboarding
          const _OnboardingListTile(),

          /// Divider
          Divider(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            height: 1,
            indent: 64,
          ),

          /// Help
          const _HelpListTile(),

          /// Divider
          Divider(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            height: 1,
            indent: 64,
          ),

          /// Export
          const _ExportListTile(),
        ],
      ),
    );
  }
}

class _ExportListTile extends StatelessWidget {
  const _ExportListTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.file_download_outlined,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        'Export to Excel',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Download your data in .xlsx format',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const ExportExcelDialog(),
        );
      },
    );
  }
}

class _OnboardingListTile extends ConsumerWidget {
  const _OnboardingListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
      title: Text(
        'Onboarding',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Show Onboarding Tour',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () {
        ref.read(onboardingProvider.notifier).resetOnboarding();
        context.go('/onboarding');
      },
    );
  }
}

class _HelpListTile extends ConsumerWidget {
  const _HelpListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
      title: Text(
        'Help',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Read about how to use the app',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () {
        context.push('/help');
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF244B73),
          ),
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
                style: const TextStyle(color: Color(0xFF244B73)),
                decoration: InputDecoration(
                  hintText: 'Category (e.g. Gym)',
                  hintStyle: const TextStyle(color: Colors.black26),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        category.name,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
            ),
            onPressed: () => _showEditDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
        backgroundColor: Colors.white,
        title: Text(
          'Delete Category?',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? '
          'Expenses in this category will remain, but their category will appear as unknown.',
          style: const TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).removeCategory(category.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
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
      backgroundColor: Colors.white,
      title: Text(
        'Edit Category',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Theme.of(context).primaryColor),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose Icon:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
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
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
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
      },
    );
  }
}

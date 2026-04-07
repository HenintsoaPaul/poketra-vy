import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/core/widgets/glass_container.dart';
import 'package:poketra_vy/features/category/widgets/add_category_form.dart';
import 'package:poketra_vy/features/category/widgets/categories_icon_grid.dart';
import 'package:poketra_vy/features/category/widgets/category_list_item.dart';
import '../providers/categories_provider.dart';
import '../../../../core/models/category.dart';

class CategoriesContainer extends StatelessWidget {
  const CategoriesContainer({super.key, required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.4,
      blur: 20,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AddCategoryForm(),
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
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                height: 1,
                indent: 56,
              ),
              itemBuilder: (context, index) =>
                  CategoryListItem(category: categories[index]),
            ),
        ],
      ),
    );
  }
}

class AddCategoryFormState extends ConsumerState<AddCategoryForm> {
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
        CategoriesIconGrid(
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/features/category/widgets/categories_icon_grid.dart';
import '../providers/categories_provider.dart';

class EditCategoryDialog extends ConsumerStatefulWidget {
  final Category category;

  const EditCategoryDialog({super.key, required this.category});

  @override
  ConsumerState<EditCategoryDialog> createState() => EditCategoryDialogState();
}

class EditCategoryDialogState extends ConsumerState<EditCategoryDialog> {
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
            CategoriesIconGrid(
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

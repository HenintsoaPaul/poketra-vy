import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/core/models/category.dart';
import 'package:poketra_vy/features/category/providers/categories_provider.dart';
import 'package:poketra_vy/features/category/widgets/edit_category_dialog.dart';

class CategoryListItem extends ConsumerWidget {
  final Category category;

  const CategoryListItem({super.key, required this.category});

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
      builder: (context) => EditCategoryDialog(category: category),
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

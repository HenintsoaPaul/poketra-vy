import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/core/models/expense.dart';
import 'package:poketra_vy/core/services/excel_import_service.dart';
import 'package:poketra_vy/core/services/json_import_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';
import 'package:poketra_vy/features/category/providers/categories_provider.dart';

class ImportListTile extends ConsumerWidget {
  const ImportListTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        Icons.file_upload_outlined,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        'Import Data',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Restore records from a .xlsx or .json file',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () async {
        final categories = ref.read(categoriesProvider);

        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx', 'json'],
        );

        if (result == null || result.files.single.path == null) return;

        final path = result.files.single.path!;
        final extension = result.files.single.extension?.toLowerCase();

        List<Expense>? importedExpenses;

        if (extension == 'xlsx') {
          final bytes = await File(path).readAsBytes();
          final importService = ExcelImportService();
          importedExpenses = importService.parseExcel(bytes, categories);
        } else if (extension == 'json') {
          final content = await File(path).readAsString();
          final importService = JsonImportService();
          importedExpenses = importService.parseJson(content, categories);
        }

        if (importedExpenses != null && importedExpenses.isNotEmpty) {
          await ref
              .read(expenseListProvider.notifier)
              .addMultipleExpenses(importedExpenses);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully imported ${importedExpenses.length} expenses!',
                ),
              ),
            );
          }
        } else if (importedExpenses != null && importedExpenses.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No valid records found in file.')),
            );
          }
        }
      },
    );
  }
}

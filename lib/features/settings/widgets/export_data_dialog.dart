import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/excel_export_service.dart';
import '../../../core/services/json_export_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../expenses/providers/expense_list_provider.dart';
import '../providers/categories_provider.dart';

enum ExportFormat { excel, json }

class ExportDataDialog extends ConsumerStatefulWidget {
  const ExportDataDialog({super.key});

  @override
  ConsumerState<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends ConsumerState<ExportDataDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  final Set<String> _selectedCategoryIds = {};
  ExportFormat _selectedFormat = ExportFormat.excel;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    _selectedCategoryIds.add('all');
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);

    try {
      final expenses = ref.read(expenseListProvider);
      final categories = ref.read(categoriesProvider);

      final List<String> filteredCategoryIds;
      if (_selectedCategoryIds.contains('all')) {
        filteredCategoryIds = categories.map((c) => c.id).toList();
      } else {
        filteredCategoryIds = _selectedCategoryIds.toList();
      }

      final filteredExpenses = expenses.where((e) {
        return filteredCategoryIds.contains(e.categoryId);
      }).toList();

      String filePath;
      if (_selectedFormat == ExportFormat.excel) {
        final service = ExcelExportService();
        filePath = await service.exportToExcel(
          expenses: filteredExpenses,
          categories: categories,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        final service = JsonExportService();
        filePath = await service.exportToJson(
          expenses: filteredExpenses,
          categories: categories,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (mounted) {
        await Share.shareXFiles([XFile(filePath)], text: 'My Expenses Export');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final primaryColor = Theme.of(context).primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassContainer(
        opacity: 0.95,
        blur: 30,
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Format Selection
            Text(
              'Format',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor.withValues(alpha: 0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedFormat = ExportFormat.excel),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedFormat == ExportFormat.excel
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: _selectedFormat == ExportFormat.excel
                              ? primaryColor
                              : Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Excel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedFormat == ExportFormat.excel
                              ? primaryColor
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedFormat = ExportFormat.json),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedFormat == ExportFormat.json
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: _selectedFormat == ExportFormat.json
                              ? primaryColor
                              : Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'JSON',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedFormat == ExportFormat.json
                              ? primaryColor
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Date Range
            Text(
              'Date Range',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor.withValues(alpha: 0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Start',
                    date: _startDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: 'End',
                    date: _endDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Categories
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor.withValues(alpha: 0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategoryIds.contains('all'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryIds.clear();
                          _selectedCategoryIds.add('all');
                        }
                      });
                    },
                    selectedColor: primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedCategoryIds.contains('all')
                          ? primaryColor
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) {
                    final isSelected = _selectedCategoryIds.contains(
                      category.id,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryIds.remove('all');
                            if (selected) {
                              _selectedCategoryIds.add(category.id);
                            } else {
                              _selectedCategoryIds.remove(category.id);
                              if (_selectedCategoryIds.isEmpty) {
                                _selectedCategoryIds.add('all');
                              }
                            }
                          });
                        },
                        selectedColor: primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? primaryColor : Colors.black54,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isExporting ? null : _export,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Export'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black38),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

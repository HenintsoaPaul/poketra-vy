import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class HiveService {
  static const String _expensesBoxName = 'expenses';
  static const String _settingsBoxName = 'settings';
  static const String _categoriesKey = 'categories';
  Box<Expense>? _expensesBox;
  Box? _settingsBox;

  /// Initialize Hive and open the expenses box
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }

    _expensesBox = await Hive.openBox<Expense>(_expensesBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    // Initialize default categories if empty
    if (_settingsBox!.get(_categoriesKey) == null) {
      await _settingsBox!.put(_categoriesKey, [
        'food',
        'transport',
        'rent',
        'fun',
        'shopping',
        'misc',
      ]);
    }
  }

  /// Get all expenses from the database
  List<Expense> getExpenses() {
    if (_expensesBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _expensesBox!.values.toList();
  }

  /// Save a new expense to the database
  Future<void> saveExpense(Expense expense) async {
    if (_expensesBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _expensesBox!.put(expense.id, expense);
  }

  /// Delete an expense from the database
  Future<void> deleteExpense(String id) async {
    if (_expensesBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _expensesBox!.delete(id);
  }

  /// Get all categories from settings
  List<String> getCategories() {
    if (_settingsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return List<String>.from(
      _settingsBox!.get(_categoriesKey, defaultValue: []),
    );
  }

  /// Save categories to settings
  Future<void> saveCategories(List<String> categories) async {
    if (_settingsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _settingsBox!.put(_categoriesKey, categories);
  }

  /// Clear all expenses (useful for testing)
  Future<void> clearAll() async {
    if (_expensesBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _expensesBox!.clear();
  }

  /// Close the Hive box (call when app is closing)
  Future<void> close() async {
    await _expensesBox?.close();
  }
}

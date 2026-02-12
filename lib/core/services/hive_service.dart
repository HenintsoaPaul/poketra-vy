import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class HiveService {
  static const String _expensesBoxName = 'expenses';
  static const String _settingsBoxName = 'settings';
  static const String _categoriesKey = 'categories';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  Box<Expense>? _expensesBox;
  Box? _settingsBox;

  /// Initialize Hive and open the expenses box
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryAdapter());
    }

    _expensesBox = await Hive.openBox<Expense>(_expensesBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    // MIGRATION LOGIC
    await _migrateToCategoryIds();

    // Initialize default categories if empty
    if (_settingsBox!.get(_categoriesKey) == null) {
      await _settingsBox!.put(_categoriesKey, [
        Category(name: 'food', iconCodePoint: Icons.restaurant.codePoint),
        Category(
          name: 'transport',
          iconCodePoint: Icons.directions_car.codePoint,
        ),
        Category(name: 'rent', iconCodePoint: Icons.home.codePoint),
        Category(name: 'fun', iconCodePoint: Icons.sports_esports.codePoint),
        Category(
          name: 'shopping',
          iconCodePoint: Icons.shopping_cart.codePoint,
        ),
        Category(name: 'misc', iconCodePoint: Icons.category.codePoint),
      ]);
    }
  }

  Future<void> _migrateToCategoryIds() async {
    final rawCategories = _settingsBox!.get(_categoriesKey);
    if (rawCategories is! List) return;

    final List<Category> categories = [];
    bool categoriesUpdated = false;

    // 1. Migrate Categories: Ensure every category has an ID
    for (final raw in rawCategories) {
      if (raw is Category) {
        // Category constructor now ensures ID, but if it came from old adapter it might be null if we didn't handle it in read()
        // Our updated CategoryAdapter handles fields[2] as String?, so it might be null.
        if (raw.id.isEmpty) {
          categories.add(raw.copyWith(id: const Uuid().v4()));
          categoriesUpdated = true;
        } else {
          categories.add(raw);
        }
      } else if (raw is String) {
        // Older migration: String to Category object
        categories.add(
          Category(name: raw, iconCodePoint: Icons.category.codePoint),
        );
        categoriesUpdated = true;
      }
    }

    if (categoriesUpdated) {
      await _settingsBox!.put(_categoriesKey, categories);
    }

    // 2. Migrate Expenses: Map name to ID
    final expenses = _expensesBox!.values.toList();

    for (final expense in expenses) {
      // Check if categoryId is actually an ID or a name
      // E.g. categoryId == 'food'
      final matchingCategory = categories.firstWhere(
        (c) => c.name == expense.categoryId,
      );

      if (expense.categoryId != matchingCategory.id) {
        await _expensesBox!.put(
          expense.id,
          expense.copyWith(categoryId: matchingCategory.id),
        );
      }
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
  List<Category> getCategories() {
    if (_settingsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    final rawCategories = _settingsBox!.get(_categoriesKey);
    if (rawCategories is List) {
      // Handle migration or initial state
      if (rawCategories.isNotEmpty && rawCategories.first is String) {
        return rawCategories
            .map(
              (name) => Category(
                name: name as String,
                iconCodePoint: Icons.category.codePoint,
              ),
            )
            .toList();
      }
      return List<Category>.from(rawCategories);
    }
    return [];
  }

  /// Save categories to settings
  Future<void> saveCategories(List<Category> categories) async {
    if (_settingsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _settingsBox!.put(_categoriesKey, categories);
  }

  /// Get onboarding status
  bool isOnboardingComplete() {
    if (_settingsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _settingsBox!.get(_onboardingCompleteKey, defaultValue: false);
  }

  /// Save onboarding status
  Future<void> setOnboardingComplete(bool complete) async {
    if (_settingsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _settingsBox!.put(_onboardingCompleteKey, complete);
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

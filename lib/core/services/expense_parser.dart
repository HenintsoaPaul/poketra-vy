import '../models/expense.dart';

class ExpenseParser {
  static final List<String> _categories = [
    'food',
    'transport',
    'rent',
    'fun',
    'shopping'
  ];

  static Expense? parse(String text) {
    if (text.isEmpty) return null;
    final lowerText = text.toLowerCase();
    final words = lowerText.split(' ');

    double? amount;
    String category = 'other'; // Default category? Prompt says "Everything else -> description", but category must be set. 
                         // "Keywords -> category". If no keyword, what category?
                         // The prompt implies we look for keywords for category. 
                         // "Everything else -> description" likely refers to non-date, non-amount, non-category words.
                         // Let's assume 'misc' or just use the extracted category if found.
                         // Wait, prompt says "Keywords -> category: food, transport, rent, fun, shopping".
                         // If none found, maybe it fails or defaults? 
                         // Let's default to 'misc' or 'uncategorized' if no keyword fits, but the prompt implies strict explicit categories.
                         // Let's check prompt again: "Keywords -> category ... Everything else -> description".
                         // It doesn't explicitly say what to do if no category keyword is found. 
                         // I will assume 'misc' for now or 'general'. Let's stick to 'misc'.

    DateTime date = DateTime.now();
    
    // 1. Extract Amount (First number)
    // Simple heuristic: find first token that parses to double
    for (var word in words) {
      // Remove symbols like currency if attached? Prompt says "First number -> amount".
      // Let's try parsing purely.
      final cleanWord = word.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleanWord.isNotEmpty) {
        final parsed = double.tryParse(cleanWord);
        if (parsed != null) {
          amount = parsed;
          break; // Stop after first number
        }
      }
    }

    if (amount == null) return null; // Amount is mandatory for an expense? Usually yes.

    // 2. Extract Category
    for (var cat in _categories) {
      if (lowerText.contains(cat)) {
        category = cat;
        break; // Take first matching category
      }
    }
    // If no category found, maybe use 'misc'? Prompt didn't specify default. using 'misc'.
    if (category == 'other' && !_categories.contains('other')) {
       category = 'misc'; 
    }


    // 3. Extract Date
    if (lowerText.contains('yesterday')) {
      date = DateTime.now().subtract(const Duration(days: 1));
    }
    // "today" is default

    // 4. Extract Description
    // "Everything else -> description"
    // We should probably remove the amount word, the category word, and the date word from the text to get "everything else".
    // Or just use the original text as description? 
    // "Everything else -> description" usually implies the *remaining* text.
    // Let's try to strip the parts we used.
    
    String description = text;
    // This is a bit tricky to do perfectly with just replace without destroying sentences.
    // MVP approach: Description = The full text (as it captures context clearly) OR
    // explicitly try to remove specific extracted tokens.
    // "Everything else -> description" strongly suggests the residue.
    
    // Let's just use the full text as description for "context" as it maintains readability, 
    // OR try to be smart. 
    // Prompt: "Everything else -> description". I will interpret this as "The description field should contain the text that wasn't parsed into other fields".
    // However, for an MVP, keeping the full text is often better than a fragmented string.
    // Let's Try to be sufficiently "MVP compliant" by using the rest.
    
    // Actually, simple heuristic: just use the whole text as description is often safer and "readable". 
    // BUT the prompt says "Everything else -> description". I will try to remove the recognized tokens.
    
    // Validating strictness: "do NOT use regex-heavy or overengineered logic."
    // So, stripping tokens might be too much. 
    // Decision: use the original text as the description, or maybe suffix it? 
    // "I spent 5000 on food" -> Amount: 5000, Cat: food. Desc: "I spent on"?? No.
    // Let's use the full text as description. It's the "raw input". 
    // Wait, if I put "food" in category, redundancy is fine.
    // Let's stick to: Description = text. 
    // Re-reading prompt: "* Everything else -> description". This line suggests extraction.
    // I made a choice: I will use the Full Text as description because it is robust and simple (MVP). 
    // AND I will construct a "clean" description if possible, but let's just stick to full text for now unless user complains.
    // Actually, "Everything else" implies a remainder. 
    // Let's do a simple pass: remove found amount string, remove found category string, remove date keywords.
    
    // Implementation of removal:
    String processingText = text;
    // We need to find the exact string that was parsed.
    // We found 'amount' via loop. Let's find it again to remove.
    for (var word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleanWord.isNotEmpty && double.tryParse(cleanWord) == amount) {
        // replace first occurrence of this word in insensitive way?
        // simplistic replacement
        processingText = processingText.replaceFirst(word, '');
        break;
      }
    }
    
    if (category != 'misc') {
       processingText = processingText.replaceFirst(category, '');
    }
    
    if (lowerText.contains('today')) processingText = processingText.replaceFirst('today', '');
    if (lowerText.contains('yesterday')) processingText = processingText.replaceFirst('yesterday', '');
    
    // Clean up spaces
    description = processingText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (description.isEmpty) {
      description = "Expense"; // Fallback
    }

    return Expense(
      amount: amount,
      category: category,
      date: date,
      description: description,
    );
  }
}

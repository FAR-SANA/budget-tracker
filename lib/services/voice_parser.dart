import '../models/record.dart';

class ParsedVoice {
  final String title;
  final double amount;
  final RecordType type;
  final String category;
  final DateTime date;
  final String? accountName;

  ParsedVoice({
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.accountName,
  });
}

class VoiceParser {
  static ParsedVoice? parse(String text, List<String> accountNames) {
    text = text.toLowerCase();

    // ================= AMOUNT =================
    final amountMatch = RegExp(r'\d+').firstMatch(text);
    if (amountMatch == null) return null;

    final amount = double.parse(amountMatch.group(0)!);

    // ================= TYPE =================
    RecordType type = RecordType.expense;

    if (text.contains("earned") ||
        text.contains("earn") ||
        text.contains("received") ||
        text.contains("credited") ||
        text.contains("income") ||
        text.contains("salary")) {
      type = RecordType.income;
    }

    if (text.contains("spent") ||
        text.contains("spend") ||
        text.contains("spending") ||
        text.contains("debited") ||
        text.contains("paid")) {
      type = RecordType.expense;
    }

    // ================= CATEGORY =================
    const categories = [
      "miscellaneous",
      "entertainment",
      "household",
      "transport",
      "shopping",
      "education",
      "health",
      "salary",
      "food",
    ];

    String category = "miscellaneous";

    for (final c in categories) {
      if (text.contains(c)) {
        category = c;
        break;
      }
    }

    // ================= ACCOUNT =================
    String? account;

    for (final acc in accountNames) {
      if (text.contains(acc.toLowerCase())) {
        account = acc;
        break;
      }
    }

    // ================= DATE =================
    DateTime date = DateTime.now();

    // Format: 26/02/2026
    final numericDate = RegExp(
      r'(\d{1,2})\/(\d{1,2})\/(\d{4})',
    ).firstMatch(text);

    if (numericDate != null) {
      final day = int.parse(numericDate.group(1)!);
      final month = int.parse(numericDate.group(2)!);
      final year = int.parse(numericDate.group(3)!);
      date = DateTime(year, month, day);
    }

    // Format: 26 February 2026 OR 26th February 2026
    final naturalDate = RegExp(
      r'(\d{1,2})(st|nd|rd|th)?\s+(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{4})',
    ).firstMatch(text);

    if (naturalDate != null) {
      final day = int.parse(naturalDate.group(1)!);
      final monthName = naturalDate.group(3)!;
      final year = int.parse(naturalDate.group(4)!);

      const months = {
        "january": 1,
        "february": 2,
        "march": 3,
        "april": 4,
        "may": 5,
        "june": 6,
        "july": 7,
        "august": 8,
        "september": 9,
        "october": 10,
        "november": 11,
        "december": 12,
      };

      date = DateTime(year, months[monthName]!, day);
    }

    if (text.contains("yesterday")) {
      date = DateTime.now().subtract(const Duration(days: 1));
    }

    if (text.contains("today")) {
      date = DateTime.now();
    }

    // ================= TITLE =================
    String title = text;

    // remove numbers
    title = title.replaceAll(RegExp(r'\d+'), '');

    // remove currency
    title = title.replaceAll(RegExp(r'\brs\b|\brupees\b'), '');

    // remove date formats
    title = title.replaceAll(RegExp(r'\d{1,2}\/\d{1,2}\/\d{4}'), '');
    title = title.replaceAll(RegExp(r'\d{1,2}(st|nd|rd|th)'), '');

    // remove month names
    title = title.replaceAll(
      RegExp(
        r'(january|february|march|april|may|june|july|august|september|october|november|december)',
      ),
      '',
    );

    // remove category
    title = title.replaceAll(category, '');

    // remove account name
    if (account != null) {
      title = title.replaceAll(account.toLowerCase(), '');
    }

    // remove filler words
    const stopWords = [
      "rs",
      "rupees",
      "spent",
      "spend",
      "paid",
      "debited",
      "earned",
      "earn",
      "received",
      "credited",
      "for",
      "four",
      "on",
      "from",
      "to",
      "in",
      "the",
      "a",
      "an",
      "category",
      "account",
      "was",
      "is",
      "of",
      "at",
      "by",
      "today",
      "yesterday",
    ];

    for (final word in stopWords) {
      title = title.replaceAll(RegExp(r'\b$word\b'), '');
    }

    // clean spaces
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    // choose meaningful words only
    final words = title
        .split(' ')
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .toList();

    if (words.isNotEmpty) {
      title = words.join(' ');
    }

    if (title.isEmpty) {
      title = type == RecordType.expense ? "Expense" : "Income";
    }

    return ParsedVoice(
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      accountName: account,
    );
  }
}

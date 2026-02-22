enum RecordType {
  income,
  expense,
}

class Record {
  final String title;
  final double amount;
  final DateTime date;
  final RecordType type;
  final String category;
  final String? repeatType;

  Record({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.repeatType,
  });
factory Record.fromJson(Map<String, dynamic> json) {
  return Record(
    title: json['title'] ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
    date: json['record_date'] != null
        ? DateTime.parse(json['record_date'])
        : DateTime.now(),
    type: json['record_type'] == 'income'
        ? RecordType.income
        : RecordType.expense,
    category: json['category_name'] ?? 'Unknown', // ✅ FIXED
    repeatType: json['repeat_type'],
  );
}
}
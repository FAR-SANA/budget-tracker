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
}

enum RecordType { income, expense }

class Record {
  final String id; // ✅ add this
  final String title;
  final double amount;
  final DateTime date;
  final RecordType type;
  final String category;
  final String? repeatType;
    final String accountId; 

  Record({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
     required this.accountId,
    this.repeatType,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['record_id'].toString(), // ✅ pull from DB
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['record_date'] != null
          ? DateTime.parse(json['record_date'])
          : DateTime.now(),
      type: json['record_type'] == 'income'
          ? RecordType.income
          : RecordType.expense,
      category: json['category_name'] ?? 'Unknown',
      repeatType: json['repeat_type'],
          accountId: json['account_id'],
    );
  }
}
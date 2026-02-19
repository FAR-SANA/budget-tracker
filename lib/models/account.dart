class Account {
  final String? id;
  final String name;
  final double balance;
  final String? userId;
  final String? createdAt;

  Account({
    this.id,
    required this.name,
    required this.balance,
    this.userId,
    this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      userId: json['user_id'],
      createdAt: json['created_at'],
    );
  }
}

class Account {
  final String accountId;
  final String name;
  final double balance;
  final String? userId;
  final String? createdAt;
  final bool isDefault;

  Account({
  required this.accountId,
  required this.name,
  required this.balance,
  this.userId,
  this.createdAt,
  required this.isDefault,   // ✅ ADD THIS
});

  factory Account.fromJson(Map<String, dynamic> json) {
  return Account(
    accountId: json['account_id'],
    name: json['name'] ?? '',
    balance: (json['balance'] ?? 0).toDouble(),
    userId: json['user_id'],
    createdAt: json['created_at'],
    isDefault: json['is_default'] ?? false,   // ✅ ADD THIS
  );
}
}

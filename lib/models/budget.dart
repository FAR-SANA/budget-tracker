enum BudgetType { saving, spending }

class Budget {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final BudgetType type;
  final DateTime? startDate; // ✅ ADD
  final DateTime? endDate;   // ✅ ADD

  Budget({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.type,
    this.startDate, // ✅ ADD
    this.endDate,   // ✅ ADD
  });
}

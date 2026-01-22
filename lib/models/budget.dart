enum BudgetType { saving, spending }

class Budget {
  final String title;
  final double targetAmount;
  double currentAmount;
  final BudgetType type;

  Budget({
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.type,
  });
}

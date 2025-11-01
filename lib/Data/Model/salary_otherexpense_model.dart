class ExpenseModel {
  final String title; // expense name (ex: Current Bill, Dokan Bill, Salary)
  final double amount;
  final DateTime date;

  ExpenseModel({
    required this.title,
    required this.amount,
    required this.date,
  });
}

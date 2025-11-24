import 'package:flutter/foundation.dart';
import '../../Data/Model/expense_model.dart';
import 'sell_provider.dart';

class ExpenseProvider with ChangeNotifier {
  final List<ExpenseModel> _expenses = [];
  final SellProvider sellProvider;

  ExpenseProvider({required this.sellProvider});

  /// 🔹 All expenses (read-only)
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  /// 🔹 Today's expenses
  List<ExpenseModel> get todayExpenses {
    final today = DateTime.now();
    return _expenses
        .where((e) =>
    e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day)
        .toList();
  }

  /// 🔹 Today's total expense
  double get todayTotalExpense =>
      todayExpenses.fold(0.0, (sum, e) => sum + e.amount);

  /// 🔹 Get expenses for a specific month
  List<ExpenseModel> getMonthlyExpenses(int year, int month) {
    return _expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  /// 🔹 Total expense for a specific month
  double getMonthlyTotalExpense(int year, int month) {
    return getMonthlyExpenses(year, month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// 🔹 Daily totals for each day in a month
  Map<DateTime, double> getDailyTotalsForMonth(int year, int month) {
    final monthlyExpenses = getMonthlyExpenses(year, month);
    final Map<DateTime, double> dailyTotals = {};

    for (var e in monthlyExpenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + e.amount;
    }
    return dailyTotals;
  }

  /// 🔹 Add new expense
  void addExpense({
    required String title,
    required double amount,
    required DateTime date,
  }) {
    if (title.isEmpty || amount <= 0) return;

    _expenses.add(ExpenseModel(
      title: title,
      amount: amount,
      date: date,
    ));

    _recalculateNetCashForDate(date);
    notifyListeners();
  }

  /// 🔹 Edit existing expense
  void editExpense({
    required int index,
    required String newTitle,
    required double newAmount,
    required DateTime newDate,
  }) {
    if (index < 0 || index >= _expenses.length) return;

    _expenses[index] = ExpenseModel(
      title: newTitle,
      amount: newAmount,
      date: newDate,
    );

    _recalculateNetCashForDate(newDate);
    notifyListeners();
  }

  /// 🔹 Delete expense
  void deleteExpense(int index) {
    if (index < 0 || index >= _expenses.length) return;

    final removedDate = _expenses[index].date;
    _expenses.removeAt(index);

    _recalculateNetCashForDate(removedDate);
    notifyListeners();
  }

  /// 🔹 Clear all expenses
  void clearAllExpenses() {
    final affectedDates = _expenses.map((e) => e.date).toSet();
    _expenses.clear();

    for (var date in affectedDates) {
      _recalculateNetCashForDate(date);
    }
    notifyListeners();
  }

  /// 🔹 Recalculate netCash for a specific date
  void _recalculateNetCashForDate(DateTime date) {
    // 1️⃣ Update SellProvider expenses
    sellProvider.updateExpenses(_expenses);

    // 2️⃣ Recalculate netCash only if a sell exists
    final existingSell = sellProvider.getSellByDate(date);
    if (existingSell != null) {
      sellProvider.addOrUpdateSellForDate(date, existingSell.amount);
    }
    else {
     sellProvider.addOrUpdateSellForDate(date, 0.0);
    }
  }
}

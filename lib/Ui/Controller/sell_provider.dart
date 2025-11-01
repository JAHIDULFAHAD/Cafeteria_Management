import 'package:flutter/foundation.dart';
import '../../Data/Model/purchase_model.dart';
import '../../Data/Model/salary_otherexpense_model.dart';
import '../../Data/Model/sell_model.dart';

class SellProvider with ChangeNotifier {
  final List<SellModel> _sells = [];
  final List<DailyPurchaseModel> _purchases = [];
  final List<ExpenseModel> _expenses = [];

  List<SellModel> get sells => _sells;

  // Update Purchases
  void updatePurchases(List<DailyPurchaseModel> newPurchases) {
    _purchases
      ..clear()
      ..addAll(newPurchases);
    _recalculateAllNetCash();
  }

  // Update Expenses
  void updateExpenses(List<ExpenseModel> newExpenses) {
    _expenses
      ..clear()
      ..addAll(newExpenses);
    _recalculateAllNetCash();
  }

  // Add or Update Sell for a specific date
  void addOrUpdateSellForDate(DateTime date, double sellAmount) {
    final index = _sells.indexWhere((s) =>
    s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day);

    double netCash =
        sellAmount - (_getPurchaseTotalByDate(date) + _getExpenseTotalByDate(date));

    if (index != -1) {
      _sells[index].amount = sellAmount;
      _sells[index].netCash = netCash;
    } else {
      _sells.add(SellModel(date: date, amount: sellAmount, netCash: netCash));
    }

    notifyListeners();
  }

  // Today Sell
  void addOrUpdateTodaySell(double sellAmount) {
    addOrUpdateSellForDate(DateTime.now(), sellAmount);
  }

  SellModel? getSellByDate(DateTime date) {
    try {
      return _sells.firstWhere((s) =>
      s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  SellModel? get todaySell => getSellByDate(DateTime.now());

  // Monthly Sell List
  List<SellModel> getMonthlySellList(int month, int year) {
    return _sells
        .where((s) => s.date.year == year && s.date.month == month)
        .toList();
  }

  // Monthly Total Sell
  double getMonthlyTotalSell(int month, int year) {
    return _sells
        .where((s) => s.date.year == year && s.date.month == month)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  // Private Helpers
  double _getPurchaseTotalByDate(DateTime date) {
    return _purchases
        .where((p) =>
    p.date.year == date.year &&
        p.date.month == date.month &&
        p.date.day == date.day)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double _getExpenseTotalByDate(DateTime date) {
    return _expenses
        .where((e) =>
    e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void _recalculateAllNetCash() {
    for (var s in _sells) {
      s.netCash =
          s.amount - (_getPurchaseTotalByDate(s.date) + _getExpenseTotalByDate(s.date));
    }
    notifyListeners();
  }
}

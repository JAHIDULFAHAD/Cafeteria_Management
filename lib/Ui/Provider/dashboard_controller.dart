import 'package:flutter/foundation.dart';
import '../../Data/Model/dashboard_model.dart';
import 'expense_provider.dart';
import 'sell_provider.dart';
import 'purchase_provider.dart';

class DashboardProvider extends ChangeNotifier {
  late DashboardModel _dashboard;

  final SellProvider sellProvider;
  final PurchaseProvider purchaseProvider;
  final ExpenseProvider expenseProvider;

  DashboardProvider({
    required this.sellProvider,
    required this.purchaseProvider,
    required this.expenseProvider,
  }) {
    _dashboard = DashboardModel(
      todayIncome: 0,
      monthIncome: 0,
      yearIncome: 0,
      monthlyTotalPurchases: 0,
    );

    // Listen to provider changes
    sellProvider.addListener(calculateDashboard);
    purchaseProvider.addListener(calculateDashboard);
    expenseProvider.addListener(calculateDashboard);

    calculateDashboard();
  }

  double get todayNetCash => _dashboard.todayIncome;
  double get monthlyNetCash => _dashboard.monthIncome;
  double get monthlyTotalSells => _dashboard.yearIncome;
  double get monthlyTotalPurchases => _dashboard.monthlyTotalPurchases.toDouble();

  /// Calculate dashboard values
  void calculateDashboard({int? year, int? month}) {
    final now = DateTime.now();
    final currentYear = year ?? now.year;
    final currentMonth = month ?? now.month;

    // ✅ Today Net Cash (already includes purchases & expenses in SellProvider)
    _dashboard.todayIncome = sellProvider.todaySell?.netCash ?? 0.0;

    // ✅ Monthly Total Sells
    final monthSells = sellProvider.getMonthlyTotalSell(currentMonth, currentYear);
    _dashboard.yearIncome = monthSells;

    // ✅ Monthly Total Expenses
    final monthExpenses = expenseProvider.getMonthlyTotalExpense(currentYear, currentMonth);


    // ✅ Monthly Total Purchases
    final monthPurchases = purchaseProvider.getMonthlyTotal(currentYear, currentMonth);
    _dashboard.monthlyTotalPurchases = monthPurchases;

    // ✅ Monthly Net Cash = total sells - total expenses
    _dashboard.monthIncome = monthSells - (monthExpenses + monthPurchases);

    notifyListeners();
  }

  /// Force refresh dashboard manually
  void refreshDashboard() {
    calculateDashboard();
  }
}

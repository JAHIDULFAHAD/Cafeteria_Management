import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    sellProvider.addListener(_calculateDashboard);
    purchaseProvider.addListener(_calculateDashboard);
    expenseProvider.addListener(_calculateDashboard);

    // Initial calculation
    _calculateDashboard();
  }

  // Public getters
  double get todayNetCash => _dashboard.todayIncome;
  double get monthlyNetCash => _dashboard.monthIncome;
  double get monthlyTotalSells => _dashboard.yearIncome;
  double get monthlyTotalPurchases => _dashboard.monthlyTotalPurchases.toDouble();

  /// 🔹 Recalculate all dashboard values
  void _calculateDashboard({int? year, int? month}) {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;

    // Today Net Cash
    final todaySell = sellProvider.getSellByDate(now);
    _dashboard.todayIncome = todaySell?.netCash ?? 0.0;

    // Monthly Total Sells
    final totalSells = sellProvider.getMonthlyTotalSell(m, y);
    _dashboard.yearIncome = totalSells;

    // Monthly Total Purchases
    final totalPurchases = purchaseProvider.getMonthlyTotal(y, m);
    _dashboard.monthlyTotalPurchases = totalPurchases.toDouble();

    // Monthly Total Expenses
    final totalExpenses = expenseProvider.getMonthlyTotalExpense(y, m);

    // Monthly Net Cash = total sells - (expenses + purchases)
    _dashboard.monthIncome = totalSells - (totalPurchases + totalExpenses);

    notifyListeners();
  }

  /// 🔹 Force refresh manually
  void refreshDashboard() {
    _calculateDashboard();
  }
}

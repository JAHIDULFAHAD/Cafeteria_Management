import 'package:flutter/foundation.dart';
import '../../Data/Model/purchase_model.dart';
import 'sell_provider.dart';

class PurchaseProvider with ChangeNotifier {
  final List<PurchaseModel> _purchases = [];
  final SellProvider sellProvider;

  PurchaseProvider({required this.sellProvider});

  List<PurchaseModel> get purchases => _purchases;

  // Add new purchase
  void addPurchase(String item, double amount, DateTime date) {
    _purchases.add(PurchaseModel(item: item, amount: amount, date: date));
    sellProvider.updatePurchases(_purchases);
    notifyListeners();
  }

  // Delete purchase
  void deletePurchase(int index) {
    _purchases.removeAt(index);
    sellProvider.updatePurchases(_purchases);
    notifyListeners();
  }

  // Edit purchase
  void editPurchase(int index, String newItem, double newAmount) {
    _purchases[index] = PurchaseModel(
      item: newItem,
      amount: newAmount,
      date: _purchases[index].date,
    );
    sellProvider.updatePurchases(_purchases);
    notifyListeners();
  }

  // Get purchases for a specific day
  List<PurchaseModel> getDailyByDate(DateTime date) {
    return _purchases
        .where((p) =>
    p.date.year == date.year &&
        p.date.month == date.month &&
        p.date.day == date.day)
        .toList();
  }

  // ✅ Get total purchase for a specific month
  double getMonthlyTotal(int year, int month) {
    return _purchases
        .where((p) => p.date.year == year && p.date.month == month)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // ✅ Get list of all months that have purchases
  List<DateTime> getAvailableMonths() {
    final months = _purchases
        .map((p) => DateTime(p.date.year, p.date.month))
        .toSet()
        .toList();
    months.sort((a, b) => b.compareTo(a)); // Latest month first
    return months;
  }

  // ✅ Get all purchases for a given month
  List<PurchaseModel> getMonthlyPurchases(int year, int month) {
    return _purchases
        .where((p) => p.date.year == year && p.date.month == month)
        .toList();
  }
}

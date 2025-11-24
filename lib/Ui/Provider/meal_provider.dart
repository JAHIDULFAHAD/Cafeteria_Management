import 'package:flutter/foundation.dart';
import '../../Data/Model/meal_model.dart';

class MealProvider with ChangeNotifier {
  final List<MealModel> _bills = [];

  List<MealModel> get bills => _bills;

  // ✅ Add a new bill
  void addBill(MealModel bill) {
    _bills.add(bill);
    notifyListeners();
  }

  // ✅ Delete a bill
  void deleteBill(MealModel bill) {
    _bills.remove(bill);
    notifyListeners();
  }

  // ✅ Edit a bill
  void updateBill(MealModel oldBill, MealModel newBill) {
    final index = _bills.indexOf(oldBill);
    if (index != -1) {
      _bills[index] = newBill;
      notifyListeners();
    }
  }

  // ✅ Get bills for specific month & year
  List<MealModel> getBillsForMonth(int year, int month) {
    return _bills
        .where((b) => b.date.year == year && b.date.month == month)
        .toList();
  }

  // ✅ Search by name within a month
  List<MealModel> searchByName(String name, int year, int month) {
    return getBillsForMonth(year, month)
        .where((b) => b.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  // ✅ Monthly totals
  double getMonthlyTotal(int year, int month) {
    return getBillsForMonth(year, month)
        .fold(0.0, (sum, b) => sum + b.massBill);
  }

  double getMonthlyAdvance(int year, int month) {
    return getBillsForMonth(year, month)
        .fold(0.0, (sum, b) => sum + b.advanceBill);
  }

  double getMonthlyRemaining(int year, int month) {
    return getBillsForMonth(year, month)
        .fold(0.0, (sum, b) => sum + b.remaining);
  }
}

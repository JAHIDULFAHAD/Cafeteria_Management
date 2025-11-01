import 'package:flutter/foundation.dart';
import '../../Data/Model/mess_model.dart';

class MonthlyBillProvider with ChangeNotifier {
  final List<MonthlyBillModel> _bills = [];

  List<MonthlyBillModel> get bills => _bills;

  // ✅ Add a new bill
  void addBill(MonthlyBillModel bill) {
    _bills.add(bill);
    notifyListeners();
  }

  // ✅ Delete a bill
  void deleteBill(MonthlyBillModel bill) {
    _bills.remove(bill);
    notifyListeners();
  }

  // ✅ Edit a bill
  void updateBill(MonthlyBillModel oldBill, MonthlyBillModel newBill) {
    final index = _bills.indexOf(oldBill);
    if (index != -1) {
      _bills[index] = newBill;
      notifyListeners();
    }
  }

  // ✅ Get bills for specific month & year
  List<MonthlyBillModel> getBillsForMonth(int year, int month) {
    return _bills
        .where((b) => b.date.year == year && b.date.month == month)
        .toList();
  }

  // ✅ Search by name within a month
  List<MonthlyBillModel> searchByName(String name, int year, int month) {
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

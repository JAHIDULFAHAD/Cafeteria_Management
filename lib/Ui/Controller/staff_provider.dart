import 'package:flutter/foundation.dart';
import '../../Data/Model/staff_model.dart';

class StaffProvider with ChangeNotifier {
  final List<StaffModel> _staffs = [];

  List<StaffModel> get staffs => _staffs;

  /// Add new staff
  void addStaff(String name, double salary) {
    _staffs.add(StaffModel(
      id: DateTime.now().toString(),
      name: name,
      salary: salary,
      pendingSalary: 0,
    ));
    notifyListeners();
  }

  /// Edit staff info
  void editStaff(String id, String newName, double newSalary) {
    final index = _staffs.indexWhere((s) => s.id == id);
    if (index != -1) {
      _staffs[index].name = newName;
      _staffs[index].salary = newSalary;
      notifyListeners();
    }
  }

  /// Delete staff
  void deleteStaff(String id) {
    _staffs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Pay salary to staff
  /// If paid less than salary, pendingSalary will be updated
  /// If paid more than salary, pendingSalary will be negative (advance)
  void paySalary(String id, double amountPaid) {
    final index = _staffs.indexWhere((s) => s.id == id);
    if (index != -1) {
      final staff = _staffs[index];
      double remaining = staff.salary - amountPaid;
      staff.pendingSalary = remaining; // positive means pending, negative means advance
      notifyListeners();
    }
  }

  /// Get staff by id
  StaffModel? getStaffById(String id) {
    try {
      return _staffs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

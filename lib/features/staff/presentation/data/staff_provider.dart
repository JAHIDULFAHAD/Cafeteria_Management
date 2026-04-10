import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../Data/Model/staff_model.dart';

class StaffProvider with ChangeNotifier {
  final List<StaffModel> _staffs = [];
  List<StaffModel> get staffs => _staffs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'staffs';

  Stream<List<StaffModel>> loadStaffsFromFirestore() {
    // Listen to realtime updates from Firestore
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      _staffs.clear();
      for (var doc in snapshot.docs) {
        _staffs.add(StaffModel.fromFirestore(doc.id, doc.data()));
      }
      notifyListeners();
      return _staffs;
    });
  }

  // Add new staff to Firestore
  Future<void> addStaff({required String name, required double salary, String? uid}) async {
    final docRef = await _firestore.collection(_collection).add({
      'uid': uid ?? '',
      'name': name,
      'salary': salary,
      'pendingSalary': 0,
    });
    _staffs.add(StaffModel(
      id: docRef.id,
      uid: uid ?? '',
      name: name,
      salary: salary,
      pendingSalary: 0,
    ));
    notifyListeners();
  }

  // Edit staff in Firestore
  Future<void> editStaff(String id, String newName, double newSalary) async {
    await _firestore.collection(_collection).doc(id).update({
      'name': newName,
      'salary': newSalary,
    });
    final index = _staffs.indexWhere((s) => s.id == id);
    if (index != -1) {
      _staffs[index].name = newName;
      _staffs[index].salary = newSalary;
      notifyListeners();
    }
  }

  // Delete staff from Firestore
  Future<void> deleteStaff(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
    _staffs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Pay salary (updates pendingSalary in Firestore)
  Future<void> paySalary(String id, double amountPaid) async {
    final staff = _staffs.firstWhere((s) => s.id == id, orElse: () => throw 'Staff not found');
    double remaining = staff.salary - amountPaid;
    await _firestore.collection(_collection).doc(id).update({
      'pendingSalary': remaining,
    });
    staff.pendingSalary = remaining;
    notifyListeners();
  }

  StaffModel? getStaffById(String id) {
    try {
      return _staffs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

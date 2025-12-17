import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../Data/Model/sell_model.dart';
import '../../../../Data/Model/purchase_model.dart';
import '../../../../Data/Model/expense_model.dart';

class SellProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<SellModel> _sells = [];
  final List<PurchaseModel> _purchases = [];
  final List<ExpenseModel> _expenses = [];

  StreamSubscription<QuerySnapshot>? _sellSubscription;
  StreamSubscription<QuerySnapshot>? _purchaseSubscription;
  StreamSubscription<QuerySnapshot>? _expenseSubscription;

  bool _isLoading = false;
  bool _isInitialized = false;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  List<SellModel> get sells => List.unmodifiable(_sells);
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _setLoading(false);
      return;
    }

    try {
      await _sellSubscription?.cancel();
      await _purchaseSubscription?.cancel();
      await _expenseSubscription?.cancel();

      _sellSubscription = _firestore
          .collection('sells')
          .where('uid', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) async {
        _sells
          ..clear()
          ..addAll(snapshot.docs.map((doc) => SellModel.fromDoc(doc.id, doc.data())));
        await _recalculateAllNetCash();
        notifyListeners();
      }, onError: (_) {
        _setLoading(false);
        notifyListeners();
      });

      _purchaseSubscription = _firestore
          .collection('purchases')
          .where('uid', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        _purchases
          ..clear()
          ..addAll(snapshot.docs.map((doc) => PurchaseModel.fromDoc(doc.id, doc.data())));
        _recalculateAllNetCash();
        notifyListeners();
      }, onError: (_) => notifyListeners());

      _expenseSubscription = _firestore
          .collection('expenses')
          .where('uid', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        _expenses
          ..clear()
          ..addAll(snapshot.docs.map((doc) => ExpenseModel.fromDoc(doc.id, doc.data())));
        _recalculateAllNetCash();
        notifyListeners();
      }, onError: (_) => notifyListeners());

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print("SellProvider initialize error: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addOrUpdateSell({
    required DateTime date,
    required double amount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _setLoading(true);
    try {
      final docId = "${user.uid}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final existingIndex = _sells.indexWhere((s) =>
      s.id == docId ||
          (s.uid == user.uid &&
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day));

      SellModel sell;

      if (existingIndex != -1) {
        sell = _sells[existingIndex];
        sell.amount = amount;
      } else {
        sell = SellModel(
          id: docId,
          uid: user.uid,
          date: date,
          amount: amount,
          netCash: 0.0,
        );
        _sells.add(sell);
      }

      sell.netCash = amount -
          (_getPurchaseTotalByDate(date) + _getExpenseTotalByDate(date));

      await _firestore
          .collection('sells')
          .doc(sell.id)
          .set(sell.toMap(), SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("addOrUpdateSell error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // নতুন: Delete Sell
  Future<void> deleteSell({required DateTime date}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _setLoading(true);
    try {
      final docId = "${user.uid}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      await _firestore.collection('sells').doc(docId).delete();

      _sells.removeWhere((s) =>
      s.id == docId ||
          (s.uid == user.uid &&
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day));

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("deleteSell error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  SellModel? getSellByDate(DateTime date) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    for (var sell in _sells) {
      if (sell.uid == user.uid &&
          sell.date.year == date.year &&
          sell.date.month == date.month &&
          sell.date.day == date.day) {
        return sell;
      }
    }
    return null;
  }

  double getNetCashForDate(DateTime date) {
    final sell = getSellByDate(date);
    if (sell != null) {
      return sell.netCash;
    }
    return -(_getPurchaseTotalByDate(date) + _getExpenseTotalByDate(date));
  }

  List<SellModel> getMonthlySellList(int year, int month) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    return _sells
        .where((s) =>
    s.uid == user.uid && s.date.year == year && s.date.month == month)
        .toList();
  }

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

  Future<void> _recalculateAllNetCash() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (var sell in _sells) {
      final newNetCash = sell.amount -
          (_getPurchaseTotalByDate(sell.date) + _getExpenseTotalByDate(sell.date));
      if ((sell.netCash - newNetCash).abs() > 0.01) {
        sell.netCash = newNetCash;
        await _firestore
            .collection('sells')
            .doc(sell.id)
            .set({'netCash': newNetCash}, SetOptions(merge: true));
      }
    }
  }

  void clearData() {
    _sells.clear();
    _purchases.clear();
    _expenses.clear();
    _sellSubscription?.cancel();
    _purchaseSubscription?.cancel();
    _expenseSubscription?.cancel();
    _sellSubscription = null;
    _purchaseSubscription = null;
    _expenseSubscription = null;
    _isInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sellSubscription?.cancel();
    _purchaseSubscription?.cancel();
    _expenseSubscription?.cancel();
    super.dispose();
  }
}
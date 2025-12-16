import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Data/Model/sell_model.dart';
import '../../Data/Model/purchase_model.dart';
import '../../Data/Model/expense_model.dart';

class SellProvider with ChangeNotifier {
  final List<SellModel> _sells = [];
  List<SellModel> get sells => List.unmodifiable(_sells);

  final List<PurchaseModel> _purchases = [];
  final List<ExpenseModel> _expenses = [];

  StreamSubscription<QuerySnapshot>? _sellSubscription;

  /// 🔹 Load sells from cache first, then start realtime listener
  Future<void> loadSellOnStart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Load from cache
    final cacheSnapshot = await FirebaseFirestore.instance
        .collection("sells")
        .where("uid", isEqualTo: user.uid)
        .get(const GetOptions(source: Source.cache));

    if (cacheSnapshot.docs.isNotEmpty) {
      _sells
        ..clear()
        ..addAll(cacheSnapshot.docs
            .map((d) => SellModel.fromDoc(d.id, d.data())));
      notifyListeners();
    }

    // Start realtime listener
    _initRealtimeListener(user.uid);
  }

  void _initRealtimeListener(String uid) {
    _sellSubscription?.cancel();

    _sellSubscription = FirebaseFirestore.instance
        .collection("sells")
        .where("uid", isEqualTo: uid)
        .snapshots()
        .listen((snapshot) async {
      _sells
        ..clear()
        ..addAll(snapshot.docs.map((d) => SellModel.fromDoc(d.id, d.data())));

      // Recalculate netCash based on current purchases/expenses
      await _recalculateAllNetCash();
      notifyListeners();
    });
  }

  /// 🔹 Add or update sell
  Future<void> addOrUpdateSell(DateTime date, double amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Find existing sell
    final index = _sells.indexWhere((s) =>
    s.uid == uid &&
        s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day);

    SellModel sell;
    final docId = "${uid}_${date.year}-${date.month}-${date.day}";

    if (index != -1) {
      // Update existing
      sell = _sells[index];
      sell.amount = amount;
    } else {
      // Create new
      sell = SellModel(
        id: docId,
        uid: uid,
        date: date,
        amount: amount,
        netCash: 0.0, // will recalc below
      );
      _sells.add(sell);
    }

    // Calculate netCash
    sell.netCash = amount - (_getPurchaseTotalByDate(date) + _getExpenseTotalByDate(date));

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection("sells")
        .doc(sell.id)
        .set(sell.toMap(), SetOptions(merge: true));

    notifyListeners();
  }

  /// 🔹 Get sell by date
  SellModel? getSellByDate(DateTime date) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      return _sells.firstWhere((s) =>
      s.uid == uid &&
          s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Monthly sells
  List<SellModel> getMonthlySellList(int month, int year) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _sells
        .where((s) => s.uid == uid && s.date.month == month && s.date.year == year)
        .toList();
  }

  double getMonthlyTotalSell(int month, int year) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _sells
        .where((s) => s.uid == uid && s.date.month == month && s.date.year == year)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  /// 🔹 Purchase & expense helpers
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

  /// 🔹 Update purchases or expenses & recalc netCash
  Future<void> updatePurchases(List<PurchaseModel> newPurchases) async {
    _purchases
      ..clear()
      ..addAll(newPurchases);
    await _recalculateAllNetCash();
  }

  Future<void> updateExpenses(List<ExpenseModel> newExpenses) async {
    _expenses
      ..clear()
      ..addAll(newExpenses);
    await _recalculateAllNetCash();
  }

  /// 🔹 Recalculate netCash for all sells and sync with Firestore
  Future<void> _recalculateAllNetCash() async {
    for (var s in _sells) {
      s.netCash = s.amount - (_getPurchaseTotalByDate(s.date) + _getExpenseTotalByDate(s.date));

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('sells')
          .doc(s.id)
          .set(s.toMap(), SetOptions(merge: true));
    }
  }

  /// 🔹 Clear all data on logout
  void clearData() {
    _sells.clear();
    _sellSubscription?.cancel();
    _sellSubscription = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sellSubscription?.cancel();
    super.dispose();
  }
}

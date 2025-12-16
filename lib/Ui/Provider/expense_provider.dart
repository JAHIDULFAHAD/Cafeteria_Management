import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Data/Model/expense_model.dart';
import 'sell_provider.dart';

class ExpenseProvider with ChangeNotifier {
  final SellProvider sellProvider;
  final List<ExpenseModel> _expenses = [];
  StreamSubscription<QuerySnapshot>? _expenseSubscription;

  ExpenseProvider({required this.sellProvider});

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  /// 🔹 Initialize real-time listener
  void init(String uid) {
    _expenseSubscription?.cancel();
    _expenseSubscription = FirebaseFirestore.instance
        .collection('expenses')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      _expenses
        ..clear()
        ..addAll(snapshot.docs
            .map((doc) => ExpenseModel.fromDoc(doc.id, doc.data())));

      // Auto-update SellProvider netCash
      sellProvider.updateExpenses(_expenses);

      notifyListeners();
    });
  }

  /// 🔹 Add expense
  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
  }) async {
    if (title.isEmpty || amount <= 0) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('expenses').doc();
    final expense = ExpenseModel(
      id: docRef.id,
      uid: user.uid,
      title: title,
      amount: amount,
      date: date,
    );

    await docRef.set(expense.toMap());
  }

  /// 🔹 Edit expense
  Future<void> editExpense({
    required String id,
    required String newTitle,
    required double newAmount,
    required DateTime newDate,
  }) async {
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(id)
        .update({'title': newTitle, 'amount': newAmount, 'date': newDate});
  }

  /// 🔹 Delete expense
  Future<void> deleteExpense(String id) async {
    await FirebaseFirestore.instance.collection('expenses').doc(id).delete();
  }

  /// 🔹 Get monthly expenses
  List<ExpenseModel> getMonthlyExpenses(int year, int month) {
    return _expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  /// 🔹 Get monthly total
  double getMonthlyTotalExpense(int year, int month) {
    return getMonthlyExpenses(year, month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// 🔹 Get daily totals for a month
  Map<DateTime, double> getDailyTotalsForMonth(int year, int month) {
    final Map<DateTime, double> dailyTotals = {};
    for (var e in _expenses) {
      if (e.date.year == year && e.date.month == month) {
        final day = DateTime(e.date.year, e.date.month, e.date.day);
        dailyTotals[day] = (dailyTotals[day] ?? 0) + e.amount;
      }
    }
    return dailyTotals;
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}


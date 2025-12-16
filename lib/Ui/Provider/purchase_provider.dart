import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Data/Model/purchase_model.dart';
import 'sell_provider.dart';

class PurchaseProvider with ChangeNotifier {
  final SellProvider sellProvider;
  final CollectionReference _purchaseCollection =
  FirebaseFirestore.instance.collection('purchases');

  List<PurchaseModel> _purchases = [];
  StreamSubscription<QuerySnapshot>? _purchaseSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  PurchaseProvider({required this.sellProvider});

  List<PurchaseModel> get purchases => List.unmodifiable(_purchases);

  /// 🔹 Initialize real-time listener with shimmer loading
  void init(String uid) {
    _isLoading = true;
    notifyListeners();

    _purchaseSubscription?.cancel();
    _purchaseSubscription = _purchaseCollection
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) async {
      await Future.delayed(const Duration(milliseconds: 500));

      _purchases = snapshot.docs
          .map((doc) => PurchaseModel.fromDoc(
          doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Update SellProvider netCash
      sellProvider.updatePurchases(_purchases);

      _isLoading = false; // Data loaded
      notifyListeners();
    });
  }

  /// 🔹 Add purchase
  Future<void> addPurchase({
    required String uid,
    required String item,
    required double amount,
    required DateTime date,
  }) async {
    _isLoading = true;
    notifyListeners();
    final docRef = _purchaseCollection.doc();
    final purchase = PurchaseModel(
      id: docRef.id,
      uid: uid,
      item: item,
      amount: amount,
      date: date,
    );

    await docRef.set(purchase.toMap());
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Edit purchase
  Future<void> editPurchase({
    required String id,
    required String item,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _purchaseCollection.doc(id).update({'item': item, 'amount': amount});
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Delete purchase
  Future<void> deletePurchase(String id) async {
    _isLoading = true;
    notifyListeners();
    await _purchaseCollection.doc(id).delete();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Get purchases by specific day
  List<PurchaseModel> getByDateForUser(String uid, DateTime date) {
    return _purchases
        .where((p) =>
    p.uid == uid &&
        p.date.year == date.year &&
        p.date.month == date.month &&
        p.date.day == date.day)
        .toList();
  }

  /// 🔹 Get purchases for a specific month
  List<PurchaseModel> getMonthlyPurchases(int year, int month) {
    return _purchases
        .where((p) => p.date.year == year && p.date.month == month)
        .toList();
  }

  /// 🔹 Get daily totals for a month
  Map<DateTime, double> getDailyTotalsForMonth(int year, int month) {
    final Map<DateTime, double> dailyTotals = {};
    final filtered = getMonthlyPurchases(year, month);
    for (var p in filtered) {
      final day = DateTime(p.date.year, p.date.month, p.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + p.amount;
    }
    return dailyTotals;
  }

  /// 🔹 Get total purchase amount for a month
  double getMonthlyTotal(int year, int month) {
    final monthlyPurchases = getMonthlyPurchases(year, month);
    return monthlyPurchases.fold(0.0, (sum, p) => sum + p.amount);
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

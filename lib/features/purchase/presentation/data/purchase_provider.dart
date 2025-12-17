import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../Data/Model/purchase_model.dart';

class PurchaseProvider with ChangeNotifier {
  final CollectionReference _purchaseCollection =
  FirebaseFirestore.instance.collection('purchases');

  // Private state
  final List<PurchaseModel> _purchases = [];
  StreamSubscription<QuerySnapshot>? _purchaseSubscription;

  bool _isLoading = false;
  bool _isInitialized = false;

  // Public getters
  bool get isLoading => _isLoading;
  List<PurchaseModel> get purchases => List.unmodifiable(_purchases);

  /// Initialize real-time listener (only once)
  Future<void> initialize(String uid) async {
    if (_isInitialized) return;

    _setLoading(true);

    try {
      await _purchaseSubscription?.cancel();
      _purchaseSubscription = _purchaseCollection
          .where('uid', isEqualTo: uid)
          .snapshots()
          .listen(
            (snapshot) {
          _purchases.clear();
          _purchases.addAll(snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return PurchaseModel.fromDoc(doc.id, data);
          }));

          _setLoading(false);
          _isInitialized = true;
          notifyListeners();
        },
        onError: (error) {
          _setLoading(false);
          notifyListeners();
        },
      );
    } catch (e) {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Helper to safely update loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Add purchase
  Future<void> addPurchase({
    required String uid,
    required String item,
    required double amount,
    required DateTime date,
  }) async {
    _setLoading(true);

    try {
      final docRef = _purchaseCollection.doc();
      final purchase = PurchaseModel(
        id: docRef.id,
        uid: uid,
        item: item,
        amount: amount,
        date: date,
      );

      await docRef.set(purchase.toMap());
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Edit purchase
  Future<void> editPurchase({
    required String id,
    required String item,
    required double amount,
  }) async {
    _setLoading(true);

    try {
      await _purchaseCollection.doc(id).update({
        'item': item,
        'amount': amount,
      });
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete purchase
  Future<void> deletePurchase(String id) async {
    _setLoading(true);

    try {
      await _purchaseCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Query methods
  List<PurchaseModel> getByDate(String uid, DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    return _purchases.where((p) {
      final pDate = DateTime(p.date.year, p.date.month, p.date.day);
      return p.uid == uid && pDate == target;
    }).toList();
  }

  List<PurchaseModel> getMonthlyPurchases(int year, int month) {
    return _purchases
        .where((p) => p.date.year == year && p.date.month == month)
        .toList();
  }

  Map<DateTime, double> getDailyTotalsForMonth(int year, int month) {
    final Map<DateTime, double> totals = {};
    for (final p in getMonthlyPurchases(year, month)) {
      final day = DateTime(p.date.year, p.date.month, p.date.day);
      totals[day] = (totals[day] ?? 0) + p.amount;
    }
    return totals;
  }

  double getMonthlyTotal(int year, int month) {
    return getMonthlyPurchases(year, month)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

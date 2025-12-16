import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Data/Model/item_model.dart';

class ItemProvider with ChangeNotifier {
  final CollectionReference _itemsCollection =
  FirebaseFirestore.instance.collection("items");

  List<ItemModel> _items = [];
  List<ItemModel> get items => List.unmodifiable(_items);

  StreamSubscription<QuerySnapshot>? _itemSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  /// 🔹 Initialize real-time listener with uid
  void init(String uid) {
    _isLoading = true;
    notifyListeners();

    _itemSubscription?.cancel();
    _itemSubscription = _itemsCollection
        .where("uid", isEqualTo: uid)
        .snapshots()
        .listen((snapshot) async {
      await Future.delayed(const Duration(milliseconds: 300));
      _items = snapshot.docs
          .map((doc) => ItemModel.fromDoc(
          doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    });
  }

  /// 🔹 Add item
  Future<void> addItem(String uid, String name) async {
    if (name.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    final docRef = _itemsCollection.doc();
    await docRef.set({"uid": uid, "name": name});
    await Future.delayed(const Duration(milliseconds: 300));

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Delete item
  Future<void> deleteItem(String id) async {
    _isLoading = true;
    notifyListeners();

    await _itemsCollection.doc(id).delete();
    await Future.delayed(const Duration(milliseconds: 300));

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Data/Model/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;


  Future<void> loadUserOnStart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;


    final cacheDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(const GetOptions(source: Source.cache));

    if (cacheDoc.exists) {
      _currentUser = UserModel.fromMap(cacheDoc);
      notifyListeners();
    }

    init(user.uid);
  }

  /// --- REAL-TIME LISTENER ---
  void init(String uid) {
    _userStreamSubscription?.cancel();

    _userStreamSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _currentUser = UserModel.fromMap(snapshot);
        notifyListeners();
      }
    });
  }

  /// --- UPDATE USER ---
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .set(updatedUser.toMap(), SetOptions(merge: true));

      // Local update
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      print("Update Error: $e");
      rethrow;
    }
  }

  /// Logout
  void clearUser() {
    _currentUser = null;
    _userStreamSubscription?.cancel();
    _userStreamSubscription = null;
    notifyListeners();
  }
}

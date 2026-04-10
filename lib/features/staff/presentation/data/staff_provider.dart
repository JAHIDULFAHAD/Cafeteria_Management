import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../Data/Model/staff_model.dart';

class StaffProvider with ChangeNotifier {
  final CollectionReference _staffCollection =
  FirebaseFirestore.instance.collection('staffs');

  // Private state
  final List<StaffModel> _staffs = [];
  StreamSubscription<QuerySnapshot>? _staffSubscription;

  bool _isLoading = false;
  bool _isInitialized = false;

  // Public getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized; // Exposed safely for UI use
  List<StaffModel> get staffs => List.unmodifiable(_staffs);

  /// Initialize real-time listener (only once)
  /// Initialize real-time listener (only once) - filtered by current user's UID
  Future<void> initialize() async {
    if (_isInitialized) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('No user logged in. Cannot load staff.');
      _isInitialized = true;
      notifyListeners();
      return;
    }

    final String currentUid = currentUser.uid;

    _setLoading(true);

    try {
      await _staffSubscription?.cancel();
      _staffSubscription = _staffCollection
          .where('uid', isEqualTo: currentUid)
          .snapshots()
          .listen(
            (snapshot) {
          _staffs.clear();
          _staffs.addAll(snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return StaffModel.fromFirestore(doc.id, data);
          }));

          _setLoading(false);
          _isInitialized = true;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in staff stream: $error');
          _setLoading(false);
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error initializing staff listener: $e');
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

  /// Add new staff
  Future<void> addStaff({
    required String name,
    required double salary,
    required String uid,
  }) async {
    _setLoading(true);

    try {
      final docRef = _staffCollection.doc();
      final staffData = {
        'uid': uid,
        'name': name,
        'salary': salary,
        'pendingSalary': salary,
      };

      await docRef.set(staffData);
    } catch (e) {
      debugPrint('Error adding staff: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Edit staff (name and salary only)
  Future<void> editStaff({
    required String id,
    required String newName,
    required double newSalary,
  }) async {
    _setLoading(true);

    try {
      await _staffCollection.doc(id).update({
        'name': newName,
        'salary': newSalary,
      });
    } catch (e) {
      debugPrint('Error editing staff: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete staff
  Future<void> deleteStaff(String id) async {
    _setLoading(true);

    try {
      await _staffCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting staff: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Pay salary (safely reduce pendingSalary using transaction)
  Future<void> paySalary({
    required String id,
    required double amountPaid,
  }) async {
    _setLoading(true);

    try {
      final docRef = _staffCollection.doc(id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Staff not found');
        }

        final currentPending =
            (snapshot.get('pendingSalary') as num?)?.toDouble() ?? 0.0;
        final newPending = currentPending - amountPaid;

        if (newPending < 0) {
          throw Exception('Payment amount exceeds pending salary');
        }

        transaction.update(docRef, {'pendingSalary': newPending});
      });
    } catch (e) {
      debugPrint('Error paying salary: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get total monthly salary (sum of all fixed salaries)
  double getTotalMonthlySalary() {
    return _staffs.fold(0.0, (sum, staff) => sum + staff.salary);
  }

  /// Get total pending salary across all staff
  double getTotalPendingSalary() {
    return _staffs.fold(
        0.0, (sum, staff) => sum + (staff.pendingSalary ?? 0.0));
  }

  @override
  void dispose() {
    _staffSubscription?.cancel();
    super.dispose();
  }
}
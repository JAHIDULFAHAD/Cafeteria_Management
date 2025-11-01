import 'package:flutter/material.dart';
import '../../Data/Model/user_model.dart';
import 'package:collection/collection.dart'; // for firstWhereOrNull

class UserProvider with ChangeNotifier {
  final List<UserModel> _users = [];

  List<UserModel> get users => _users;

  UserModel? _currentUser; // currently logged-in user
  UserModel? get currentUser => _currentUser;

  /// Add a new user
  void addUser(UserModel user) {
    _users.add(user);
    notifyListeners();
  }

  /// Get user by email, returns null if not found
  UserModel? getUserByEmail(String email) {
    return _users.firstWhereOrNull((user) => user.email == email);
  }

  /// Check if email already exists
  bool emailExists(String email) {
    return _users.any((user) => user.email == email);
  }

  /// Login and set current user
  bool login(String email, String password) {
    final user = getUserByEmail(email);
    if (user != null && user.password == password) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Logout current user
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Update user info
  void updateUser(UserModel updatedUser) {
    final index = _users.indexWhere((user) => user.email == updatedUser.email);
    if (index != -1) {
      _users[index] = updatedUser;

      // If updated user is the current user, update currentUser too
      if (_currentUser?.email == updatedUser.email) {
        _currentUser = updatedUser;
      }

      notifyListeners();
    }
  }
}

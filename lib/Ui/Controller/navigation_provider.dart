import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  Widget? _activePage;

  // Getter for the current bottom navigation index
  int get currentIndex => _currentIndex;

  // Getter for the currently active page (optional overlay page)
  Widget? get activePage => _activePage;

  /// Change the bottom navigation index
  /// Automatically resets any active page overlay
  void setIndex(int index) {
    if (_currentIndex == index) return; // avoid unnecessary rebuilds
    _currentIndex = index;
    _activePage = null; // reset overlay page
    notifyListeners();
  }

  /// Open a new page overlay on top of current tab
  void openPage(Widget page) {
    _activePage = page;
    notifyListeners();
  }

  /// Close the currently active page overlay
  void closePage() {
    if (_activePage == null) return;
    _activePage = null;
    notifyListeners();
  }
}

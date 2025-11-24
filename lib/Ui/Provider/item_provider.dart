import 'package:flutter/material.dart';

class ItemProvider extends ChangeNotifier {
  List<String> _items = [
    "Al Araba",
    "Vegetable",
    "Sonas",
    "Labenup",
    "Al Modina",
    "Rapa Meat",
    "Fish",
    "Olendo Papercup",
    "Noor Al Bahar",
    "Pran",
    "Others",
  ];

  List<String> get items => _items;

  void addItem(String item) {
    if (!_items.contains(item)) {
      _items.insert(0, item);
      notifyListeners();
    }
  }

  void deleteItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

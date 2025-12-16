import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String id;       // Firestore document ID
  final String uid;      // User ID
  final String item;     // Item name (ex: Rice, Sugar)
  final double amount;   // Purchase amount
  final DateTime date;   // Date of purchase

  PurchaseModel({
    required this.id,
    required this.uid,
    required this.item,
    required this.amount,
    required this.date,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "item": item,
      "amount": amount,
      "date": Timestamp.fromDate(date),
    };
  }

  // Factory constructor to create PurchaseModel from Firestore doc
  factory PurchaseModel.fromDoc(String id, Map<String, dynamic> data) {
    DateTime parsedDate;

    if (data["date"] is Timestamp) {
      parsedDate = (data["date"] as Timestamp).toDate();
    } else if (data["date"] is String) {
      parsedDate = DateTime.parse(data["date"]);
    } else {
      parsedDate = DateTime.now();
    }

    return PurchaseModel(
      id: id,
      uid: data["uid"] ?? "",
      item: data["item"] ?? "",
      amount: (data["amount"] ?? 0).toDouble(),
      date: parsedDate,
    );
  }

}

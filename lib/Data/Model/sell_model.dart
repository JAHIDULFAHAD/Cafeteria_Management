import 'package:cloud_firestore/cloud_firestore.dart';

class SellModel {
  String id;
  String uid;
  DateTime date;
  double amount;
  double netCash;

  SellModel({
    required this.id,
    required this.uid,
    required this.date,
    required this.amount,
    required this.netCash,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "date": Timestamp.fromDate(date),
      "amount": amount,
      "netCash": netCash,
    };
  }

  factory SellModel.fromDoc(String id, Map<String, dynamic> data) {
    DateTime sellDate;
    if (data["date"] is Timestamp) {
      sellDate = (data["date"] as Timestamp).toDate();
    } else if (data["date"] is String) {
      sellDate = DateTime.parse(data["date"]);
    } else {
      sellDate = DateTime.now();
    }
    return SellModel(
      id: id,
      uid: data["uid"],
      date: sellDate,
      amount: (data["amount"] ?? 0).toDouble(),
      netCash: (data["netCash"] ?? 0).toDouble(),
    );
  }
}

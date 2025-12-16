class ExpenseModel {
  String id;      // Firestore document ID
  String uid;     // User ID
  String title;
  double amount;
  DateTime date;

  ExpenseModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.amount,
    required this.date,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "title": title,
      "amount": amount,
      "date": date.toIso8601String(),
    };
  }

  // Create from Firestore Document
  factory ExpenseModel.fromDoc(String id, Map<String, dynamic> data) {
    return ExpenseModel(
      id: id,
      uid: data["uid"] ?? "",
      title: data["title"] ?? "",
      amount: (data["amount"] ?? 0).toDouble(),
      date: DateTime.parse(data["date"]),
    );
  }
}

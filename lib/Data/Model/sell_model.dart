class SellModel {
  DateTime date;
  double amount;
  double netCash; // purchase + expense বাদ দেওয়ার পর বাকি টাকাটা

  SellModel({
    required this.date,
    required this.amount,
    required this.netCash,
  });

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'amount': amount,
    'netCash': netCash,
  };

  factory SellModel.fromMap(Map<String, dynamic> map) {
    return SellModel(
      date: DateTime.parse(map['date']),
      amount: map['amount'] ?? 0.0,
      netCash: map['netCash'] ?? 0.0,
    );
  }
}

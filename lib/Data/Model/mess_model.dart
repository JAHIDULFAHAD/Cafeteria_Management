class MonthlyBillModel {
  String name;
  double massBill;
  double advanceBill;
  DateTime date;

  MonthlyBillModel({
    required this.name,
    required this.massBill,
    required this.advanceBill,
    required this.date,
  });

  // ✅ Remaining automatically calculate
  double get remaining => (massBill - advanceBill).clamp(0, double.infinity);

  // ✅ Paid automatically determine
  bool get paid => remaining <= 0;

  // ✅ Add partial payment
  void addPayment(double amount) {
    advanceBill += amount;
  }
}

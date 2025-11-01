import 'package:rukin_cafeteria/Data/Model/purchase_model.dart';

class MonthlyPurchaseModel {
  final int month;
  final int year;
  final List<DailyPurchaseModel> dailyPurchases;

  MonthlyPurchaseModel({
    required this.month,
    required this.year,
    required this.dailyPurchases,
  });

  double get totalAmount =>
      dailyPurchases.fold(0.0, (sum, p) => sum + p.amount);
}

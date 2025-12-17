import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/features/Screen/staff_manage_screen.dart';
import '../Provider/dashboard_controller.dart';
import '../Widget/build_action_button_widget.dart';
import '../Widget/build_summarycard.dart';
import '../purchase/presentation/screens/purchase_summary_screen.dart';
import 'expence_summary_screen.dart';
import 'meal_summary_screen.dart';
import 'net_cash_summary_screen.dart';
import '../sell/presentation/screens/sell_summary_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SUMMARY CARDS
            SizedBox(
              height: 250,
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal, // horizontal scroll
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  BuildSummaryWidget(
                    title: "Net Cash Today",
                    value: controller.todayNetCash,
                    icon: Icons.today,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  BuildSummaryWidget(
                    title: "Monthly Net Cash",
                    value: controller.monthlyNetCash,
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  BuildSummaryWidget(
                    title: "Monthly Sells",
                    value: controller.monthlyTotalSells,
                    icon: Icons.sell,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  BuildSummaryWidget(
                    title: "Monthly Purchases",
                    value: controller.monthlyTotalPurchases,
                    icon: Icons.shopping_cart,
                    color: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // QUICK ACTION BUTTONS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                BuildActionButtonWidget(
                  title: "NetCash Summary",
                  icon: Icons.bar_chart,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NetCashSummaryScreen()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Sells Summary",
                  icon: Icons.sell,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SellSummaryScreen()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Purchases Summary",
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PurchaseSummaryScreen()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Expenses Summary",
                  icon: Icons.monetization_on,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExpenseSummaryScreen()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Meal Summary",
                  icon: Icons.person_pin_rounded,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MealSummaryScreen()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Manage Staffs",
                  icon: Icons.person,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StaffManageScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

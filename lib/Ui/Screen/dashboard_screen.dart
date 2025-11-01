import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Screen/staff_screen.dart';
import '../Controller/dashboard_controller.dart';
import '../Widget/build_action_button_widget.dart';
import '../Widget/build_summarycard.dart';
import 'monthly_Purchase_screen.dart';
import 'monthly_expence_screen.dart';
import 'monthly_mess_screen.dart';
import 'monthly_net_cash_screen.dart';
import 'monthly_sell_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SUMMARY CARDS
            Row(
              children: [
                BuildSummaryWidget(
                  title: "Net Cash Today",
                  value: controller.todayNetCash,
                  icon: Icons.today,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                BuildSummaryWidget(
                  title: "Monthly Net Cash",
                  value: controller.monthlyNetCash,
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                BuildSummaryWidget(
                  title: "Monthly Sells",
                  value: controller.monthlyTotalSells,
                  icon: Icons.sell,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                BuildSummaryWidget(
                  title: "Monthly Purchases",
                  value: controller.monthlyTotalPurchases,
                  icon: Icons.shopping_cart,
                  color: Colors.red,
                ),
              ],
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
                  title: "Monthly Net Cash",
                  icon: Icons.bar_chart,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MonthlyNetCashView()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Monthly Sells",
                  icon: Icons.sell,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MonthlySellView()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Monthly Purchases",
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MonthlyPurchaseView()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Monthly Expenses",
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
                  title: "Monthly Mess",
                  icon: Icons.person_pin_rounded,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessRecordPage()),
                    );
                  },
                ),
                BuildActionButtonWidget(
                  title: "Staffs",
                  icon: Icons.person,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StaffManagementPage()),
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

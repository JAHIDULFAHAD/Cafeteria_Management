import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/navigation_provider.dart';
import '../Widget/appbar_widget.dart';
import 'add_mase_screen.dart';
import 'daily_expense_screen.dart';
import 'dashboard_screen.dart';
import 'daily_purchase_screen.dart';
import 'daily_sell_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    final pages = [
      const DashboardScreen(),
      const DailySellScreen(),
      const DailyPurchaseScreen(),
      const ExpenseEntryView(),
      const AddMessPage(),
    ];
    return Scaffold(
      appBar: AppbarWidget(),
      body: nav.activePage ?? pages[nav.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // <-- add this
        currentIndex: nav.currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          context.read<NavigationProvider>().setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Purchase'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Expense'),
          BottomNavigationBarItem(icon: Icon(Icons.person_pin_rounded), label: 'Mess'),
        ],
      ),
    );
  }
}

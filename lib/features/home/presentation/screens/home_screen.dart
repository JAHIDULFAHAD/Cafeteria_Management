import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/navigation_provider.dart';
import '../Widget/appbar_widget.dart';
import '../expense/presentation/screens/expense_entry_screen.dart';
import '../purchase/presentation/screens/purchase_entry_screen.dart';
import 'meal_entry_screen.dart';
import 'dashboard_screen.dart';
import '../sell/presentation/screens/sell_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    final pages = [
      const DashboardScreen(),
      const SellEntryScreen(),
      const PurchaseEntryScreen(),
      const ExpenseEntryScreen(),
      const MealEntryScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.person_pin_rounded), label: 'Meal'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Ui/Controller/dashboard_controller.dart';
import 'Ui/Controller/mass_provider.dart';
import 'Ui/Controller/navigation_provider.dart';
import 'Ui/Controller/purchase_provider.dart';
import 'Ui/Controller/expense_provider.dart';
import 'Ui/Controller/sell_provider.dart';
import 'Ui/Controller/staff_provider.dart';
import 'Ui/Controller/user_provider.dart';
import 'Ui/Screen/login_screen.dart';

class RukinCafeteria extends StatelessWidget {
  const RukinCafeteria({super.key});

  @override
  Widget build(BuildContext context) {
    final sellProvider = SellProvider(); // Single instance
    final purchaseProvider = PurchaseProvider(sellProvider: sellProvider);
    final expenseProvider = ExpenseProvider(sellProvider: sellProvider);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sellProvider),
        ChangeNotifierProvider(create: (_) => purchaseProvider),
        ChangeNotifierProvider(create: (_) => expenseProvider),
        ChangeNotifierProvider(
          create: (_) => DashboardController(
            sellProvider: sellProvider,
            purchaseProvider: purchaseProvider,
            expenseProvider: expenseProvider,
          ),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyBillProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rukin Cafeteria',
        theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.green.shade50,
        ),
        home: LoginScreen(),
      ),
    );
  }
}

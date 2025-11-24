import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Screen/purchase_item_manage_screen.dart';

import 'Ui/Provider/dashboard_controller.dart';
import 'Ui/Provider/item_provider.dart';
import 'Ui/Provider/meal_provider.dart';
import 'Ui/Provider/navigation_provider.dart';
import 'Ui/Provider/purchase_provider.dart';
import 'Ui/Provider/expense_provider.dart';
import 'Ui/Provider/sell_provider.dart';
import 'Ui/Provider/staff_provider.dart';
import 'Ui/Provider/user_provider.dart';
import 'Ui/Screen/home_screen.dart';
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
          create: (_) => DashboardProvider(
            sellProvider: sellProvider,
            purchaseProvider: purchaseProvider,
            expenseProvider: expenseProvider,
          ),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserOnStart()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rukin Cafeteria',
        theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.green.shade50,
          elevatedButtonTheme:ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            color: Colors.green.shade50,
          )
        ),
        home:  StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final uid = snapshot.data!.uid;
              final userProvider =
              Provider.of<UserProvider>(context, listen: false);
              // Auto fetch user on login
              userProvider.init(uid);
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

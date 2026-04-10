import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/dashboard/presentation/data/dashboard_controller.dart';
import 'features/expense/presentation/data/expense_provider.dart';
import 'features/meal/presentation/data/meal_provider.dart';
import 'features/Provider/navigation_provider.dart';
import 'features/purchase/presentation/data/item_provider.dart';
import 'features/purchase/presentation/data/purchase_provider.dart';
import 'features/sell/presentation/data/sell_provider.dart';
import 'features/staff/presentation/data/staff_provider.dart';
import 'features/auth/presentation/data/user_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
class RukinCafeteria extends StatelessWidget {
  const RukinCafeteria({super.key});

  @override
  Widget build(BuildContext context) {
    final sellProvider = SellProvider(); // Single instance
    final purchaseProvider = PurchaseProvider();
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 16),
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

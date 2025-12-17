import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Provider/expense_provider.dart';
import '../sell/presentation/data/sell_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';
import '../Widget/show_item_list_dialog.dart';
import '../Widget/total_card_widget.dart';

class ExpenseSummaryScreen extends StatefulWidget {
  const ExpenseSummaryScreen({super.key});

  @override
  State<ExpenseSummaryScreen> createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: const AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer2<ExpenseProvider, SellProvider>(
          builder: (context, expenseProvider, sellProvider, _) {
            // Get expense data
            final expenseList = expenseProvider.getMonthlyExpenses(selectedYear, selectedMonth);
            final totalExpense = expenseProvider.getMonthlyTotalExpense(selectedYear, selectedMonth);
            final dailyTotals = expenseProvider.getDailyTotalsForMonth(selectedYear, selectedMonth);

            // Calculate daily netCash using SellProvider
            final Map<DateTime, double> dailyNetCash = {};
            for (var date in dailyTotals.keys) {
              final sell = sellProvider.getSellByDate(date);
              if (sell != null) {
                dailyNetCash[date] = sell.netCash;
              } else {
                dailyNetCash[date] = sellProvider.getNetCashForDate(date);
              }
            }

            // Calculate monthly netCash
            double monthlyNetCash = 0.0;
            final monthlySells = sellProvider.getMonthlySellList(selectedYear, selectedMonth);
            for (var sell in monthlySells) {
              monthlyNetCash += sell.netCash;
            }

            final monthName = DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth));

            return Column(
              children: [
                PageTitleWidget(
                    title: "Monthly Expense Summary - $monthName $selectedYear"),
                const SizedBox(height: 20),

                // Month & Year Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<int>(
                            value: selectedMonth,
                            underline: const SizedBox(),
                            isExpanded: true,
                            items: List.generate(12, (i) => i + 1)
                                .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(DateFormat.MMMM().format(DateTime(2024, m))),
                            ))
                                .toList(),
                            onChanged: (val) => setState(() {
                              selectedMonth = val!;
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<int>(
                            value: selectedYear,
                            underline: const SizedBox(),
                            isExpanded: true,
                            items: [2024, 2025, 2026]
                                .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text("$y"),
                            ))
                                .toList(),
                            onChanged: (val) => setState(() {
                              selectedYear = val!;
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Daily totals list
                Expanded(
                  child: dailyTotals.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money_off, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No Expense Records Found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ListView(
                    children: dailyTotals.entries.map((entry) {
                      final date = entry.key;
                      final expenseAmount = entry.value;
                      final netCash = dailyNetCash[date];

                      final dayExpenses = expenseProvider.expenses
                          .where((e) =>
                      e.date.year == date.year &&
                          e.date.month == date.month &&
                          e.date.day == date.day)
                          .toList();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          onTap: () {
                            showItemListDialog(
                              context: context,
                              title: "Expenses",
                              date: date,
                              items: dayExpenses,
                              itemName: (e) => e.title,
                              itemAmount: (e) => e.amount,
                              iconColor: Colors.green,
                              icon: Icons.receipt_long,
                              primaryColor: Colors.green,
                            );
                          },
                          leading: const Icon(Icons.calendar_today, color: Colors.green),
                          title: Text(
                            DateFormat.yMMMMd().format(date),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text("Tap to view details"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Exp: AED ${expenseAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (netCash != null)
                                Text(
                                  "Net: AED ${netCash.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Monthly Total Card
                TotalCardWidget(
                  total: totalExpense,
                  title:
                  "Monthly Total Expense\nMonthly NetCash: AED ${monthlyNetCash.toStringAsFixed(2)}",
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

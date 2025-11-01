import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Controller/expense_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';
import '../Widget/daily_detail_dialog_widget.dart';
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
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    // 🔹 Monthly expense list
    final expenseList =
    expenseProvider.getMonthlyExpenses(selectedYear, selectedMonth);

    // 🔹 Monthly total
    final total =
    expenseProvider.getMonthlyTotalExpense(selectedYear, selectedMonth);

    // 🔹 Daily totals
    final dailyTotals =
    expenseProvider.getDailyTotalsForMonth(selectedYear, selectedMonth);

    final monthName =
    DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth));

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PageTitleWidget(
                title: "Monthly Expense Summary - $monthName $selectedYear"),
            const SizedBox(height: 20),

            // 🔹 Month & Year Dropdowns (Card style)
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        underline: const SizedBox(),
                        isExpanded: true,
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                              DateFormat.MMMM().format(DateTime(2024, m))),
                        ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedMonth = val!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.green.shade50,
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
                        onChanged: (val) => setState(() => selectedYear = val!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Daily totals list
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
                  final amount = entry.value;

                  // 🔹 Get list of expenses for this day
                  final dayExpenses = expenseProvider.expenses
                      .where((e) =>
                  e.date.year == date.year &&
                      e.date.month == date.month &&
                      e.date.day == date.day)
                      .toList();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      onTap: () {
                        showItemListDialog(
                          context: context,
                          title: "Expenses",
                          date: date,
                          items: dayExpenses,
                          itemName: (e) => e.title,
                          itemAmount: (e) =>
                              e.amount.toStringAsFixed(2),
                          iconColor: Colors.green,
                          icon: Icons.receipt_long,
                          primaryColor: Colors.green,
                        );
                      },
                      leading:
                      const Icon(Icons.calendar_today, color: Colors.green),
                      title: Text(
                        DateFormat.yMMMMd().format(date),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text("Tap to view details"),
                      trailing: Text(
                        "AED ${amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // 🔹 Monthly Total Card
            TotalCardWidget(total: total, title: "Monthly Total Expense"),
          ],
        ),
      ),
    );
  }
}

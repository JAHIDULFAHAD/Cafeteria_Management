import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../expense/presentation/data/expense_provider.dart';
import '../data/sell_provider.dart';
import '../../../Widget/Page_Title_widget.dart';
import '../../../Widget/appbar_widget.dart';
import '../../../Widget/total_card_widget.dart';

class NetCashSummaryScreen extends StatefulWidget {
  const NetCashSummaryScreen({super.key});

  @override
  State<NetCashSummaryScreen> createState() => _NetCashSummaryScreenState();
}

class _NetCashSummaryScreenState extends State<NetCashSummaryScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final sellProvider = Provider.of<SellProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    // Selected month-এর sell list
    final monthSells = sellProvider.getMonthlySellList(selectedMonth, selectedYear);

    // প্রতিদিনের net cash
    final dailyNetCash = <DateTime, double>{};
    for (var s in monthSells) {
      dailyNetCash[s.date] = s.netCash;
    }

    // মাসের total net cash
    final totalNetCash = monthSells.fold(0.0, (sum, s) => sum + s.netCash);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PageTitleWidget(title: "Monthly Net Cash Report - ${DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth))} $selectedYear"),
            const SizedBox(height: 20),

            // Month & Year Dropdown
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        underline: const SizedBox(),
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(DateFormat.MMMM().format(DateTime(0, m))),
                        ))
                            .toList(),
                        onChanged: (val) => setState(() => selectedMonth = val!),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<int>(
                        value: selectedYear,
                        underline: const SizedBox(),
                        items: [2024, 2025, 2026]
                            .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
                            .toList(),
                        onChanged: (val) => setState(() => selectedYear = val!),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Daily Net Cash List
            Expanded(
              child: dailyNetCash.isEmpty
                  ? const Center(
                child: Text("No Net Cash Records Found",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              )
                  : ListView.builder(
                itemCount: dailyNetCash.length,
                itemBuilder: (context, index) {
                  final date = dailyNetCash.keys.elementAt(index);
                  final netCash = dailyNetCash[date]!;
                  final color = netCash >= 0 ? Colors.green : Colors.red;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.green),
                      title: Text("${DateFormat.d().format(date)} ${DateFormat.MMMM().format(date)} ${date.year}"),
                      trailing: Text(
                        "৳${netCash.toStringAsFixed(2)}",
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Total Monthly Net Cash
            TotalCardWidget(total: totalNetCash, title: "Monthly Total Net Cash"),
          ],
        ),
      ),
    );
  }
}

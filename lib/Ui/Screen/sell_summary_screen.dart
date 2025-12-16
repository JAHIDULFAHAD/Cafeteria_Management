import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/sell_provider.dart';
import 'package:intl/intl.dart';

import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';
import '../Widget/total_card_widget.dart';

class SellSummaryScreen extends StatefulWidget {
  const SellSummaryScreen({super.key});

  @override
  State<SellSummaryScreen> createState() => _SellSummaryScreenState();
}

class _SellSummaryScreenState extends State<SellSummaryScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellProvider>(context);
    final monthList = provider.getMonthlySellList(selectedMonth, selectedYear);
    final total = provider.getMonthlyTotalSell(selectedMonth, selectedYear);

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
              title: "Monthly Sells Report - $monthName $selectedYear",
            ),
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
                          child: Text(DateFormat.MMMM()
                              .format(DateTime(0, m))),
                        ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedMonth = val);
                          }
                        },
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
                            .map((y) =>
                            DropdownMenuItem(value: y, child: Text("$y")))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedYear = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Monthly Sell List
            Expanded(
              child: monthList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sell, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No Sell Records Found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: monthList.length,
                itemBuilder: (context, index) {
                  final s = monthList[index];
                  Color netCashColor =
                  s.netCash >= 0 ? Colors.green : Colors.red;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading:
                      const Icon(Icons.sell, color: Colors.green),
                      title: Text(
                          "${DateFormat.d().format(s.date)} ${DateFormat.MMMM().format(s.date)} ${s.date.year}"),
                      subtitle: Text(
                        "Net Cash: AED ${s.netCash.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: netCashColor),
                      ),
                      trailing: Text(
                        "AED ${s.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Monthly Total Card
            TotalCardWidget(total: total, title: "Monthly Total Sells"),
          ],
        ),
      ),
    );
  }
}

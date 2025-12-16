import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Provider/purchase_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';
import '../Widget/daily_detail_dialog_widget.dart';
import '../Widget/total_card_widget.dart';

class PurchaseSummaryScreen extends StatefulWidget {
  const PurchaseSummaryScreen({super.key});

  @override
  State<PurchaseSummaryScreen> createState() => _PurchaseSummaryScreenState();
}

class _PurchaseSummaryScreenState extends State<PurchaseSummaryScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: const AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<PurchaseProvider>(
          builder: (context, provider, _) {
            final dailyTotals = provider.getDailyTotalsForMonth(
              selectedYear,
              selectedMonth,
            );

            final monthlyTotal = provider.getMonthlyPurchases(
              selectedYear,
              selectedMonth,
            ).fold<double>(0.0, (sum, p) => sum + p.amount);

            final monthName =
            DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth));

            return Column(
              children: [
                PageTitleWidget(
                  title: "Monthly Purchase Summary - $monthName $selectedYear",
                ),
                const SizedBox(height: 20),

                // 🔹 Month & Year Dropdowns
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
                                  .format(DateTime(2024, m))),
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
                            onChanged: (val) =>
                                setState(() => selectedYear = val!),
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
                        Icon(Icons.shopping_bag,
                            size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No Purchase Records Found",
                          style:
                          TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ListView(
                    children: dailyTotals.entries.map((entry) {
                      final date = entry.key;
                      final amount = entry.value;

                      // 🔹 Get purchases for this day
                      final dayPurchases = provider.purchases
                          .where((p) =>
                      p.date.year == date.year &&
                          p.date.month == date.month &&
                          p.date.day == date.day)
                          .toList();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          onTap: () {
                            showItemListDialog(
                              context: context,
                              title: "Purchases",
                              date: date,
                              items: dayPurchases,
                              itemName: (p) => p.item,
                              itemAmount: (p) =>
                                  p.amount.toStringAsFixed(2),
                              iconColor: Colors.green,
                              icon: Icons.shopping_bag,
                              primaryColor: Colors.green,
                            );
                          },
                          leading: const Icon(Icons.calendar_today,
                              color: Colors.green),
                          title: Text(
                            DateFormat.yMMMMd().format(date),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
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
                TotalCardWidget(total: monthlyTotal, title: "Monthly Total Purchase"),
              ],
            );
          },
        ),
      ),
    );
  }
}

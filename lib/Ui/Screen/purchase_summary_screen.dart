import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/purchase_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';
import '../Widget/daily_detail_dialog_widget.dart';
import '../Widget/total_card_widget.dart';
import 'package:intl/intl.dart';

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
    final provider = Provider.of<PurchaseProvider>(context);
    final purchases = provider.purchases;

    // Filter by selected month/year
    final filteredPurchases = purchases
        .where((p) =>
    p.date.month == selectedMonth && p.date.year == selectedYear)
        .toList();

    // Group by day
    final grouped = <int, double>{};
    for (var p in filteredPurchases) {
      grouped[p.date.day] = (grouped[p.date.day] ?? 0) + p.amount;
    }

    final monthlyTotal =
    filteredPurchases.fold(0.0, (sum, p) => sum + p.amount);

    final monthName =
    DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth));

    return Scaffold(
      appBar: const AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PageTitleWidget(title: "Monthly Purchase Report - $monthName $selectedYear"),
            const SizedBox(height: 20),

            // Month & Year Dropdown (like MonthlySellView)
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        underline: const SizedBox(),
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                              DateFormat.MMMM().format(DateTime(2024, m))),
                        ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedMonth = val!),
                        isExpanded: true,
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
                        onChanged: (val) => setState(() => selectedYear = val!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Daily grouped list
            Expanded(
              child: grouped.isEmpty
                  ? const Center(
                child: Text("No purchases found for this month."),
              )
                  : ListView.builder(
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final day = grouped.keys.elementAt(index);
                  final total = grouped[day]!;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today,
                          color: Colors.green),
                      title: Text(
                        "Date: $day/$selectedMonth/$selectedYear",
                        style:
                        const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text("Tap to view details"),
                      trailing: Text(
                        "AED ${total.toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      onTap: () {
                        final dayPurchases = filteredPurchases
                            .where((p) => p.date.day == day)
                            .toList();
                        final date =
                        DateTime(selectedYear, selectedMonth, day);

                        showItemListDialog(
                          context: context,
                          title: "Purchases",
                          date: date,
                          items: dayPurchases,
                          itemName: (p) => p.item,
                          itemAmount: (p) => p.amount.toStringAsFixed(0),
                          iconColor: Colors.green,
                          icon: Icons.shopping_bag,
                          primaryColor: Colors.green,
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Monthly total card
            TotalCardWidget(
              total: monthlyTotal,
              title: "Monthly Total Purchase",
            ),
          ],
        ),
      ),
    );
  }
}

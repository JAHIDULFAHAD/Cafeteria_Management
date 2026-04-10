import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Provider/meal_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/add_payment_dialog_widget.dart';
import '../Widget/appbar_widget.dart';
import '../Widget/confirm_delete_dialog_widget.dart';
import '../Widget/edit_bill_buttom_sheet_widget.dart';

class MealSummaryScreen extends StatefulWidget {
  const MealSummaryScreen({Key? key}) : super(key: key);

  @override
  State<MealSummaryScreen> createState() => _MealSummaryScreenState();
}

class _MealSummaryScreenState extends State<MealSummaryScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final searchController = TextEditingController();

  // Helper function to get full month name
  String monthName(int month) => DateFormat.MMMM().format(DateTime(selectedYear, month));

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealProvider>(context);
    final billsForMonth = provider.getBillsForMonth(selectedYear, selectedMonth);

    final filteredBills = billsForMonth
        .where((bill) => bill.name.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();

    final total = provider.getMonthlyTotal(selectedYear, selectedMonth);
    final totalAdvance = provider.getMonthlyAdvance(selectedYear, selectedMonth);
    final totalRemaining = provider.getMonthlyRemaining(selectedYear, selectedMonth);
    final totalBills = billsForMonth.length;
    final paidCount = billsForMonth.where((b) => b.paid).length;
    final unpaidCount = billsForMonth.where((b) => !b.paid).length;

    return Scaffold(
      appBar: AppbarWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Title
              PageTitleWidget(
                  title: "Monthly Mess Bill - (${monthName(selectedMonth)} $selectedYear)"),
              const SizedBox(height: 20),

              // Month & Year Dropdown
              Row(
                children: [
                  // Month Dropdown
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          items: List.generate(12, (i) => i + 1)
                              .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(monthName(m)),
                          ))
                              .toList(),
                          onChanged: (val) => setState(() => selectedMonth = val!),
                          isExpanded: true,
                          underline: const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Year Dropdown
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<int>(
                          value: selectedYear,
                          items: List.generate(5, (i) => DateTime.now().year - i)
                              .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text("$y"),
                          ))
                              .toList(),
                          onChanged: (val) => setState(() => selectedYear = val!),
                          isExpanded: true,
                          underline: const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Search by Name",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Totals Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Total: AED $total"),
                          Text("Advance: AED $totalAdvance"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Remaining: AED $totalRemaining",
                              style: const TextStyle(color: Colors.red)),
                          Text("Mess Entries: $totalBills"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Paid: $paidCount",
                              style: const TextStyle(color: Colors.green)),
                          Text("Unpaid: $unpaidCount",
                              style: const TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bill List
              Expanded(
                child: filteredBills.isEmpty
                    ? const Center(child: Text("No bills found"))
                    : ListView.builder(
                  itemCount: filteredBills.length,
                  itemBuilder: (context, index) {
                    final bill = filteredBills[index];

                    return Card(
                      child: ListTile(
                        title: Text(bill.name),
                        subtitle: Text(
                            "Bill: ${bill.massBill} | Advance: ${bill.advanceBill} | Remaining: ${bill.remaining}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'Edit':
                                    showModalBottomSheet(
                                      backgroundColor: Colors.green.shade50,
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16)),
                                      ),
                                      builder: (context) =>
                                          EditBillBottomSheet(
                                              provider: provider,
                                              bill: bill),
                                    );
                                    break;
                                  case 'Delete':
                                    ConfirmDeleteDialogWidget.show(
                                      context,
                                      name: bill.name,
                                      description:
                                      'Are you sure you want to delete this bill?',
                                      onDelete: () {
                                        provider.deleteBill(bill);
                                        Navigator.pop(context);
                                      },
                                    );
                                    break;
                                  case 'Add Payment':
                                    showDialog(
                                      context: context,
                                      builder: (_) => AddPaymentDialog(
                                          provider: provider, bill: bill),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (context) {
                                List<PopupMenuEntry<String>> items = [
                                  const PopupMenuItem(
                                      value: 'Edit', child: Text('Edit')),
                                  const PopupMenuItem(
                                      value: 'Delete', child: Text('Delete')),
                                ];
                                if (bill.remaining > 0) {
                                  items.add(const PopupMenuItem(
                                      value: 'Add Payment',
                                      child: Text('Add Payment')));
                                }
                                return items;
                              },
                            ),
                            const SizedBox(width: 8),
                            bill.paid
                                ? const Icon(Icons.check_circle,
                                color: Colors.green)
                                : const Icon(Icons.pending,
                                color: Colors.orange),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

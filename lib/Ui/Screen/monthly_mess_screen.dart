import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Data/Model/mess_model.dart';
import '../Controller/mass_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';

class MessRecordPage extends StatefulWidget {
  const MessRecordPage({Key? key}) : super(key: key);

  @override
  State<MessRecordPage> createState() => _MessRecordPageState();
}

class _MessRecordPageState extends State<MessRecordPage> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final searchController = TextEditingController();

  final List<String> months = const [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  // ---------------- Add Payment Dialog with Validation ----------------
  void _showAddPaymentDialog(MonthlyBillProvider provider, MonthlyBillModel bill) {
    final payController = TextEditingController();
    final remaining = bill.remaining;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Payment for ${bill.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Remaining: ৳$remaining"),
            const SizedBox(height: 8),
            TextField(
              controller: payController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter payment amount"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final payment = double.tryParse(payController.text) ?? -1;

              if (payment <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid positive amount")),
                );
                return;
              }
              if (payment > remaining) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Payment cannot exceed remaining: ৳$remaining")),
                );
                return;
              }

              bill.addPayment(payment);
              provider.notifyListeners();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ---------------- Edit Bottom Sheet ----------------
  void _showBottomSheet(MonthlyBillProvider provider, MonthlyBillModel bill) {
    final nameCtrl = TextEditingController(text: bill.name);
    final massCtrl = TextEditingController(text: bill.massBill.toString());
    final advCtrl = TextEditingController(text: bill.advanceBill.toString());
    DateTime editDate = bill.date;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                ),
                Text("Edit Bill", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                const SizedBox(height: 8),
                TextField(controller: massCtrl, decoration: const InputDecoration(labelText: "Mass Bill"), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: advCtrl, decoration: const InputDecoration(labelText: "Advance Paid"), keyboardType: TextInputType.number),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 6),
                    Text(DateFormat('MMMM yyyy').format(editDate)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: editDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => editDate = picked);
                        }
                      },
                      child: const Text("Change Date"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () {
                    String name = nameCtrl.text.trim();
                    double mass = double.tryParse(massCtrl.text) ?? -1;
                    double advance = double.tryParse(advCtrl.text) ?? 0;

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Name cannot be empty")),
                      );
                      return;
                    }
                    if (mass < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Mass Bill must be positive")),
                      );
                      return;
                    }
                    if (advance < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Advance must be positive")),
                      );
                      return;
                    }

                    bill.name = name;
                    bill.massBill = mass;
                    bill.advanceBill = advance;
                    bill.date = editDate;

                    provider.notifyListeners();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MonthlyBillProvider>(context);
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
            children: [
              PageTitleWidget(title: "Monthly Mess Bill - (${months[selectedMonth-1]} $selectedYear)"),
              const SizedBox(height: 20),
              // Month & Year Dropdown
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          items: List.generate(12, (i) => i + 1)
                              .map((m) => DropdownMenuItem(value: m, child: Text(months[m-1])))
                              .toList(),
                          onChanged: (val) => setState(() => selectedMonth = val!),
                          isExpanded: true,
                          underline: const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<int>(
                          value: selectedYear,
                          items: List.generate(5, (i) => DateTime.now().year - i)
                              .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
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
                color: Colors.green.shade100,
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
                          Text("Remaining: AED $totalRemaining", style: const TextStyle(color: Colors.red)),
                          Text("Mess Entries: $totalBills"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Paid: $paidCount", style: const TextStyle(color: Colors.green)),
                          Text("Unpaid: $unpaidCount", style: const TextStyle(color: Colors.orange)),
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
                        subtitle: Text("Bill: ${bill.massBill} | Advance: ${bill.advanceBill} | Remaining: ${bill.remaining}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'Edit':
                                    _showBottomSheet(provider, bill);
                                    break;
                                  case 'Delete':
                                    provider.deleteBill(bill);
                                    break;
                                  case 'Add Payment':
                                    _showAddPaymentDialog(provider, bill);
                                    break;
                                }
                              },
                              itemBuilder: (context) {
                                List<PopupMenuEntry<String>> items = [
                                  const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                                ];
                                if (bill.remaining > 0) {
                                  items.add(const PopupMenuItem(value: 'Add Payment', child: Text('Add Payment')));
                                }
                                return items;
                              },
                            ),
                            const SizedBox(width: 8),
                            bill.paid
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.pending, color: Colors.orange),
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

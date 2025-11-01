import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/purchase_provider.dart';
import '../Controller/sell_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/item_list_card_widget.dart';
import '../Widget/total_card_widget.dart';
import 'monthly_Purchase_screen.dart';

class DailyPurchaseScreen extends StatefulWidget {
  const DailyPurchaseScreen({super.key});

  @override
  State<DailyPurchaseScreen> createState() => _DailyPurchaseScreenState();
}

class _DailyPurchaseScreenState extends State<DailyPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  String? selectedItem;
  int? editIndex;

  DateTime selectedDate = DateTime.now(); // ✅ Default = today's date

  final List<String> itemNames = [
    "Al Araba",
    "Vegetable",
    "Sonas",
    "Labenup",
    "Al Modina",
    "Rapa Meat",
    "Fish",
    "Olendo Papercup",
    "Noor Al Bahar",
    "Pran",
    "Others",
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // ✅ Default today
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final sellProvider = Provider.of<SellProvider>(context, listen: false);

    final dailyPurchases = purchaseProvider.getDailyByDate(selectedDate);
    final dailyTotal = dailyPurchases.fold(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PageTitleWidget(title: "Purchase Input - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})"),
            const SizedBox(height: 12),
            // Add/Edit Purchase form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ✅ Date Picker Field
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Select Date",
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedItem,
                        items: itemNames
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: "Select Item",
                          prefixIcon: Icon(Icons.shopping_cart),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            setState(() => selectedItem = value),
                        validator: (value) =>
                            value == null ? "Please select an item" : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Amount (AED)",
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Enter amount";
                          if (double.tryParse(value) == null)
                            return "Enter valid number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (editIndex == null) {
                              // Add new purchase
                              purchaseProvider.addPurchase(
                                selectedItem!,
                                double.parse(amountController.text),
                                selectedDate, // ✅ use selected date
                              );
                            } else {
                              // Edit purchase
                              purchaseProvider.editPurchase(
                                editIndex!,
                                selectedItem!,
                                double.parse(amountController.text),
                              );
                              editIndex = null;
                            }

                            // Update SellProvider
                            sellProvider.updatePurchases(
                              purchaseProvider.purchases,
                            );

                            selectedItem = null;
                            amountController.clear();
                          }
                        },
                        icon: Icon(
                          editIndex == null ? Icons.add : Icons.update,
                        ),
                        label: Text(
                          editIndex == null
                              ? "Add Purchase"
                              : "Update Purchase",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Monthly button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MonthlyPurchaseView(),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text("View Monthly Purchases"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),

            // Daily total
            TotalCardWidget(
              total: dailyTotal,
              title:
                  "Total Purchase - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
            ),
            const SizedBox(height: 10),

            // Purchase List
            Expanded(
              child: ItemListCard(
                items: dailyPurchases,
                leading: (_) =>
                    const Icon(Icons.shopping_bag, color: Colors.green),
                title: (p) => Text(p.item),
                onEdit: (p, index) {
                  selectedItem = p.item;
                  amountController.text = p.amount.toString();
                  setState(() => editIndex = index);
                },
                onDelete: (p, index) {
                  purchaseProvider.deletePurchase(index);
                  sellProvider.updatePurchases(purchaseProvider.purchases);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Widget/confirm_delete_dialog_widget.dart';
import '../Provider/item_provider.dart';
import '../Provider/purchase_provider.dart';
import '../Provider/sell_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/date_picker_widget.dart';
import '../Widget/item_list_card_widget.dart';
import '../Widget/total_card_widget.dart';
import 'purchase_item_manage_screen.dart';
import 'purchase_summary_screen.dart';

class PurchaseEntryScreen extends StatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();

  String? selectedItem;
  int? editIndex;
  DateTime selectedDate = DateTime.now();

  void _clearForm() {
    selectedItem = null;
    amountController.clear();
    editIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final sellProvider = Provider.of<SellProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context);

    final dailyPurchases = purchaseProvider.getDailyByDate(selectedDate);
    final dailyTotal = dailyPurchases.fold(0.0, (sum, p) => sum + p.amount);
    List<String> itemNames = List.from(itemProvider.items);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageTitleWidget(
                title:
                    "Purchase Input - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
              ),
              const SizedBox(height: 12),

              // Manage Items Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PurchaseItemManageScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.manage_accounts),
                label: const Text("Manage Items"),
              ),
              const SizedBox(height: 12),

              // Form Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Date Picker
                        InkWell(
                          onTap: () => DatePickerWidget(selectedDate: selectedDate,  onDatePicked: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                          ),
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

                        // Item Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedItem,
                          items: itemNames
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
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

                        // Amount Input
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Amount (AED)",
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter amount";
                            }
                            if (double.tryParse(value) == null) {
                              return "Enter valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Add/Update Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(
                            editIndex == null ? Icons.add : Icons.update,
                          ),
                          label: Text(
                            editIndex == null
                                ? "Add Purchase"
                                : "Update Purchase",
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                selectedItem != null) {
                              if (editIndex == null) {
                                purchaseProvider.addPurchase(
                                  selectedItem!,
                                  double.parse(amountController.text),
                                  selectedDate,
                                );
                              } else {
                                purchaseProvider.editPurchase(
                                  editIndex!,
                                  selectedItem!,
                                  double.parse(amountController.text),
                                );
                              }

                              sellProvider.updatePurchases(
                                purchaseProvider.purchases,
                              );
                              setState(() => _clearForm());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Monthly Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PurchaseSummaryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("View Purchases Summary"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),

              // Daily Total
              TotalCardWidget(
                total: dailyTotal,
                title:
                    "Total Purchase - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
              ),
              const SizedBox(height: 10),

              // Purchase List with fixed height
              Container(
                height: 300, // adjust height as needed
                child: dailyPurchases.isEmpty
                    ? const Center(child: Text("No purchases for this day."))
                    : ItemListCard(
                        items: dailyPurchases,
                        leading: (_) =>
                            const Icon(Icons.shopping_bag, color: Colors.green),
                        title: (p) => Text(p.item),
                        subtitle: (p) => Text(
                        p.amount.toStringAsFixed(2),
                        style: const TextStyle(color: Colors.green),
                      ),
                        onEdit: (p, index) {
                          setState(() {
                            selectedItem = p.item;
                            amountController.text = p.amount.toStringAsFixed(2);
                            editIndex = index;
                          });
                        },
                        onDelete: (p, index) {
                          ConfirmDeleteDialogWidget.show(
                            context,
                            name: p.item,
                            description: "Are you sure you want to delete this purchase?",
                            onDelete: () {
                              purchaseProvider.deletePurchase(index);
                              sellProvider.updatePurchases(
                                purchaseProvider.purchases,
                              );
                            },
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

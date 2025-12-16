import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Widget/confirm_delete_dialog_widget.dart';
import '../Provider/item_provider.dart';
import '../Provider/purchase_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/full_page_loader_widget.dart';
import '../Widget/item_list_card_widget.dart';
import '../Widget/total_card_widget.dart';
import 'purchase_item_manage_screen.dart';
import 'purchase_summary_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

class PurchaseEntryScreen extends StatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();

  String? selectedItem;
  String? editId;
  DateTime selectedDate = DateTime.now();

  bool _addOrEditPurchaseLoading = false;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Provider.of<PurchaseProvider>(context, listen: false).init(uid);
    Provider.of<ItemProvider>(context, listen: false).init(uid);
  }

  void _clearForm() {
    selectedItem = null;
    amountController.clear();
    editId = null;
  }

  Future<void> _addOrEditPurchase() async {
    if (_formKey.currentState!.validate() && selectedItem != null) {
      setState(() => _addOrEditPurchaseLoading = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final amount = double.parse(amountController.text);
      final purchaseProvider =
      Provider.of<PurchaseProvider>(context, listen: false);

      if (editId == null) {
        await purchaseProvider.addPurchase(
          uid: uid,
          item: selectedItem!,
          amount: amount,
          date: selectedDate,
        );
        Fluttertoast.showToast(msg: "Purchase added successfully");
      } else {
        await purchaseProvider.editPurchase(
          id: editId!,
          item: selectedItem!,
          amount: amount,
        );
        Fluttertoast.showToast(msg: "Purchase updated successfully");
      }
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _addOrEditPurchaseLoading = false;
        _clearForm();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dailyPurchases =
    purchaseProvider.getByDateForUser(uid, selectedDate);
    final dailyTotal = dailyPurchases.fold(0.0, (sum, p) => sum + p.amount);
    final itemNames = itemProvider.items.map((item) => item.name).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageTitleWidget(
                    title:
                    "Purchase Input - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
                  ),
                  const SizedBox(height: 12),

                   ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PurchaseItemManageScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.manage_accounts),
                    label: const Text("Manage Items"),
                  ),
                  const SizedBox(height: 12),

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
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2024, 1),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Select Date",
                                  prefixIcon: Icon(Icons.date_range),
                                  border: OutlineInputBorder(),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                    (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ),
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

                            // Amount Field
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
                            const SizedBox(height: 20),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              icon: Icon(
                                  editId == null ? Icons.add : Icons.update),
                              label: Text(
                                  editId == null ? "Add Purchase" : "Update Purchase"),
                              onPressed: _addOrEditPurchaseLoading
                                  ? null
                                  : _addOrEditPurchase,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary Button
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
                  ),

                  const SizedBox(height: 20),

                  // Total Card
                  TotalCardWidget(
                    total: dailyTotal,
                    title:
                    "Total Purchase - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
                  ),
                  const SizedBox(height: 10),

                  // Purchases List
                  SizedBox(
                    height: 300,
                    child: ItemListCard(
                      isLoading: purchaseProvider.isLoading,
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
                          editId = p.id;
                        });
                      },
                      onDelete: (p, index) {
                        ConfirmDeleteDialogWidget.show(
                          context,
                          name: p.item,
                          description:
                          "Are you sure you want to delete this purchase?",
                          onDelete: () async {
                            await purchaseProvider.deletePurchase(p.id);
                            Fluttertoast.showToast(
                                msg: "Purchase deleted successfully");
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Overlay Shimmer Loader for Add/Edit
            if (_addOrEditPurchaseLoading)
              FullPageLoaderWidget(),
          ],
        ),
      ),
    );
  }
}


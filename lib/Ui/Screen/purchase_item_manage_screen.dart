import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Widget/appbar_widget.dart';
import 'package:rukin_cafeteria/Ui/Widget/confirm_delete_dialog_widget.dart';
import '../Provider/item_provider.dart';
import '../Widget/Page_Title_widget.dart';

class PurchaseItemManageScreen extends StatefulWidget {
  const PurchaseItemManageScreen({super.key});

  @override
  State<PurchaseItemManageScreen> createState() => _PurchaseItemManageScreenState();
}

class _PurchaseItemManageScreenState extends State<PurchaseItemManageScreen> {
  final TextEditingController itemController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: const AppbarWidget(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitleWidget(
                title: "Item Management",
                ),
            const SizedBox(height: 20),
            // Add Item Field vertically
            TextField(
              controller: itemController,
              decoration: InputDecoration(
                hintText: "Add New Item",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (itemController.text.trim().isNotEmpty) {
                      itemProvider.addItem(itemController.text.trim());
                      itemController.clear();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List of Items
            Expanded(
              child: itemProvider.items.isEmpty
                  ? const Center(
                child: Text(
                  "No items added yet",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: itemProvider.items.length,
                itemBuilder: (context, index) {
                  final name = itemProvider.items[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.shopping_cart,
                            color: Colors.green),
                      ),
                      title: Text(name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ConfirmDeleteDialogWidget.show(
                            context,
                            name: name,
                            description: "Are you sure you want to delete this item?",
                            onDelete: () {
                              itemProvider.deleteItem(index);
                            },
                          ),
                        ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

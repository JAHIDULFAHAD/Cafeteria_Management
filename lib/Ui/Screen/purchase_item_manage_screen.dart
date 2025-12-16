import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Widget/listview_loader_widget.dart';
import 'package:shimmer/shimmer.dart';
import '../Provider/item_provider.dart';
import '../Provider/user_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';
import '../Widget/confirm_delete_dialog_widget.dart';
import '../Widget/full_page_loader_widget.dart';

class PurchaseItemManageScreen extends StatefulWidget {
  const PurchaseItemManageScreen({super.key});

  @override
  State<PurchaseItemManageScreen> createState() =>
      _PurchaseItemManageScreenState();
}

class _PurchaseItemManageScreenState extends State<PurchaseItemManageScreen> {
  final TextEditingController itemController = TextEditingController();
  bool _addItemLoading = false;

  @override
  void initState() {
    super.initState();
    final itemProvider =
    Provider.of<ItemProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    itemProvider.init(uid);
  }
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;


    return Scaffold(
      appBar: const AppbarWidget(),
      body: Stack(
        children: [
          Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageTitleWidget(title: "Item Management"),
              const SizedBox(height: 20),

              // Add Item Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: itemController,
                        decoration: const InputDecoration(
                          hintText: "Add New Item",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final name = itemController.text.trim();
                          if (name.isNotEmpty) {
                            setState(() => _addItemLoading = true);
                            await itemProvider.addItem(uid,name);
                            itemController.clear();
                            setState(() => _addItemLoading = false);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items List
              Expanded(
                child: itemProvider.isLoading ?
                    ListviewLoaderWidget():
                itemProvider.items.isEmpty
                    ? const Center(
                  child: Text(
                    "No items added yet",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: itemProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = itemProvider.items[index];
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
                        title: Text(item.name),
                        trailing: IconButton(
                          icon:
                          const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ConfirmDeleteDialogWidget.show(
                            context,
                            name: item.name,
                            description:
                            "Are you sure you want to delete this item?",
                            onDelete: () async {
                              setState(() => _addItemLoading = true);
                              await itemProvider.deleteItem(item.id);
                              setState(() => _addItemLoading = false);
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
          if (_addItemLoading)
            FullPageLoaderWidget(),
        ]
      ),
    );
  }
}



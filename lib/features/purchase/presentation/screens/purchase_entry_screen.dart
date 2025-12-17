import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rukin_cafeteria/features/Widget/amount_text_widget.dart';
import 'package:rukin_cafeteria/features/purchase/presentation/screens/purchase_item_manage_screen.dart';
import 'package:rukin_cafeteria/features/purchase/presentation/screens/purchase_summary_screen.dart';
import 'package:rukin_cafeteria/features/purchase/presentation/widgets/build_action_buttons.dart';
import '../../../Widget/Page_Title_widget.dart';
import '../data/item_provider.dart';
import '../data/purchase_provider.dart';
import '../../../Widget/confirm_delete_dialog_widget.dart';
import '../../../Widget/full_page_loader_widget.dart';
import '../../../Widget/item_list_card.dart';
import '../../../Widget/listview_loader_widget.dart';
import '../../../Widget/summary_button_widget.dart';
import '../../../Widget/total_card_widget.dart';
import '../widgets/build_purchase_form.dart';

class PurchaseEntryScreen extends StatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedItem;
  String? _editId;
  DateTime _selectedDate = DateTime.now();

  bool _isSubmitting = false;
  bool _isDateChanging = false;

  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;

    // Initialize providers once
    Provider.of<PurchaseProvider>(context, listen: false).initialize(_uid);
    Provider.of<ItemProvider>(context, listen: false).init(_uid);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _selectedItem = null;
    _amountController.clear();
    _editId = null;
  }

  Future<void> _submitPurchase() async {
    setState(() => _isSubmitting = true);

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final provider = Provider.of<PurchaseProvider>(context, listen: false);

    try {
      if (_editId == null) {
        await provider.addPurchase(
          uid: _uid,
          item: _selectedItem!,
          amount: amount,
          date: _selectedDate,
        );
        Fluttertoast.showToast(msg: "Purchase added successfully");
      } else {
        await provider.editPurchase(
          id: _editId!,
          item: _selectedItem!,
          amount: amount,
        );
        Fluttertoast.showToast(msg: "Purchase updated successfully");
      }
      _resetForm();
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong!");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isDateChanging = true;
      });

      // Simulate loading for better UX
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _isDateChanging = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    final dailyPurchases = purchaseProvider.getByDate(_uid, _selectedDate);
    final dailyTotal = dailyPurchases.fold<double>(
        0.0, (sum, p) => sum + p.amount);
    final itemNames = itemProvider.items.map((e) => e.name).toList();

    final isLoading = purchaseProvider.isLoading || _isDateChanging;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Form Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PageTitleWidget(title: "Purchase Input - ${_formatDate(
                          _selectedDate)}"),
                      const SizedBox(height: 16),

                      BuildActionButton(label: "Manage Item", icon: Icons.shopping_cart, onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PurchaseItemManageScreen(),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      PurchaseFormWidget(
                        itemNames: itemNames,
                        selectedDate: _selectedDate,
                        selectedItem: _selectedItem,
                        editId: _editId,
                        editAmount: null,
                        isSubmitting: _isSubmitting,
                        onDateTap: _selectDate,
                        onItemChanged: (value) => setState(() => _selectedItem = value),
                        amountController: _amountController,
                        onSubmit: _submitPurchase,
                      ),
                      const SizedBox(height: 20),

                      SummaryButtonWidget(label: "View Purchases Summary", icon: Icons.calendar_month, onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PurchaseSummaryScreen(),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      TotalCardWidget(
                        total: dailyTotal,
                        title: "Total Purchase - ${_formatDate(_selectedDate)}",
                      ),
                    ],
                  ),
                ),

                // Purchase List Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: isLoading
                        ? const ListviewLoaderWidget()
                        : ItemListCard(
                      items: dailyPurchases,
                      leading: (_) =>
                      const Icon(Icons.shopping_bag, color: Colors.green),
                      title: (p) => Text(p.item),
                      subtitle: (p) =>
                          AmountText(p.amount,),
                      onEdit: (p, _) {
                        setState(() {
                          _selectedItem = p.item;
                          _amountController.text = p.amount == p.amount.truncateToDouble()
                              ? p.amount.toInt().toString()
                              : p.amount.toStringAsFixed(2);
                          _editId = p.id;

                          _amountController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _amountController.text.length),
                          );
                        });
                      },
                      onDelete: (p, _) {
                        ConfirmDeleteDialogWidget.show(
                          context,
                          name: p.item,
                          description: "Are you sure you want to delete this purchase?",
                          onDelete: () async {
                            await purchaseProvider.deletePurchase(p.id);
                            Fluttertoast.showToast(
                                msg: "Purchase deleted successfully");
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Submit Loader
            if (_isSubmitting) const FullPageLoaderWidget(),
          ],
        ),
      ),
    );
  }

}
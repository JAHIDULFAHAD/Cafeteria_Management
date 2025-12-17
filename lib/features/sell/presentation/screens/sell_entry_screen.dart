import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rukin_cafeteria/features/Widget/amount_text_widget.dart';
import 'package:rukin_cafeteria/features/Widget/listview_loader_widget.dart';
import 'package:rukin_cafeteria/features/Widget/summary_button_widget.dart';
import 'package:rukin_cafeteria/features/Widget/confirm_delete_dialog_widget.dart'; // ← আপনার widget
import '../../../../Data/Model/sell_model.dart';
import '../../../Widget/Page_Title_widget.dart';
import '../../../Widget/full_page_loader_widget.dart';
import '../../../Widget/item_list_card.dart';
import '../../../Widget/total_card_widget.dart';
import '../data/sell_provider.dart';
import 'sell_summary_screen.dart';

class SellEntryScreen extends StatefulWidget {
  const SellEntryScreen({super.key});

  @override
  State<SellEntryScreen> createState() => _SellEntryScreenState();
}

class _SellEntryScreenState extends State<SellEntryScreen> {
  final TextEditingController _sellController = TextEditingController();
  bool _isSubmitting = false;
  bool _isChangingDate = false;
  String? _editId;

  @override
  void initState() {
    super.initState();
    Provider.of<SellProvider>(context, listen: false)..initialize();
  }

  @override
  void dispose() {
    _sellController.dispose();
    super.dispose();
  }

  void _updateInputField() {
    final provider = Provider.of<SellProvider>(context, listen: false);
    final date = provider.selectedDate;

    final sellsOfDay = provider
        .getMonthlySellList(date.year, date.month)
        .where((s) =>
    s.date.day == date.day &&
        s.date.month == date.month &&
        s.date.year == date.year)
        .toList();

    if (sellsOfDay.isNotEmpty) {
      final sell = sellsOfDay.first;
      setState(() {
        _sellController.text = sell.amount.toStringAsFixed(2);
        _editId = sell.id;
      });
    } else {
      setState(() {
        _sellController.clear();
        _editId = null;
      });
    }
  }

  void _selectDate() async {
    final provider = Provider.of<SellProvider>(context, listen: false);
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != provider.selectedDate) {
      setState(() => _isChangingDate = true);

      provider.setSelectedDate(picked);
      _updateInputField();

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _isChangingDate = false);
        }
      });
    }
  }

  Future<void> _saveSell() async {
    final amount = double.tryParse(_sellController.text.trim());
    if (amount == null) {
      Fluttertoast.showToast(msg: "Enter a valid amount!");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final provider = Provider.of<SellProvider>(context, listen: false);
      await provider.addOrUpdateSell(date: provider.selectedDate, amount: amount);

      Fluttertoast.showToast(
          msg: _editId == null ? "Sell added successfully" : "Sell updated successfully");

      _updateInputField();
    } catch (_) {
      Fluttertoast.showToast(msg: "Failed to save sell!");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  @override
  Widget build(BuildContext context) {
    return Consumer<SellProvider>(
      builder: (context, provider, child) {
        final date = provider.selectedDate;

        final sellsOfDay = provider
            .getMonthlySellList(date.year, date.month)
            .where((s) =>
        s.date.day == date.day &&
            s.date.month == date.month &&
            s.date.year == date.year)
            .toList();

        final totalSell = sellsOfDay.fold<double>(0.0, (sum, s) => sum + s.amount);

        final isLoading = provider.isLoading || _isSubmitting || _isChangingDate;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          PageTitleWidget(title: "Sell Input - ${_formatDate(date)}"),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: _selectDate,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: "Select Date",
                                        prefixIcon: Icon(Icons.date_range, color: Colors.green),
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_formatDate(date), style: const TextStyle(fontSize: 16)),
                                          const Icon(Icons.arrow_drop_down),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _sellController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: "Enter Sell Amount",
                                      prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _isSubmitting ? null : _saveSell,
                                    icon: Icon(_editId == null ? Icons.save : Icons.update),
                                    label: Text(
                                      _editId == null ? "Save Sell" : "Update Sell",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SummaryButtonWidget(
                            label: "View Sell Summary",
                            icon: Icons.sell,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SellSummaryScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TotalCardWidget(
                            total: totalSell,
                            title: "Total Sell - ${_formatDate(date)}",
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: isLoading
                            ? const ListviewLoaderWidget()
                            : ItemListCard<SellModel>(
                          items: sellsOfDay,
                          leading: (_) => const Icon(Icons.sell, color: Colors.green),
                          title: (s) => AmountText(s.amount),
                          subtitle: (s) => Row(
                            children: [
                              Text('Net Cash: ',style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                          ),),
                              AmountText(
                                s.netCash,
                                 style: TextStyle(
                                   fontWeight: FontWeight.bold,
                                   color: s.netCash >= 0 ? Colors.green : Colors.red,
                                   fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          onEdit: (s, _) {
                            setState(() {
                              _sellController.text = s.amount == s.amount.truncateToDouble()
                                  ? s.amount.toInt().toString()
                                  : s.amount.toStringAsFixed(2);
                              _editId = s.id;

                              _sellController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _sellController.text.length),
                              );
                            });
                          },
                          onDelete: (s, _) async {
                            ConfirmDeleteDialogWidget.show(
                              context,
                              name: _formatDate(s.date),
                              description: "Are you sure you want to delete the sell entry of",
                              buttonName: "Delete",
                              onDelete: () async {
                                try {
                                  await provider.deleteSell(date: s.date);
                                  Fluttertoast.showToast(msg: "Sell deleted successfully");

                                  if (provider.selectedDate.year == s.date.year &&
                                      provider.selectedDate.month == s.date.month &&
                                      provider.selectedDate.day == s.date.day) {
                                    setState(() {
                                      _sellController.clear();
                                      _editId = null;
                                    });
                                  }
                                } catch (_) {
                                  Fluttertoast.showToast(msg: "Failed to delete sell!");
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isSubmitting) const FullPageLoaderWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
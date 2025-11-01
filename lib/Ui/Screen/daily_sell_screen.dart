import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/sell_provider.dart';
import '../Widget/Page_Title_widget.dart';
import 'monthly_sell_screen.dart';

class DailySellScreen extends StatefulWidget {
  const DailySellScreen({super.key});

  @override
  State<DailySellScreen> createState() => _DailySellScreenState();
}

class _DailySellScreenState extends State<DailySellScreen> {
  final TextEditingController _sellController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // ✅ Default today's date

  // Date Picker Function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellProvider>(
      builder: (context, provider, child) {
        final sellForSelectedDate = provider.getSellByDate(selectedDate);
        if (sellForSelectedDate != null &&
            _sellController.text != sellForSelectedDate.amount.toString()) {
          _sellController.text = sellForSelectedDate.amount.toString();
        }

        final todaySell = sellForSelectedDate;
        Color netCashColor =
        todaySell != null && todaySell.netCash >= 0 ? Colors.green : Colors.red;

        return Scaffold(
          backgroundColor: Colors.green.shade50,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ Title + Selected Date
                  PageTitleWidget(
                    title:
                    "Sells Input - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
                  ),
                  const SizedBox(height: 20),

                  // ✅ Sell Input Field
                  Card(
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _sellController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Enter Sell (AED)",
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              final value = double.tryParse(_sellController.text);
                              if (value != null && value >= 0) {
                                provider.addOrUpdateSellForDate(selectedDate, value);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Sell Saved for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text("Save Sell"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Monthly Sell Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MonthlySellView()),
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text("View Monthly Sells"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Daily Summary
                  if (todaySell != null)
                    Card(
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              "Selected Date Summary",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sell: AED ${todaySell.amount}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Net Cash: AED ${todaySell.netCash.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: netCashColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

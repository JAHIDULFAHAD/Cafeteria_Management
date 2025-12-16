import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Widget/date_picker_widget.dart';
import '../Provider/sell_provider.dart';
import '../Widget/Page_Title_widget.dart';
import 'sell_summary_screen.dart';

class SellEntryScreen extends StatefulWidget {
  const SellEntryScreen({super.key});

  @override
  State<SellEntryScreen> createState() => _SellEntryScreenState();
}

class _SellEntryScreenState extends State<SellEntryScreen> {
  final TextEditingController _sellController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    final sellProvider = Provider.of<SellProvider>(context, listen: false);
    sellProvider.loadSellOnStart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellProvider>(
      builder: (context, provider, child) {
        final sellForSelectedDate = provider.getSellByDate(selectedDate);

        // Auto-fill controller if sell exists
        if (sellForSelectedDate != null &&
            _sellController.text !=
                sellForSelectedDate.amount.toStringAsFixed(2)) {
          _sellController.text = sellForSelectedDate.amount.toStringAsFixed(2);
        }

        final todaySell = sellForSelectedDate;
        Color netCashColor =
        todaySell != null && todaySell.netCash >= 0 ? Colors.green : Colors.red;

        return Scaffold(
          backgroundColor: Colors.green.shade50,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Page Title
                        PageTitleWidget(
                          title:
                          "Sells Input - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
                        ),
                        const SizedBox(height: 20),

                        // Input Card
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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

                                // Sell Input Field
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

                                // Save Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final value =
                                    double.tryParse(_sellController.text);
                                    if (value != null && value >= 0) {
                                      // <-- FIXED FUNCTION NAME
                                      provider.addOrUpdateSell(selectedDate, value);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Sell Saved for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                                        ),
                                      );

                                      _sellController.clear();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Enter a valid sell amount!"),
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // View Sells Summary Button
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SellSummaryScreen()),
                            );
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text("View Sells Summary"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Daily Summary Card
                        if (todaySell != null)
                          Card(
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Sell: AED ${todaySell.amount.toStringAsFixed(2)}",
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _sellController.dispose();
    super.dispose();
  }
}

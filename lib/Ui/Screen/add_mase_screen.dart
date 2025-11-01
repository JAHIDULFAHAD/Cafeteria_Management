import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Data/Model/mess_model.dart';
import '../Controller/mass_provider.dart';
import '../Widget/Page_Title_widget.dart';
import 'monthly_mess_screen.dart';

class AddMessPage extends StatefulWidget {
  const AddMessPage({super.key});

  @override
  State<AddMessPage> createState() => _AddMessPageState();
}

class _AddMessPageState extends State<AddMessPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final billController = TextEditingController();
  final advanceController = TextEditingController();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = const [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  void _addBill(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MonthlyBillProvider>(context, listen: false);

      // ✅ Parse values safely as double
      final double mass = double.tryParse(billController.text.trim()) ?? 0.0;
      final double adv = advanceController.text.trim().isEmpty
          ? 0.0
          : double.tryParse(advanceController.text.trim()) ?? 0.0;
      final String name = nameController.text.trim();

      provider.addBill(
        MonthlyBillModel(
          name: name,
          massBill: mass,
          advanceBill: adv,
          date: DateTime(selectedYear, selectedMonth, DateTime.now().day),
        ),
      );

      // Clear fields
      nameController.clear();
      billController.clear();
      advanceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bill added successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PageTitleWidget(title: "Add Mess Bill - (${months[selectedMonth-1]} $selectedYear)"),
            SizedBox(height: 20,),
            Form(
              key: _formKey,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                  items: List.generate(12, (i) =>
                                      DropdownMenuItem(
                                        value: i + 1,
                                        child: Text(months[i]),
                                      )),
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
                                  items: List.generate(5, (i) {
                                    final year = DateTime.now().year - i;
                                    return DropdownMenuItem(
                                        value: year,
                                        child: Text("$year")
                                    );
                                  }),
                                  onChanged: (val) => setState(() => selectedYear = val!),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          hintText: "Enter person's name",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Enter name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Mass Bill
                      TextFormField(
                        controller: billController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Mess Bill",
                          hintText: "Enter total bill amount",
                          prefixIcon: const Icon(Icons.receipt),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Enter Mess Bill";
                          }
                          final val = double.tryParse(value.trim());
                          if (val == null || val <= 0) {
                            return "Enter a valid positive number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Advance (Optional)
                      TextFormField(
                        controller: advanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Advance Paid (Optional)",
                          hintText: "Enter advance amount if any",
                          prefixIcon: const Icon(Icons.payments),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null; // Optional field
                          }
                          final val = double.tryParse(value.trim());
                          final mass = double.tryParse(billController.text.trim()) ?? 0.0;
                          if (val == null || val < 0) {
                            return "Enter a valid number";
                          }
                          if (val > mass) {
                            return "Advance cannot exceed Mass Bill";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Add Button
                      ElevatedButton.icon(
                        onPressed: () => _addBill(context),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Add Bill",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Monthly Expense Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MessRecordPage()),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text("View Monthly Mess Bill"),
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
    );
  }
}

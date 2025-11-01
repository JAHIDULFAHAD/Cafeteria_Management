import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Data/Model/staff_model.dart';
import '../Controller/expense_provider.dart';
import '../Controller/staff_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/item_list_card_widget.dart';
import '../Widget/total_card_widget.dart';
import 'monthly_expence_screen.dart';

class ExpenseEntryView extends StatefulWidget {
  const ExpenseEntryView({super.key});

  @override
  State<ExpenseEntryView> createState() => _ExpenseEntryViewState();
}

class _ExpenseEntryViewState extends State<ExpenseEntryView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();

  String? selectedTitle;
  StaffModel? selectedStaff;
  int? editIndex;
  DateTime selectedDate = DateTime.now();

  final List<String> expenseTitles = [
    'Salary',
    'Room Rent',
    'Store Rent',
    'Current Bill',
  ];

  // 🔹 Date Picker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        editIndex = null;
        selectedTitle = null;
        selectedStaff = null;
        amountController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final staffProvider = Provider.of<StaffProvider>(context);

    // 🔹 Expenses for selected date
    final expensesForSelectedDate = expenseProvider.expenses
        .where((e) =>
    e.date.year == selectedDate.year &&
        e.date.month == selectedDate.month &&
        e.date.day == selectedDate.day)
        .toList();

    final totalForSelectedDate =
    expensesForSelectedDate.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageTitleWidget(title: "Expense Input - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})"),
              const SizedBox(height: 16),

              // 🔹 Expense Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Date Picker
                        GestureDetector(
                          onTap: () => _pickDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Expense Date",
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                                hintText:
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                              ),
                              controller: TextEditingController(
                                  text:
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Expense Title Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedTitle,
                          decoration: const InputDecoration(
                            labelText: "Expense Title",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          items: expenseTitles
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedTitle = val;
                              selectedStaff = null;
                              amountController.clear();
                            });
                          },
                          validator: (value) =>
                          value == null ? "Select expense title" : null,
                        ),
                        const SizedBox(height: 12),

                        // Staff Dropdown (Salary only)
                        if (selectedTitle == 'Salary')
                          DropdownButtonFormField<StaffModel>(
                            value: selectedStaff,
                            decoration: const InputDecoration(
                              labelText: "Select Staff",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: staffProvider.staffs
                                .map((staff) => DropdownMenuItem(
                              value: staff,
                              child: Text(
                                  "${staff.name} (৳${staff.salary.toStringAsFixed(0)})"),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedStaff = val;
                                if (val != null) {
                                  amountController.text = val.salary.toString();
                                }
                              });
                            },
                            validator: (value) =>
                            value == null ? "Select staff" : null,
                          ),
                        const SizedBox(height: 12),

                        // Amount Input
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Amount (AED)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter amount";
                            }
                            if (double.tryParse(value) == null) {
                              return "Enter a valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Add / Update Button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              double enteredAmount =
                              double.parse(amountController.text);

                              if (editIndex == null) {
                                // Add Expense
                                if (selectedTitle == 'Salary' &&
                                    selectedStaff != null) {
                                  double diff =
                                      enteredAmount - selectedStaff!.salary;
                                  if (diff > 0) {
                                    selectedStaff!.pendingSalary =
                                        (selectedStaff!.pendingSalary - diff)
                                            .clamp(0, double.infinity);
                                  } else if (diff < 0) {
                                    selectedStaff!.pendingSalary += (-diff);
                                  }
                                  expenseProvider.addExpense(
                                      title: "Salary - ${selectedStaff!.name}",
                                      amount: enteredAmount,
                                      date: selectedDate);
                                } else {
                                  expenseProvider.addExpense(
                                      title: selectedTitle ?? 'Other',
                                      amount: enteredAmount,
                                      date: selectedDate);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("Expense saved successfully ✅")),
                                );
                              } else {
                                // Edit Expense
                                expenseProvider.editExpense(
                                  index: editIndex!,
                                  newTitle: selectedTitle!,
                                  newAmount: enteredAmount,
                                  newDate: selectedDate,
                                );
                                editIndex = null;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("Expense updated successfully ✅")),
                                );
                              }

                              // Reset Form fields BUT keep selectedDate
                              setState(() {
                                selectedTitle = null;
                                selectedStaff = null;
                                amountController.clear();
                              });
                            }
                          },
                          icon: Icon(editIndex == null
                              ? Icons.add
                              : Icons.check_circle_outline),
                          label: Text(editIndex == null
                              ? "Add Expense"
                              : "Update Expense"),
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
              ),

              const SizedBox(height: 20),

              // Monthly Expense Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ExpenseSummaryScreen()),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("View Monthly Expense"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),

              // Selected Date Total
              TotalCardWidget(
                total: totalForSelectedDate,
                title:
                "Total Expense - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ItemListCard(
                  items: expensesForSelectedDate,
                  leading: (_) =>
                  const Icon(Icons.money, color: Colors.green),
                  title: (e) =>
                      Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: (e) =>
                      Text("Date: ${e.date.day}/${e.date.month}/${e.date.year}"),
                  onEdit: (e, index) {
                    setState(() {
                      selectedTitle =
                      e.title.contains("Salary") ? "Salary" : e.title;
                      amountController.text = e.amount.toString();
                      selectedDate = e.date;
                      editIndex = expenseProvider.expenses.indexOf(e);
                    });
                  },
                  onDelete: (e, index) {
                    final indexInProvider =
                    expenseProvider.expenses.indexOf(e);
                    expenseProvider.deleteExpense(indexInProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                          Text("Expense deleted successfully ❌")),
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Widget/confirm_delete_dialog_widget.dart';
import 'package:rukin_cafeteria/Ui/Widget/date_picker_widget.dart';
import '../../Data/Model/staff_model.dart';
import '../Provider/expense_provider.dart';
import '../Provider/staff_provider.dart';
import '../Provider/sell_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/item_list_card_widget.dart';
import '../Widget/total_card_widget.dart';
import 'expence_summary_screen.dart';

class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();

  String? selectedTitle;
  StaffModel? selectedStaff;
  String? editId; // Firestore doc ID
  DateTime selectedDate = DateTime.now();

  final List<String> expenseTitles = [
    'Staff Salary',
    'Staff Room Rent',
    'Store Rent',
    'Current Bill',
    'Other Bill'
  ];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      Provider.of<ExpenseProvider>(context, listen: false).init(uid);
      Provider.of<StaffProvider>(context, listen: false).loadStaffsFromFirestore();
      Provider.of<SellProvider>(context, listen: false).loadSellOnStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final staffProvider = Provider.of<StaffProvider>(context);

    // Filter expenses for the selected date
    final expensesForSelectedDate = expenseProvider.expenses
        .where((e) =>
    e.date.year == selectedDate.year &&
        e.date.month == selectedDate.month &&
        e.date.day == selectedDate.day)
        .toList();

    final totalForSelectedDate =
    expensesForSelectedDate.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageTitleWidget(
                title:
                "Expense Input - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})",
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Form Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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

                                // Expense Title Dropdown
                                DropdownButtonFormField<String>(
                                  value: selectedTitle,
                                  decoration: const InputDecoration(
                                    labelText: "Expense Title",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.title),
                                  ),
                                  items: expenseTitles
                                      .map(
                                        (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
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
                                if (selectedTitle == 'Staff Salary')
                                  DropdownButtonFormField<StaffModel>(
                                    value: selectedStaff,
                                    decoration: const InputDecoration(
                                      labelText: "Select Staff",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    items: staffProvider.staffs
                                        .map(
                                          (staff) => DropdownMenuItem(
                                        value: staff,
                                        child: Text(
                                            "${staff.name} (AED${staff.salary.toStringAsFixed(0)})"),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedStaff = val;
                                        if (val != null) {
                                          amountController.text =
                                              val.salary.toString();
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
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      double enteredAmount =
                                      double.parse(amountController.text);
                                      String title = selectedTitle!;

                                      if (title == 'Staff Salary' &&
                                          selectedStaff != null) {
                                        title = "Salary - ${selectedStaff!.name}";
                                        await staffProvider.paySalary(
                                            selectedStaff!.id, enteredAmount);
                                      }

                                      if (editId == null) {
                                        await expenseProvider.addExpense(
                                          title: title,
                                          amount: enteredAmount,
                                          date: selectedDate,
                                        );
                                      } else {
                                        await expenseProvider.editExpense(
                                          id: editId!,
                                          newTitle: title,
                                          newAmount: enteredAmount,
                                          newDate: selectedDate,
                                        );
                                        editId = null;
                                      }

                                      setState(() {
                                        selectedTitle = null;
                                        selectedStaff = null;
                                        amountController.clear();
                                      });
                                    }
                                  },
                                  icon: Icon(
                                      editId == null ? Icons.add : Icons.check),
                                  label: Text(editId == null
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

                      // Expense Summary Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ExpenseSummaryScreen()),
                          );
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("View Expense Summary"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Total Card with live netCash
                      Consumer<SellProvider>(
                        builder: (context, sellProvider, _) {
                          final sell = sellProvider.getSellByDate(selectedDate);
                          final netCash = sell?.netCash ?? 0.0;
                          return TotalCardWidget(
                            total: totalForSelectedDate,
                            title:
                            "Total Expense - (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})\nNet Cash: \$${netCash.toStringAsFixed(2)}",
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // Expense List
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: ItemListCard(
                          items: expensesForSelectedDate,
                          leading: (_) =>
                          const Icon(Icons.money, color: Colors.green),
                          title: (e) => Text(e.title,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: (e) => Text(e.amount.toStringAsFixed(2),
                              style: const TextStyle(color: Colors.green)),
                          onEdit: (e, index) {
                            setState(() {
                              selectedTitle = e.title.contains("Salary")
                                  ? "Staff Salary"
                                  : e.title;
                              amountController.text =
                                  e.amount.toStringAsFixed(2);
                              selectedDate = e.date;
                              editId = e.id;
                            });
                          },
                          onDelete: (e, index) {
                            ConfirmDeleteDialogWidget.show(
                              context,
                              name: e.title,
                              description:
                              "Are you sure you want to delete this expense?",
                              onDelete: () async {
                                await expenseProvider.deleteExpense(e.id);
                              },
                            );
                          },
                        ),
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
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}

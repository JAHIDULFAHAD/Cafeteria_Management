import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Data/Model/staff_model.dart';
import '../data/staff_provider.dart';
import '../../../Widget/Page_Title_widget.dart';
import '../../../Widget/appbar_widget.dart';
import '../../../Widget/confirm_delete_dialog_widget.dart';

class StaffManageScreen extends StatefulWidget {
  const StaffManageScreen({super.key});

  @override
  State<StaffManageScreen> createState() => _StaffManageScreenState();
}

class _StaffManageScreenState extends State<StaffManageScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  String? editId;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    Provider.of<StaffProvider>(context, listen: false).initialize();
  }

  @override
  void dispose() {
    nameController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  void _clearForm() {
    nameController.clear();
    salaryController.clear();
    setState(() => editId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const PageTitleWidget(title: "Staff Management"),
            const SizedBox(height: 16),

            // Add/Edit Form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Staff Name",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: salaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Salary (AED)",
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<StaffProvider>(
                      builder: (context, staffProvider, _) {
                        return ElevatedButton.icon(
                          onPressed: staffProvider.isLoading
                              ? null
                              : () async {
                            final name = nameController.text.trim();
                            final salaryText = salaryController.text.trim();
                            final salary = double.tryParse(salaryText) ?? 0;

                            if (name.isEmpty || salary <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter valid name and salary')),
                              );
                              return;
                            }

                            try {
                              if (editId == null) {
                                await staffProvider.addStaff(
                                  name: name,
                                  salary: salary,
                                  uid: uid,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Staff added successfully')),
                                );
                              } else {
                                await staffProvider.editStaff(
                                  id: editId!,
                                  newName: name,
                                  newSalary: salary,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Staff updated successfully')),
                                );
                                _clearForm();
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          icon: Icon(editId == null ? Icons.add : Icons.update),
                          label: Text(editId == null ? "Add Staff" : "Update Staff"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Staff List
            Expanded(
              child: Consumer<StaffProvider>(
                builder: (context, staffProvider, child) {
                  if (staffProvider.isLoading && staffProvider.staffs.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (staffProvider.staffs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No staff found.\nTap 'Add Staff' to create one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: staffProvider.staffs.length,
                    itemBuilder: (context, index) {
                      final s = staffProvider.staffs[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          title: Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Salary: AED ${s.salary.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.deepPurple),
                                ),
                                Text(
                                  "Pending: AED ${s.pendingSalary.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: staffProvider.isLoading
                                    ? null
                                    : () {
                                  nameController.text = s.name;
                                  salaryController.text = s.salary.toStringAsFixed(0);
                                  setState(() => editId = s.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Editing ${s.name}")),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: staffProvider.isLoading
                                    ? null
                                    : () => ConfirmDeleteDialogWidget.show(
                                  context,
                                  name: s.name,
                                  description: "This will permanently delete the staff member.",
                                  onDelete: () async {
                                    try {
                                      await staffProvider.deleteStaff(s.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Staff deleted')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Delete failed: $e')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
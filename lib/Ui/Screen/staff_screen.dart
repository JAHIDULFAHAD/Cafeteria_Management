import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Data/Model/staff_model.dart';
import '../Controller/staff_provider.dart';
import '../Widget/Page_Title_widget.dart';
import '../Widget/appbar_widget.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  String? editId;

  @override
  Widget build(BuildContext context) {
    final staffProvider = Provider.of<StaffProvider>(context);

    return Scaffold(
      appBar: AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PageTitleWidget( title: "Staff Management"),
            const SizedBox(height: 16),
            // Add/Edit Staff Name & Salary
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                        labelText: "Salary (৳)",
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final salary =
                            double.tryParse(salaryController.text) ?? 0;
                        if (name.isEmpty || salary <= 0) return;

                        if (editId == null) {
                          staffProvider.addStaff(name, salary);
                        } else {
                          staffProvider.editStaff(editId!, name, salary);
                          editId = null;
                        }

                        nameController.clear();
                        salaryController.clear();
                      },
                      icon: Icon(editId == null ? Icons.add : Icons.update),
                      label: Text(editId == null ? "Add Staff" : "Update Staff"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Staff List with salary and pending salary
            Expanded(
              child: ListView.builder(
                itemCount: staffProvider.staffs.length,
                itemBuilder: (context, index) {
                  final StaffModel s = staffProvider.staffs[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.deepPurple.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      title: Text(
                        s.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Salary: ৳${s.salary.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.deepPurple),
                            ),
                            Text(
                              "Pending: ৳${s.pendingSalary.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Name & Salary
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              nameController.text = s.name;
                              salaryController.text = s.salary.toString();
                              setState(() => editId = s.id);
                            },
                          ),
                          // Delete
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => staffProvider.deleteStaff(s.id),
                          ),
                        ],
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


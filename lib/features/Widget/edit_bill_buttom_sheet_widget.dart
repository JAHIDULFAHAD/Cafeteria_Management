import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Data/Model/meal_model.dart';
import '../meal/presentation/data/meal_provider.dart';

class EditBillBottomSheet extends StatefulWidget {
  final MealProvider provider;
  final MealModel bill;

  const EditBillBottomSheet({super.key, required this.provider, required this.bill});

  @override
  State<EditBillBottomSheet> createState() => _EditBillBottomSheetState();
}

class _EditBillBottomSheetState extends State<EditBillBottomSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _massCtrl;
  late TextEditingController _advCtrl;
  late DateTime _editDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.bill.name);
    _massCtrl = TextEditingController(text: widget.bill.massBill.toString());
    _advCtrl = TextEditingController(text: widget.bill.advanceBill.toString());
    _editDate = widget.bill.date;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _massCtrl.dispose();
    _advCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
            ),
            Text("Edit Bill", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 8),
            TextField(
              controller: _massCtrl,
              decoration: const InputDecoration(labelText: "Mass Bill"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _advCtrl,
              decoration: const InputDecoration(labelText: "Advance Paid"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(DateFormat('MMMM yyyy').format(_editDate)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _editDate,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _editDate = picked);
                    }
                  },
                  child: const Text("Change Date"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                String name = _nameCtrl.text.trim();
                double mass = double.tryParse(_massCtrl.text) ?? -1;
                double advance = double.tryParse(_advCtrl.text) ?? 0;

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Name cannot be empty")),
                  );
                  return;
                }
                if (mass < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mass Bill must be positive")),
                  );
                  return;
                }
                if (advance < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Advance must be positive")),
                  );
                  return;
                }

                widget.bill.name = name;
                widget.bill.massBill = mass;
                widget.bill.advanceBill = advance;
                widget.bill.date = _editDate;

                widget.provider.notifyListeners();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text("Save"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

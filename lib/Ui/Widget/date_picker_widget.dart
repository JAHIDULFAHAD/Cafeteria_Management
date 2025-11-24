import 'package:flutter/material.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDatePicked;

  DatePickerWidget({
    Key? key,
    required this.selectedDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required this.onDatePicked,
  })  : firstDate = firstDate ?? DateTime(2024, 1),
        lastDate = lastDate ?? DateTime(2100),
        super(key: key);

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) onDatePicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: "Expense Date",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
          ),
        ),
      ),
    );
  }
}

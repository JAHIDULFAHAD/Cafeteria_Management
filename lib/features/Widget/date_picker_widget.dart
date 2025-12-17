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
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ).then((picked) {
      if (picked != null) {
        onDatePicked(picked);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

    return GestureDetector(
      onTap: () => _openPicker(context),
      child: TextFormField(
        readOnly: true,
        decoration: const InputDecoration(
          labelText: "Expense Date",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        controller: TextEditingController(text: formattedDate),
      ),
    );
  }
}

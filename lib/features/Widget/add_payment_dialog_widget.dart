import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Data/Model/meal_model.dart';
import '../meal/presentation/data/meal_provider.dart';

class AddPaymentDialog extends StatefulWidget {
  final MealProvider provider;
  final MealModel bill;

  const AddPaymentDialog({super.key, required this.provider, required this.bill});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final TextEditingController _payController = TextEditingController();

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.bill.remaining;

    return AlertDialog(
      backgroundColor: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: Text("Add Payment for ${widget.bill.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Remaining: AED $remaining"),
          const SizedBox(height: 8),
          TextField(
            controller: _payController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter payment amount"),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(
              fontSize: 16
          ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.greenAccent,
          ),
          onPressed: () {
            final payment = double.tryParse(_payController.text) ?? -1;

            if (payment <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Enter a valid positive amount")),
              );
              return;
            }
            if (payment > remaining) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Payment cannot exceed remaining: AED $remaining")),
              );
              return;
            }

            widget.bill.addPayment(payment);
            widget.provider.notifyListeners();
            Navigator.pop(context);
          },
          child: const Text("Add", style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16
          ),
          ),
        )
      ],
    );
  }
}

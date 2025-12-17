import 'package:flutter/material.dart';

class PurchaseFormWidget extends StatefulWidget {
  final List<String> itemNames;
  final DateTime selectedDate;
  final String? selectedItem;
  final String? editId;
  final double? editAmount;
  final bool isSubmitting;
  final VoidCallback onDateTap;
  final Function(String?) onItemChanged;
  final TextEditingController amountController;
  final VoidCallback onSubmit;

  const PurchaseFormWidget({
    Key? key,
    required this.itemNames,
    required this.selectedDate,
    this.selectedItem,
    this.editId,
    this.editAmount,
    required this.isSubmitting,
    required this.onDateTap,
    required this.onItemChanged,
    required this.amountController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<PurchaseFormWidget> createState() => _PurchaseFormWidgetState();
}

class _PurchaseFormWidgetState extends State<PurchaseFormWidget> {
  final _formKey = GlobalKey<FormState>();

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date Picker
              InkWell(
                onTap: widget.onDateTap,
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
                        _formatDate(widget.selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Item Dropdown
              DropdownButtonFormField<String>(
                value: widget.selectedItem,
                items: widget.itemNames.isNotEmpty
                    ? widget.itemNames
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList()
                    : [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("No items available"),
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: "Select Item",
                  prefixIcon: Icon(Icons.shopping_cart),
                  border: OutlineInputBorder(),
                ),
                onChanged: widget.itemNames.isNotEmpty ? widget.onItemChanged : null, // disable if empty
                validator: (value) =>
                value == null ? "Please select an item" : null,
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: widget.amountController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Amount (AED)",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter amount";
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return "Enter valid positive number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(widget.editId == null ? Icons.add : Icons.update),
                  label: Text(
                    widget.editId == null ? "Add Purchase" : "Update Purchase",
                  ),
                  onPressed: widget.isSubmitting ? null : () {
                    if (_formKey.currentState!.validate() &&
                        widget.selectedItem != null) {
                      widget.onSubmit();
                    }
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
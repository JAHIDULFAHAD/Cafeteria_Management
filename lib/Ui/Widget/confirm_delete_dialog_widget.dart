import 'package:flutter/material.dart';

class ConfirmDeleteDialogWidget extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onDelete;
  final String? buttonName;


  const ConfirmDeleteDialogWidget({
    super.key,
    required this.name,
    required this.onDelete, required this.description, this.buttonName,
  });

  /// Static method to show the dialog easily
  static void show(BuildContext context,
      {required String name, required VoidCallback onDelete, required String description, String? buttonName}) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialogWidget(
        name: name,
        onDelete: onDelete, description: description,
        buttonName: buttonName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
          SizedBox(width: 10),
          Text(
            "Confirm Delete",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$description",
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            "'$name'",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[800],
          ),
          child: const Text("Cancel", style: TextStyle(fontSize: 16)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: Text(
            buttonName ?? "Delete",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            onDelete();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

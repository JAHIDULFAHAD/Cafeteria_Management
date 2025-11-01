import 'package:flutter/material.dart';

class TotalCardWidget extends StatelessWidget {
  const TotalCardWidget({
    super.key,
    required this.total, required this.title,
  });

  final double total;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          "$title",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          "AED ${total.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
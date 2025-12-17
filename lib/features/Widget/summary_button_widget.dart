import 'package:flutter/material.dart';

class SummaryButtonWidget extends StatelessWidget {

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const SummaryButtonWidget({Key? key, required this.label, required this.icon, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
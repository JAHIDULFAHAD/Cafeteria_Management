import 'package:flutter/material.dart';
class PageTitleWidget extends StatelessWidget {
  const PageTitleWidget({
    super.key, required this.title,
  });
  final title ;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.teal, width: 2),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          " $title",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.teal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

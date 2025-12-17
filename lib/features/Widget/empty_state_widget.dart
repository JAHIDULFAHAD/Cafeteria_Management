import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final TextStyle? textStyle;

  const EmptyStateWidget({
    Key? key,
    this.message = "No data available",
    this.icon = Icons.info_outline,
    this.iconSize = 80,
    this.iconColor = Colors.grey,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: textStyle ??
                TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}
